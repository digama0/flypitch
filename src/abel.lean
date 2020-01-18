/-
Copyright (c) 2019 The Flypitch Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

Authors: Jesse Han, Floris van Doorn
-/
import .fol

open fol

local notation h :: t  := dvector.cons h t
local notation `[]` := dvector.nil
local notation `[` l:(foldr `, ` (h t, dvector.cons h t) dvector.nil `]`) := l

namespace abel
section

/- The language of abelian groups -/
inductive abel_functions : ℕ → Type
| zero : abel_functions 0
| plus : abel_functions 2

def L_abel : Language := ⟨abel_functions, λn, pempty⟩

def L_abel_plus {n} (t₁ t₂ : bounded_term L_abel n) : bounded_term L_abel n :=
@bounded_term_of_function L_abel 2 n abel_functions.plus t₁ t₂

@[reducible]def zero {n} : bounded_term L_abel n := bd_const abel_functions.zero

local infix ` +' `:100 := _root_.abel.L_abel_plus

def a_assoc : sentence L_abel := ∀' ∀' ∀' (((&(by to_dfin 2) +' &1) +' &0) ≃ (&(by to_dfin 2) +' (&1 +' &0)))

def a_zero_right : sentence L_abel := ∀' (&0 +' zero ≃ &0)

def a_zero_left : sentence L_abel := ∀'(zero +' &0 ≃ &0)

def a_inv : sentence L_abel := ∀' ∃' (&1 +' &0 ≃ zero ⊓ &0 +' &1 ≃ zero)

def a_comm : sentence L_abel := ∀' ∀' (&1 +' &0 ≃ &0 +' &1)

/- axioms of abelian groups -/
def T_ab : Theory L_abel := {a_assoc, a_zero_right, a_zero_left, a_inv, a_comm}

def L_abel_structure_of_int : Structure L_abel :=
begin
  refine ⟨ℤ,_,_⟩,
  {intros n f, induction f,
    exact λ v, 0,
    exact λ v, (v.nth 0 (by repeat{constructor})) + (v.nth 1 (by repeat{constructor}))},
  {intros, cases a}
end

notation `ℤ'` := _root_.abel.L_abel_structure_of_int

@[simp]lemma ℤ'_ℤ : ↥(ℤ') = ℤ := by refl

@[reducible]instance has_zero_ℤ' : has_zero ℤ' := ⟨(0 : ℤ)⟩

@[reducible]instance has_add_ℤ' : has_add ℤ' := ⟨λx y, (x + y : ℤ)⟩

@[reducible]instance nonempty_ℤ' : nonempty ℤ' := by simp

@[simp]lemma zero_is_zero : @realize_bounded_term L_abel ℤ' _ [] _ zero [] = (0 : ℤ) := by refl

@[simp]lemma plus_is_plus_l : ∀ x y : ℤ', realize_bounded_term ([x,y]) (&0 +' &1) [] = x + y := by {intros, refl}

@[simp]lemma plus_is_plus_r : ∀ x y : ℤ', realize_bounded_term ([x,y]) (&1 +' &0) [] = y + x := by {intros, refl}

-- instance has_add_Structure_L_abel {S : Structure L_abel} : has_add S :=
--   ⟨λ x y, realize_bounded_term ([x,y]) (&0 +' &1) []⟩

-- @[simp]lemma plus_is_plus {S : Structure L_abel} {n} {t₁ t₂ : bounded_term L_abel n} {v : dvector S n} : realize_bounded_term v (t₁ +' t₂) [] = (realize_bounded_term v t₁ []) + (realize_bounded_term v t₂ []) := by refl

/- Note: the above seems to confuse the elaborator when proving the theorem below. Probably because ℤ has an existing has_add instance. -/

def presburger_arithmetic : Theory L_abel := Th ℤ'

theorem ℤ'_is_abelian_group : T_ab ⊆ presburger_arithmetic :=
begin
  intros a H, repeat{cases H},
  {intros x y, simp},
  {intros x H, dsimp at H, unfold realize_bounded_formula, have : ∃ y : ℤ, x + y = 0,
  by exact ⟨-x, by tidy⟩, rcases this with ⟨y, hy⟩, apply H y, simp[hy], refl},
  {intro x, change 0 + x = x, rw[zero_add]},
  {intro x, change x + 0 = x, rw[add_zero]},
  {intros x y z, change x + y + z = x + (y + z), rw[add_assoc]}
end

end
end abel
