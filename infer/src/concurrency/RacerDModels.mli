(*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *)

open! IStd

type container_access = ContainerRead | ContainerWrite

val get_container_access : Procname.t -> Tenv.t -> container_access option
(** return Some (access) if this procedure accesses the contents of a container (e.g., Map.get) *)

val has_return_annot : (Annot.Item.t -> bool) -> Procname.t -> bool

val is_functional : Procname.t -> bool

val acquires_ownership : Procname.t -> Tenv.t -> bool

val is_box : Procname.t -> bool
(** return true if the given procname boxes a primitive type into a reference type *)

val is_thread_confined_method : Tenv.t -> Procname.t -> bool
(** Methods in [@ThreadConfined] classes and methods annotated with [@ThreadConfined] are assumed to
    all run on the same thread. For the moment we won't warn on accesses resulting from use of such
    methods at all. In future we should account for races between these methods and methods from
    completely different classes that don't necessarily run on the same thread as the confined
    object. *)

val should_analyze_proc : Tenv.t -> Procname.t -> bool
(** return true if we should compute a summary for the procedure. if this returns false, we won't
    analyze the procedure or report any warnings on it. note: in the future, we will want to analyze
    the procedures in all of these cases in order to find more bugs. this is just a temporary
    measure to avoid obvious false positives *)

val get_current_class_and_threadsafe_superclasses :
  Tenv.t -> Procname.t -> (Typ.name * Typ.name list) option

val is_thread_safe_method : Procname.t -> Tenv.t -> bool
(** returns true if method or overriden method in superclass is [@ThreadSafe],
    [@ThreadSafe(enableChecks = true)], or is defined as an alias of [@ThreadSafe] in a .inferconfig
    file. *)

val is_marked_thread_safe : Procname.t -> Tenv.t -> bool

val is_safe_access : 'a HilExp.Access.t -> HilExp.AccessExpression.t -> Tenv.t -> bool
(** check if an access to a field is thread-confined, or whether the field is volatile *)

val should_flag_interface_call : Tenv.t -> HilExp.t list -> CallFlags.t -> Procname.t -> bool
(** should an interface call be flagged as potentially non-thread safe? *)

val is_synchronized_container : Procname.t -> HilExp.AccessExpression.t -> Tenv.t -> bool
(** is a call on an access expression to a method of a synchronized container? *)

val is_abstract_getthis_like : Procname.t -> bool
(** is the callee an abstract method with one argument where argument type is equal to return type *)

val creates_builder : Procname.t -> bool
(** is the callee a static java method returning a [Builder] object? *)

val is_builder_passthrough : Procname.t -> bool
(** is the callee a non-static [Builder] method returning the same type as its receiver *)

val is_initializer : Tenv.t -> Procname.t -> bool
(** should the given procedure be treated as a constructor/initializer? *)
