module type S = sig
  type elt
  type t

  val empty    : unit -> t
  val mem      : elt -> t -> bool
  val add      : elt -> t -> unit
  val remove   : elt -> t -> unit
  val cardinal : t -> int
end

module Lib : sig
  module Make : functor (Ord : Set.OrderedType) -> S with type elt = Ord.t
end = struct
  module Make (Ord : Set.OrderedType) = struct
    module S = Set.Make (Ord)

    type elt = Ord.t
    type t = { mutable content : S.t; mutable cardinal : int; mutex : Mutex.t }

    let empty () = { content = S.empty; cardinal = 0; mutex = Mutex.create () }

    let mem_non_lock a t = S.mem a t.content

    let mem a t =
      Mutex.lock t.mutex;
      let b = S.mem a t.content in
      Mutex.unlock t.mutex;
      b

    let add a t =
      Mutex.lock t.mutex;
      if not (mem_non_lock a t) then begin
        t.content  <- S.add a t.content;
        t.cardinal <- t.cardinal + 1
      end;
      Mutex.unlock t.mutex

    let remove a t =
      Mutex.lock t.mutex;
      if mem_non_lock a t then begin
        t.content  <- S.remove a t.content;
        t.cardinal <- t.cardinal - 1
      end;
      Mutex.unlock t.mutex

    let cardinal t =
      Mutex.lock t.mutex;
      let c = t.cardinal in
      Mutex.unlock t.mutex;
      c
  end
end

open Lin
module LibInt = Lib.Make (Int)

module Spec : Spec = struct
  type t = LibInt.t

  let init = LibInt.empty
  let cleanup _ = ()

  let api =
    let int = nat_small in
    [
      val_ "mem"      LibInt.mem      (int @-> t @-> returning bool);
      val_ "add"      LibInt.add      (int @-> t @-> returning unit);
      val_ "remove"   LibInt.remove   (int @-> t @-> returning unit);
      val_ "cardinal" LibInt.cardinal (t @-> returning int);
    ]
end

module LibDomain = Lin_domain.Make (Spec)

let _ =
  QCheck_base_runner.run_tests ~verbose:true
    [ LibDomain.lin_test ~count:1000 ~name:"Lin parallel tests" ]
