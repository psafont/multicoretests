open Ref_stm_spec
open STM

module RT_int   = STM_Thread.Make(RConf_int)
module RT_int64 = STM_Thread.Make(RConf_int64)

module RConf_int_GC = STM.AddGC(RConf_int)
module RConf_int64_GC = STM.AddGC(RConf_int64)

module RT_int_GC = STM_Thread.Make(RConf_int_GC)
module RT_int64_GC = STM_Thread.Make(RConf_int64_GC)
;;
Util.set_ci_printing ()
;;
QCheck_runner.run_tests_main
  (let count = 1000 in
   [RT_int.agree_test_conc    ~count ~name:"global int ref test";
    RT_int_GC.agree_test_conc ~count ~name:"global int ref test (w/AddGC functor)";
    RT_int.agree_test_conc    ~count ~name:"global int64 ref test";
    RT_int_GC.agree_test_conc ~count ~name:"global int64 ref test (w/AddGC functor)";
   ])
