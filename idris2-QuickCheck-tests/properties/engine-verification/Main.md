# QuickCheck Engine Verification

The QuickCheck engine is the "Oracle" of our Antifragile system. To trust our libraries, we must first trust the engine that verifies them. In this chapter, we perform a series of sanity checks on the core QuickCheck machinery.

```idris
module Main

import QuickCheck
import Data.List
import Data.So

%default total
```

## 1. Successful Properties

A robust testing engine must be able to verify tautologies. We test two fundamental properties of Integers and Lists.

### Integer Commutativity
Addition of Integers is commutative. QuickCheck should pass this after 100 tests.

```idris
prop_addCommutative : Property
prop_addCommutative = forAll {a = (Int, Int)} {prop = Bool} arbitrary (MkFn (\(a, b) =>
  a + b == b + a))
```

### List Double Reversal
Reversing a list twice should return the original list.

```idris
prop_listDoubleReverse : Property
prop_listDoubleReverse = forAll {a = List Int} {prop = Bool} arbitrary (MkFn (\xs =>
  reverse (reverse xs) == xs))
```

## 2. Detecting Failures

An even more critical capability is the detection of counterexamples. We provide a property that we *know* is false.

### List Append Commutativity (False)
Appending lists is NOT commutative (e.g., `[1] ++ [2] != [2] ++ [1]`). QuickCheck should detect this and provide a counterexample.

```idris
prop_listAppendCommutative : Property
prop_listAppendCommutative = forAll {a = (List Int, List Int)} {prop = Bool} arbitrary (MkFn (\(xs, ys) =>
  xs ++ ys == ys ++ xs))
```

## 3. Verification Execution

We run these tests and observe the engine's output. For the false property, we expect to see a "Falsifiable" message with the offending arguments.

```idris
main : IO ()
main = do
  let res1 = QuickCheck.quickCheck prop_addCommutative
  putStrLn $ "prop_addCommutative: " ++ res1.msg
  
  let res2 = QuickCheck.quickCheck prop_listDoubleReverse
  putStrLn $ "prop_listDoubleReverse: " ++ res2.msg
  
  let res3 = QuickCheck.quickCheck prop_listAppendCommutative
  putStrLn $ "prop_listAppendCommutative: " ++ 
    (if isJust res3.pass && fromMaybe True res3.pass then "FAILED (Should have failed)" else "OK (Correctly detected failure)")
```
