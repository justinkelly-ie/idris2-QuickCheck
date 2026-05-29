# idris2-QuickCheck

**A zero-dependency property-based testing library for [Idris 2](https://github.com/idris-lang/Idris2).**

[![Idris2](https://img.shields.io/badge/Idris2-Pure_Nat-blue.svg)](https://github.com/idris-lang/Idris2)
[![Dependencies](https://img.shields.io/badge/Dependencies-base%2C_contrib-green.svg)]()

A port and internalization of the classic QuickCheck property-testing approach for Idris 2. Used as the shared test primitive across the [Nat-Science](https://github.com/justinkelly-ie/Nat-Science) project constellation.

---

## Features

- **Zero upward dependencies** — only `base` and `contrib`; safe to use in any Idris 2 project without circular dependency risk
- **LCG PRNG** — fast, deterministic, seedable pseudo-random generator (`LCG.idr`)
- **Testable typeclass** — `Bool`, `Property`, and custom types all work as test targets
- **Configurable** — `quick` (100 tests), `verbose`, and `TinyConf` built in
- **`QCRes` result type** — structured pass/fail/exhausted result for programmatic inspection
- **Type-level checking** — `Passes` type and `Check` function for compile-time property enforcement

---

## Modules

| Module | Role |
|---|---|
| `LCG` | Linear Congruential Generator — the PRNG engine |
| `QuickCheck` | Property generation, `Testable` typeclass, `quickCheck`, `check`, `QCRes` |

---

## Usage

```idris
import QuickCheck

-- A simple property
prop_addCommutative : Int -> Int -> Bool
prop_addCommutative x y = x + y == y + x

-- Run it
main : IO ()
main = do
  let res = quickCheck prop_addCommutative
  putStrLn (msg res)   -- "OK, passed 100 tests ."
```

### With structured results

```idris
let res = quickCheck myProperty
case pass res of
  Just True  => putStrLn "PASS"
  Just False => putStrLn $ "FAIL: " ++ msg res
  Nothing    => putStrLn "Arguments exhausted"
```

### Custom config

```idris
let res = check verbose myProperty    -- prints each test case
let res = check TinyConf myProperty   -- only 2 tests (REPL-friendly)
```

---

## Installation

Resolve locally via `pack.toml`:

```toml
[custom.all.idris2-QuickCheck]
type = "local"
path = "../idris2-QuickCheck"
ipkg = "idris2-QuickCheck.ipkg"
```

Then add to your `.ipkg`:

```
depends = base, contrib, idris2-QuickCheck
```

---

## Used By

| Project | Role |
|---|---|
| [`Nat-Science`](https://github.com/justinkelly-ie/Nat-Science) | 55 property tests across physics, chemistry & biology |
| [`idris2-Universe`](https://github.com/justinkelly-ie/idris2-Universe) | Core simulation engine tests |
| [`idris2-Multiset`](https://github.com/justinkelly-ie/idris2-Multiset) | Multiset algebra law verification |
| [`idris2-Chromogeometry`](https://github.com/justinkelly-ie/idris2-Chromogeometry) | Chromogeometric spread/quadrance theorems |

---

## Origin

Ported from the original [QuickCheck for Haskell](https://web.archive.org/web/20010731175214/http://www.cs.chalmers.se/~rjmh/QuickCheck/QuickCheck.hs) by Koen Claessen & John Hughes. Idris 2 port by Thomas E. Hansen, internalized and extended for the Nat-Science project by Justin Kelly.

---

© Justin Kelly. All rights reserved.
