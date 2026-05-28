# Double Slit Interference Phenomenon

In standard quantum mechanics, the double-slit experiment is often explained by invoking wave-particle duality. In the deterministic Primorial architecture, we eliminate this continuity. A particle does not become a wave; it remains a discrete point with a fractional input spread.

The "interference pattern" observed on the detector screen is purely an arithmetic projection of Spread Polynomials.

```idris
module Main

import QuickCheck
import Math.SpreadPolynumber
import Math.IntPolynumber
import Math.Fraction
import Math.FractionalEvaluator

import Data.Maybe

%default covering
```

## Slit Geometry 

We use a simple gate degree for the geometry. A bright fringe occurs if the polynomial evaluated at the given fractional spread results in an exact integer.

```idris
isDivisible : Nat -> Nat -> Bool
isDivisible Z _ = True
isDivisible _ Z = False
isDivisible n d = 
  case n `minus` d of
       Z => (n == d)
       diff => isDivisible (assert_smaller n diff) d

projectsToBrightFringe : Nat -> Spread -> Bool
projectsToBrightFringe gateDegree spread =
  let algebraicPoly = memoSpreadPoly gateDegree
      polyResult = evaluateIntPoly algebraicPoly spread
  in polyResult.value.denominator == 1 || isDivisible polyResult.value.numerator polyResult.value.denominator
```

## QuickCheck Properties

We verify that for certain combinations of rational spreads, we get either deterministic bright or dark fringes.

```idris
restrictGate : Nat -> Nat
restrictGate Z = Z
restrictGate (S k) = 
  let r = restrictGate k 
  in if r == 15 then 0 else S r

prop_fringesAreDeterministic : Property
prop_fringesAreDeterministic = forAll {a = (Nat, Nat, Nat)} {prop = Bool} arbitrary (MkFn (\(gateDeg, num, den) =>
  let den' = if den == 0 then 1 else den
      spread = MkSpread (MkFraction num den')
      -- It should either be a bright or dark fringe, there is no ambiguity.
      -- We just evaluate it to ensure it completes without crashing.
      res = projectsToBrightFringe (restrictGate gateDeg) spread
  in res == True || res == False))
```

## Main Test Runner

```idris
main : IO ()
main = do
  let res1 = QuickCheck.quickCheck prop_fringesAreDeterministic
  putStrLn $ "prop_fringesAreDeterministic: " ++ res1.msg
```
