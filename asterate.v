From stars Require Import definitions vector matrix.

Section Matrix_asterate.

Variable X : Type.
Notation sq n := (mat X n n).
Notation mat m n := (mat X m n).

Context `{SR : Star_Semiring X}.

Section Inductive_construction.

Section Block_construction.

Variable m n : nat.
Variable star_m: sq m -> sq m.
Variable star_n: sq n -> sq n.

Definition mat_star_blocks
  (a : sq m) (b : mat m n)
  (c : mat n m) (d : sq n) : sq (m + n) :=
  let d'     := star_n d     in
  let bd'    := b × d'       in
  let d'c    := d' × c       in
  let f      := a + bd' × c  in
  let f'     := star_m f     in
  let f'bd'  := f' × bd'     in
  let d'cf'  := d'c × f'     in
  blocks f' f'bd' d'cf' (d' + d'cf' × bd').

Lemma left_expand_mat_star_blocks a b c d :
  mat_star_blocks a b c d ≡ 1 + blocks a b c d * mat_star_blocks a b c d.
Proof.
unfold mat_star_blocks; cbn.
rewrite eq_one_blocks, mul_mat_unfold, equiv_mul_blocks, equiv_add_blocks.
apply proper_blocks.
Admitted.

End Block_construction.

Arguments mat_star_blocks {_ _}.

Definition mat_S_partition {n} (a : sq (S n)) :=
  (([# [# vhd (vhd a) ]], [# vtl (vhd a) ]),
  (vmap (λ r, [# vhd r ]) (vtl a), vmap vtl (vtl a))).

Definition mat_star_ind_step {n} star_ind (a : sq (S n)) :=
  let p := mat_S_partition a in
  mat_star_blocks (mat_map star) star_ind p.1.1 p.1.2 p.2.1 p.2.2.

Fixpoint mat_star_ind {n} : sq n -> sq n :=
  match n with
  | 0 => λ x, x
  | S m => mat_star_ind_step mat_star_ind
  end.

Lemma blocks_S_partition {n} (a : sq (S n)) :
  let p := mat_S_partition a in
  a = blocks p.1.1 p.1.2 p.2.1 p.2.2.
Proof.
Admitted.

Lemma mat_star_ind_S_unfold {n} (a : sq (S n)) :
  mat_star_ind a = mat_star_ind_step mat_star_ind a.
Proof.
done.
Qed.

Lemma left_expand_mat_star_ind n (a : sq n) :
  mat_star_ind a ≡ 1 + a * mat_star_ind a.
Proof.
induction n. cbn; inv_vec a; done.
rewrite blocks_S_partition with (a:=a) at 2.
rewrite mat_star_ind_S_unfold; unfold mat_star_ind_step.
rewrite left_expand_mat_star_blocks at 1; done.
Qed.

Lemma right_expand_mat_star_ind n (a : sq n) :
  mat_star_ind a ≡ 1 + mat_star_ind a * a.
Proof.
Admitted.

Lemma left_intro_mat_star_ind n (a b : sq n) :
  a * b ⪯ b -> mat_star_ind a * b ⪯ b.
Proof.
Admitted.

Lemma right_intro_mat_star_ind n (a b : sq n) :
  b * a ⪯ b -> b * mat_star_ind a ⪯ b.
Proof.
Admitted.

End Inductive_construction.

Section Warshall_Floyd_Kleene.

Definition mat_plus_WFK {n} (a : sq n) : sq n :=
  let step k c i j := c@i@j + c@i@k * c@k@k{*} * c@k@j in
  foldr (λ k b, mat_build (step k b)) a (vseq n).

End Warshall_Floyd_Kleene.

Section Matrix_star_semiring.

Variable n : nat.
Notation mat := (sq n).

Global Instance : Star mat :=
  λ a, 1 + mat_plus_WFK a.

Global Instance : Star_Semiring mat.
Proof. split. c. Admitted.

End Matrix_star_semiring.

End Matrix_asterate.
