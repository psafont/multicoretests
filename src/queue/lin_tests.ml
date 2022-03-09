open QCheck

module Spec =
  struct
    type t = int Queue.t
    let m = Mutex.create ()
    
    type cmd =
      | Add of int'
      | Take
      | Take_opt
      | Peek
      | Peek_opt
      | Clear
      | Is_empty
      | Fold of fct * int'
      | Length [@@deriving qcheck, show { with_path = false }]
    and int' = int [@gen Gen.nat]
    and fct = (int -> int -> int) fun_ [@printer fun fmt f -> fprintf fmt "%s" (Fn.print f)] [@gen (fun2 Observable.int Observable.int int).gen] 

    type res =
      | RAdd
      | RTake of int option
      | RTake_opt of int option
      | RPeek of int option
      | RPeek_opt of int option
      | RClear
      | RIs_empty of bool
      | RFold of int
      | RLength of int [@@deriving show { with_path = false }]

    let init () = Queue.create ()
    let cleanup _ = ()
  end

module QConf =
  struct
    include Spec
    let run c q = match c with
      | Add i       -> Queue.add i q; RAdd
      | Take        -> RTake (
                           try Some (Queue.take q)
                           with Queue.Empty -> None)
      | Take_opt    -> RTake_opt (Queue.take_opt q)
      | Peek        -> RPeek (
                           try Some (Queue.peek q)
                           with Queue.Empty -> None)
      | Peek_opt    -> RPeek_opt (Queue.peek_opt q)
      | Length      -> RLength (Queue.length q)
      | Is_empty    -> RIs_empty (Queue.is_empty q)
      | Fold (f, a) -> RFold (Queue.fold (Fn.apply f) a q) 
      | Clear       -> Queue.clear q; RClear
   end

module QMutexConf =
  struct
    include Spec
    let run c q = match c with
      | Add i       -> Mutex.lock m;
                       Queue.add i q;
                       Mutex.unlock m; RAdd
      | Take        -> Mutex.lock m;
                       let r =
                         try Some (Queue.take q)
                         with Queue.Empty -> None
                       in
                       Mutex.unlock m;
                       RTake r
      | Take_opt    -> Mutex.lock m;
                       let r = Queue.take_opt q in
                       Mutex.unlock m;
                       RTake_opt r
      | Peek        -> Mutex.lock m;
                       let r =
                         (try Some (Queue.peek q)
                          with Queue.Empty -> None)
                       in
                       Mutex.unlock m;
                       RPeek r
      | Peek_opt    -> Mutex.lock m;
                       let r = Queue.peek_opt q in
                       Mutex.unlock m;
                       RPeek_opt r
      | Length      -> Mutex.lock m;
                       let l = Queue.length q in
                       Mutex.unlock m;
                       RLength l
      | Is_empty    -> Mutex.lock m;
                       let b = Queue.is_empty q in
                       Mutex.unlock m;
                       RIs_empty b
      | Fold (f, a) -> Mutex.lock m;
                       let r = (Queue.fold (Fn.apply f) a q)  in
                       Mutex.unlock m;
                       RFold r
      | Clear       -> Mutex.lock m;
                       Queue.clear q;
                       Mutex.unlock m;
                       RClear
end
    
module QMT = Lin.Make(QMutexConf)
module QT  = Lin.Make(QConf)
;;
Util.set_ci_printing ()
;;
QCheck_runner.run_tests_main [
    QMT.lin_test `Domain ~count:1000 ~name:"Queue test with domains and mutex";
    QMT.lin_test `Thread ~count:1000 ~name:"Queue test with threads and mutex";
    QT.lin_test  `Domain ~count:1000 ~name:"Queue test with domains without mutex";
    QT.lin_test  `Thread ~count:1000 ~name:"Queue test with threads without mutex";
  ]