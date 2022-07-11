
module TestConf = struct
  type t = Bytes.t
  let init () = Bytes.make 42 '0'
  let cleanup _ = ()
  open Lin_api
  let api = [ val_ "Bytes.get" Bytes.get (t @-> int @-> returning_or_exc char) ]
end

module BT = Lin_api.Make(TestConf)
;;
Util.set_ci_printing ()
;;
QCheck_runner.run_tests_main [
  BT.lin_test `Domain ~count:1000 ~name:"Byte test with domains";
]
