# Changes

## Next version

- #337: Add 3 `Bytes.t` combinators to `Lin`: `bytes`, `bytes_small`, `bytes_small_printable`
- #329: Support `qcheck-lin` and `qcheck-stm` on OCaml 4.14.x without
        the `Domain` and `Effect` modes
- #316: Fix `rep_count` in `STM_thread` so that negative and positive
  tests repeat equally many times
- #318: avoid repetitive interleaving searches in `STM_domain` and `STM_thread`
- #312: Escape and quote `bytes` printed with `STM`'s `bytes` combinator
- #295: ensure `cleanup` is run in the presence of exceptions in
  - `STM_sequential.agree_prop` and `STM_domain.agree_prop_par`
  - `Lin_thread.lin_prop` and `Lin_effect.lin_prop`

## 0.1.1

- #263: Cleanup resources after each domain-based `Lin` test
- #281: Escape and quote strings printed with `STM`'s `string` combinator

## 0.1

The initial opam release of `qcheck-lin`, `qcheck-stm`, and
`qcheck-multicoretests-util`.

The `multicoretests` package is not released on opam, as it is of
limited use to OCaml developers.
