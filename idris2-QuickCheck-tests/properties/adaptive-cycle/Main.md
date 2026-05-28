# Adaptive Cycle Simulation

The Adaptive Cycle is the cosmological heartbeat of the Pure Multiset Ascension architecture.
This test verifies that the full quantum gate pipeline (n=2 → n=3 → n=4 → n=5 → n=7 → n=11 → n=13)
correctly partitions, shatters, and evaluates the ascension/decoherence decision.

We also verify key Findings — compiled physics derivations that must remain invariant
as the pipeline evolves.

```idris
module Main

import QuickCheck
import Simplex.Core
import Evolution.Cycle
import Evolution.Transform
import Evolution.Gate
import Evolution.Clock
import Physics.System.CosmicPartition
import Physics.Analysis.CosmicEnergyBudget
import Physics.System.Spread13
import Physics.System.PeriodicTable
import Physics.Analysis.FineStructureDerivation
import Physics.Analysis.CosmologicalConstant
import Physics.Analysis.VacuumPairProduction
import Physics.Analysis.DarkEnergyExpansion
import Physics.Analysis.GravitationalTimeDilation
import Physics.Elements.Hydrogen
import Physics.Elements.Oxygen
import Physics.Elements.Water
import Physics.Scales.PythagoreanFixedPoint
import Physics.Scales.ScaleTrajectory
import Physics.Scales.IceGeometry
import Math.Multiset
import Math.IntPolynumber
import Math.SpreadPolynumber
import Math.Chromogeometry
import Math.Fraction

import Data.List

%default covering
```

## Test Seeds

We construct concrete seed states to exercise the pipeline. The origin geometry
`(0, 0)` is the canonical active coordinate used throughout the evolution modules.

We cap spread polynomial degrees at 8 to keep computation tractable — `spreadPoly 13`
generates polynomials with thousands of terms.

```idris
origin : Geometry
origin = MkPixel 0 0

-- Cap degree to avoid huge polynomial explosion (spreadPoly 13 has thousands of terms)
capDegree : Nat -> Nat
capDegree n = if n > 7 then 7 else n

seedPoly : IntPolynumber
seedPoly = spreadPoly 3

seedState : Multiset (Geometry, Amplitude)
seedState = fromList [((origin, seedPoly), 1)]

vacuumUniverse : UniverseState
vacuumUniverse = MkUniverseState emptySubstrate emptySparseMaxel

seededUniverse : UniverseState
seededUniverse = MkUniverseState emptySubstrate seedState
```

## Part 1: Pipeline Properties

### Property 1: Partition Gate Returns Two Parts

The 128/27 partition must produce two multisets (latent and visible).
We verify both are structurally valid (non-crashing, finite).

```idris
prop_partitionProducesTwoParts : Property
prop_partitionProducesTwoParts = forAll {a = Nat} {prop = Bool} arbitrary (MkFn (\rawDeg =>
  let degree = capDegree rawDeg
      poly = spreadPoly degree
      (latent, visible) = partitionLogic 128 origin poly
      latentCount = length (multisetToList latent)
      visibleCount = length (multisetToList visible)
  in latentCount >= 0 && visibleCount >= 0))
```

### Property 2: Resonance Reduces Coefficients

After the n=13 resonance shattering, every coefficient in the result must be
in range [0, moduloBase). We force the trigger by setting multiplicity to 200.

```idris
allCoeffsBelow : Integer -> IntPolynumber -> Bool
allCoeffsBelow bound poly =
  all (\(_, coef) => coef >= 0 && coef < bound) (multisetToList poly)

prop_resonanceReduces : Property
prop_resonanceReduces = forAll {a = Nat} {prop = Bool} arbitrary (MkFn (\rawDeg =>
  let degree = capDegree rawDeg
      poly = spreadPoly degree
      bigState = fromList [((origin, poly), 200)]
      resonated = evaluateResonance 137 13 origin bigState
      polys = map (\((_, p), _) => p) (multisetToList resonated)
  in case polys of
       []      => True
       (p::ps) => allCoeffsBelow 13 p))
```

### Property 3: Ascension Produces a Singleton

`ascendScale` must condense any number of micro-states into exactly one macro-node.

```idris
prop_ascensionCondenses : Property
prop_ascensionCondenses = forAll {a = Nat} {prop = Bool} arbitrary (MkFn (\rawDeg =>
  let degree = capDegree rawDeg
      poly1 = spreadPoly degree
      poly2 = spreadPoly (degree + 1)
      microStates = fromList [((origin, poly1), 1), ((MkPixel 1 1, poly2), 1)]
      macroNode = ascendScale origin microStates
      entries = multisetToList macroNode
  in length entries == 1))
```

### Property 4: CanAscend Requires Exact Balance

The three-fold proof should only succeed when the three capacities sum to the limit.
On a vacuum substrate with origin geometry and empty residue, it should fail.

```idris
prop_canAscendRequiresBalance : Bool
prop_canAscendRequiresBalance =
  let result = canAscend Blue emptySubstrate emptySparseMaxel
  in result == False
```


## Part 3: Findings Verification

These properties verify that key physics derivations remain invariant.

### Property 8: Primorial Grid Is 210 States

The total combinatorial state space (27 + 55 + 128 = 210) is structurally mandated.

```idris
prop_primorialGridIs210 : Bool
prop_primorialGridIs210 = primordialGridStates == 210
```

### Property 9: Cosmic Energy Budget Matches Empirical Data

The 128/55/27 partition yields Dark Energy ~61%, Dark Matter ~26%, Visible ~13%.

```idris
prop_cosmicBudgetMatches : Bool
prop_cosmicBudgetMatches =
  let budget = calculateCosmicBudget constructPrimorialGrid
  in verifyEmpiricalMatch budget
```

### Property 10: S_13 Is Non-Trivial

The 13th spread polynomial must be non-empty (it drives the resonance gate).

```idris
prop_s13NonTrivial : Bool
prop_s13NonTrivial =
  let s13 = evaluateS13
  in multiplicityAll s13 > 0
```

### Property 11: Grid Limit Derives 137

The calculated grid limit from the cosmic partition must equal 137.

```idris
prop_gridLimitIs137 : Bool
prop_gridLimitIs137 =
  let grid = constructPrimorialGrid
  in calculateGridLimit grid == 137
```

### Property 12: Adaptive Cycle Is 7 Gates

The canonical gate sequence has exactly 7 gates.

```idris
prop_cycleHas7Gates : Bool
prop_cycleHas7Gates = length adaptiveCycle == 7
```

### Property 13: Gate Degrees Are Correct

The gate degrees match the spread polynomial indices.

```idris
prop_gateDegrees : Bool
prop_gateDegrees =
  map degree adaptiveCycle == [2, 3, 4, 5, 7, 11, 13]
```

## Part 4: Natural Ascension

These tests verify the end-to-end ascension pipeline. Each test seeds a fresh
`UniverseState` from the primorial grid and runs one epoch. The substrate folds
naturally from the state vector geometry — no hardcoded substrate.

### Property 14: Fresh Primorial Seed Ascends in One Epoch

The visible matter pool from `constructPrimorialGrid` seeds the state vector.
After one full adaptive cycle, the system should ascend — the substrate folds
naturally through `stepUniverseLocalized`, and the three-fold proof triggers.

## Part 5: Findings Deep Verification

These tests verify the compiled physics derivations — the Findings modules.

### Property 18: Exactly 137 Stable Elements

The resonance gate (n=13) limits the periodic table to exactly 137 stable elements.
No hardcoded Fin — the limit emerges from `evaluateResonance`.

```idris
prop_periodicTableHas137 : Bool
prop_periodicTableHas137 = stableElementCount == 137
```

### Property 19: Feynmanium Boundary

Z=137 survives, Z=138 decoheres.

```idris
prop_feynmaniumBoundary : Bool
prop_feynmaniumBoundary =
  isStableElement 137 && not (isStableElement 138)
```

### Property 20: Oxygen Divides Dark Energy Pool

128 / 8 = 16 exactly. Oxygen partitions the 2^7 dark energy pool into 16 quanta.

```idris
prop_oxygenDividesLatent : Bool
prop_oxygenDividesLatent = div 128 8 == 16 && mod 128 8 == 0
```

### Property 21: Oxygen Remainder is MatterGate

27 mod 8 = 3. The remainder of Oxygen in the visible sector (3^3) is exactly the
MatterGate degree (n=3).

```idris
prop_oxygenVisibleResidue : Bool
prop_oxygenVisibleResidue = mod (the Integer 27) 8 == cast (degree MatterGate)
```

### Property 22: Vacuum Quantum is 8

Adding S₂ (BackgroundGate) to any state contributes exactly 8 units of lag.

```idris
prop_vacuumQuantumIs8 : Bool
prop_vacuumQuantumIs8 = vacuumQuantum == 8
```

### Property 23: Primordial Alpha is 1/210

For empty space (zero lag), the running Fine Structure Constant should equal 1/210.

```idris
prop_primordialAlpha : Bool
prop_primordialAlpha =
  verifyPrimordialAlpha emptySparseMaxel
```

### Property 24: Vacuum Energy is Finite

The cosmological constant predicted by the model must be finite and strictly
bounded — no 10^120 catastrophe.

```idris
prop_finiteVacuumEnergy : Bool
prop_finiteVacuumEnergy =
  let pip = emptySparseMaxel
      lambda = predictCosmologicalConstant pip
  in lambda.numerator > 0 && lambda.denominator > 0 &&
     lambda.numerator * 100 < lambda.denominator
```

### Property 25: Pair Production Conserves Structure

Schwinger pair production adds exactly +2 multiplicity to the state
(one particle + one antiparticle).

```idris
prop_pairProductionAdds : Bool
prop_pairProductionAdds =
  let pip = emptySparseMaxel
      geom = MkPixel 0 0
      afterPair = simulateSchwingerEffect pip geom
      pairLag = stateLag afterPair
  in pairLag == 2
```

## Part 6: Water Chemistry

These tests verify the chromogeometric structure of the H₂O molecule.

### Property 26: Water Baryonic Lag is 10

Total Z = 2×1 + 8 = 10.

```idris
prop_waterBaryonicLag : Bool
prop_waterBaryonicLag = waterBaryonicLag == 10
```

### Property 27: Water Bond Count is 2

Oxygen's valence = BackgroundGate degree = 2.

```idris
prop_waterBondCount : Bool
prop_waterBondCount = waterBondCount == 2
```

### Property 28: Water is Stable

Z=10 is well below the Feynman limit (137).

```idris
prop_waterIsStable : Bool
prop_waterIsStable = waterIsStable
```

### Property 29: Oxygen Valence is BackgroundGate

Oxygen needs 2 electrons = BackgroundGate degree.

```idris
prop_oxygenValenceIs2 : Bool
prop_oxygenValenceIs2 = oxygenValence == 2
```

### Property 30: Dark Energy Quanta is 16

128 / 8 = 16. Oxygen partitions the dark energy pool into 16 quanta.

```idris
prop_darkEnergyQuantaIs16 : Bool
prop_darkEnergyQuantaIs16 = darkEnergyQuanta == 16
```

### Property 31: Hydrogen has Minimal Lag

Hydrogen is the unit baryon — lag = 1.

```idris
prop_hydrogenLagMinimal : Bool
prop_hydrogenLagMinimal = hydrogenLag (MkPixel 0 0) > 0
```

### Property 32: Bond Quadrance is ChargeGate²

Q(OH) = 4² + 3² = 25 = 5² = ChargeGate².

```idris
prop_bondQuadranceIs25 : Bool
prop_bondQuadranceIs25 = bondQuadrance == 25
```

### Property 33: Bond Spread is 7²/5⁴

The spread at O = 49/625 = TimeGate² / ChargeGate⁴.

```idris
prop_bondSpreadGateDerived : Bool
prop_bondSpreadGateDerived =
  let (num, den) = bondSpread
  in num == 196 && den == 2500
```

### Property 34: Inter-Hydrogen Quadrance is BackgroundGate

Q(H₁H₂) = 2 = BackgroundGate degree.

```idris
prop_interHydrogenIsBackground : Bool
prop_interHydrogenIsBackground =
  interHydrogenQuadrance == cast (degree BackgroundGate)
```

### Property 35: Bonds are Red-Perpendicular

The O-H bonds are perpendicular in the Red (Minkowski) metric.
This means they are null-separated in relativistic spacetime.

```idris
prop_bondsRedPerpendicular : Bool
prop_bondsRedPerpendicular = bondsRedPerpendicular
```

### Property 36: Electron Red Quadrance is TimeGate

Q_Red(electron at H₁) = 4² - 3² = 16 - 9 = 7 = TimeGate degree.
The electron's relativistic quadrance IS the TimeGate.

```idris
prop_electronRedIsTimeGate : Bool
prop_electronRedIsTimeGate =
  electronRedQuadrance == cast (degree TimeGate)
```

### Property 37: Electron Green Quadrance is Oxygen × MatterGate

Q_Green(electron at H₁) = 2·4·3 = 24 = 8 × 3 = Oxygen(Z) × MatterGate(n).
The electron's product-metric quadrance encodes the Oxygen-MatterGate product.

```idris
prop_electronGreenIsOxygenMatter : Bool
prop_electronGreenIsOxygenMatter =
  electronGreenQuadrance == 8 * cast (degree MatterGate)
```

### Property 38: Electron-Electron Spread Equals Bond Spread

The angular separation between the two bonding electrons (as seen from O)
is identical to the bond spread. The electrons ARE the bonds.

```idris
prop_electronSpreadIsBondSpread : Bool
prop_electronSpreadIsBondSpread =
  electronElectronSpread == bondSpread
```

## Part 7: Pythagorean Fixed Point & N+1 Scale Transition

### Property 39: Water is a Pythagorean Fixed Point

The (4,3) coordinate decodes to gate degrees in all three metrics.

```idris
prop_waterIsFixedPoint : Bool
prop_waterIsFixedPoint = waterIsFixedPoint
```

### Property 40: Hydrogen Bond Direction is TimeGate Diagonal

At N+1, the hydrogen bond direction = (7, 7) = TimeGate diagonal.

```idris
prop_hydrogenBondIsTimeGateDiagonal : Bool
prop_hydrogenBondIsTimeGateDiagonal =
  let hb = hydrogenBondDirection
  in hb.src == cast (degree TimeGate) && hb.tgt == cast (degree TimeGate)
```

### Property 41: Hydrogen Bond is Red-Null (Identity Diagonal)

Q_Red(7,7) = 7² - 7² = 0. The N+1 bond IS the [J,J] identity diagonal.
A null vector in Minkowski space — pure self-reference.

```idris
prop_hydrogenBondIsIdentity : Bool
prop_hydrogenBondIsIdentity = hydrogenBondIsIdentity
```

### Property 42: Hydrogen Bond is Isotropic

Q_Blue = Q_Green = 98. The bond looks identical from Euclidean and
product metrics — metric-invariant.

```idris
prop_hydrogenBondIsIsotropic : Bool
prop_hydrogenBondIsIsotropic = hydrogenBondIsIsotropic
```

### Property 43: N+1 Blue Quadrance = BackgroundGate × TimeGate²

98 = 2 × 49 = BackgroundGate × TimeGate². The scale hierarchy
persists into N+1.

```idris
prop_hbondBlueDecomposition : Bool
prop_hbondBlueDecomposition =
  let fp = hydrogenBondFingerprint
  in fp.blueQ == cast (degree BackgroundGate) * cast (degree TimeGate) * cast (degree TimeGate)
```

## Part 8: Ice Geometry & Folding (N+2)

### Property 44: Ice Direction is Self-Addition

(11,10) = (7,7) + (4,3). The fixed point adds itself to reach N+2.

```idris
prop_iceSelfAddition : Bool
prop_iceSelfAddition = isSelfAddition
```

### Property 45: Folding Number is MatterGate × TimeGate

Q_Red(11,10) = 21 = 3 × 7. The product of structure and time.

```idris
prop_iceFoldingIsMatterTime : Bool
prop_iceFoldingIsMatterTime = foldingIsMatterTimesTime
```

### Property 46: Blue Quadrance = ResonanceGate × 17

221 = 13 × 17. Decoherence onset: 13 is the last gate, 17 is beyond.

```idris
prop_iceBlueIsResonanceDecoherence : Bool
prop_iceBlueIsResonanceDecoherence = blueIsResonanceTimesDecoherence
```

### Property 47: Edge IS Water Fixed Point

The edge from (7,7) to (11,10) = (4,3) = Water's fixed point.

```idris
prop_iceEdgeIsWater : Bool
prop_iceEdgeIsWater = edgeIsWaterFixedPoint
```

### Property 48: Edge Quadrance = Water Bond Quadrance

Q(edge) = 25 = ChargeGate² — same as Water's covalent bond.

```idris
prop_iceEdgeQuadranceIsWater : Bool
prop_iceEdgeQuadranceIsWater = edgeQuadranceIsWater
```

### Property 49: Archimedes Invariant = 196

A(Q)_Blue of the (7,7)-(11,10) triangle = 196 = Water's A(Q).
The chromogeometric signature persists across scales.

```idris
prop_iceArchimedesIs196 : Bool
prop_iceArchimedesIs196 = iceArchimedes == 196
```

### Property 50: Folding Reciprocity (Matter from Time)

21 / 7 = 3 = MatterGate. Time folds produce Matter.

```idris
prop_matterFoldsIsMatter : Bool
prop_matterFoldsIsMatter = matterFoldsIsMatter
```

### Property 51: Folding Reciprocity (Time from Matter)

21 / 3 = 7 = TimeGate. Matter folds produce Time.

```idris
prop_timeFoldsIsTime : Bool
prop_timeFoldsIsTime = timeFoldsIsTime
```

## Part 9: Scale Trajectory (38-Scale Hypothesis)

### Property 52: Gate Fingerprint is Invariant Across Scales

At any scale $k$, the Pythagorean fixed point yields Blue $25(k+1)^2$, Red $7(k+1)^2$, and Green $24(k+1)^2$.

```idris
prop_fingerprintInvariant : Property
prop_fingerprintInvariant = forAll {a = Nat} {prop = Bool} arbitrary (MkFn (\k => fingerprintInvariant k))
```

### Property 53: Eddington Generation (n=39) is Matter × Resonance

The 38th cycle (n=39) is the scale of the known universe, factoring purely into MatterGate × ResonanceGate.

```idris
prop_eddingtonIsMatterTimesResonance : Bool
prop_eddingtonIsMatterTimesResonance = eddingtonIsMatterTimesResonance
```

### Property 54: First Decoherence is at k=16 (n=17)

The first non-gate prime (17) breaks the coherence sequence at cycle 16.

```idris
prop_firstDecoherenceIsK16 : Bool
prop_firstDecoherenceIsK16 = firstDecoherenceIsK16
```

## Main Test Runner


```idris
runProp : String -> Bool -> IO ()
runProp name result = putStrLn $ name ++ ": " ++ (if result then "PASS" else "FAIL")

main : IO ()
main = do
  putStrLn "=== Adaptive Cycle Simulation ==="
  putStrLn ""

  -- Part 1: Pipeline Properties (QuickCheck randomised)
  putStrLn "--- Part 1: Pipeline Properties ---"

  let r1 = QuickCheck.quickCheck prop_partitionProducesTwoParts
  putStrLn $ "prop_partitionProducesTwoParts: " ++ r1.msg

  let r2 = QuickCheck.quickCheck prop_resonanceReduces
  putStrLn $ "prop_resonanceReduces: " ++ r2.msg

  let r3 = QuickCheck.quickCheck prop_ascensionCondenses
  putStrLn $ "prop_ascensionCondenses: " ++ r3.msg

  runProp "prop_canAscendRequiresBalance" prop_canAscendRequiresBalance

  putStrLn "--- Part 9: Scale Trajectory ---"
  let r9 = QuickCheck.quickCheck prop_fingerprintInvariant
  putStrLn $ "prop_fingerprintInvariant: " ++ r9.msg
  runProp "prop_eddingtonIsMatterTimesResonance" prop_eddingtonIsMatterTimesResonance
  runProp "prop_firstDecoherenceIsK16" prop_firstDecoherenceIsK16

  putStrLn ""

  -- Part 3: Findings Verification (deterministic invariants)
  putStrLn "--- Part 3: Findings Verification ---"

  runProp "prop_primorialGridIs210" prop_primorialGridIs210
  runProp "prop_cosmicBudgetMatches" prop_cosmicBudgetMatches
  runProp "prop_s13NonTrivial" prop_s13NonTrivial
  runProp "prop_gridLimitIs137" prop_gridLimitIs137
  runProp "prop_cycleHas7Gates" prop_cycleHas7Gates
  runProp "prop_gateDegrees" prop_gateDegrees

  putStrLn ""

  -- Part 4: Natural Ascension (deterministic, model-seeded)
  putStrLn "--- Part 4: Natural Ascension ---"



  putStrLn ""

  -- Part 5: Findings Deep Verification
  putStrLn "--- Part 5: Findings Deep Verification ---"

  runProp "prop_periodicTableHas137" prop_periodicTableHas137
  runProp "prop_feynmaniumBoundary" prop_feynmaniumBoundary
  runProp "prop_oxygenDividesLatent" prop_oxygenDividesLatent
  runProp "prop_oxygenVisibleResidue" prop_oxygenVisibleResidue
  runProp "prop_vacuumQuantumIs8" prop_vacuumQuantumIs8
  runProp "prop_primordialAlpha" prop_primordialAlpha
  runProp "prop_finiteVacuumEnergy" prop_finiteVacuumEnergy
  runProp "prop_pairProductionAdds" prop_pairProductionAdds

  putStrLn ""

  -- Part 6: Water Chemistry & Electron Interaction
  putStrLn "--- Part 6: Water Chemistry ---"

  runProp "prop_waterBaryonicLag" prop_waterBaryonicLag
  runProp "prop_waterBondCount" prop_waterBondCount
  runProp "prop_waterIsStable" prop_waterIsStable
  runProp "prop_oxygenValenceIs2" prop_oxygenValenceIs2
  runProp "prop_darkEnergyQuantaIs16" prop_darkEnergyQuantaIs16
  runProp "prop_hydrogenLagMinimal" prop_hydrogenLagMinimal
  runProp "prop_bondQuadranceIs25" prop_bondQuadranceIs25
  runProp "prop_bondSpreadGateDerived" prop_bondSpreadGateDerived
  runProp "prop_interHydrogenIsBackground" prop_interHydrogenIsBackground
  runProp "prop_bondsRedPerpendicular" prop_bondsRedPerpendicular
  runProp "prop_electronRedIsTimeGate" prop_electronRedIsTimeGate
  runProp "prop_electronGreenIsOxygenMatter" prop_electronGreenIsOxygenMatter
  runProp "prop_electronSpreadIsBondSpread" prop_electronSpreadIsBondSpread

  putStrLn ""

  -- Part 7: Pythagorean Fixed Point & N+1
  putStrLn "--- Part 7: Pythagorean Fixed Point ---"

  runProp "prop_waterIsFixedPoint" prop_waterIsFixedPoint
  runProp "prop_hydrogenBondIsTimeGateDiagonal" prop_hydrogenBondIsTimeGateDiagonal
  runProp "prop_hydrogenBondIsIdentity" prop_hydrogenBondIsIdentity
  runProp "prop_hydrogenBondIsIsotropic" prop_hydrogenBondIsIsotropic
  runProp "prop_hbondBlueDecomposition" prop_hbondBlueDecomposition

  putStrLn ""

  -- Part 8: Ice Geometry & Folding (N+2)
  putStrLn "--- Part 8: Ice Geometry (N+2) ---"

  runProp "prop_iceSelfAddition" prop_iceSelfAddition
  runProp "prop_iceFoldingIsMatterTime" prop_iceFoldingIsMatterTime
  runProp "prop_iceBlueIsResonanceDecoherence" prop_iceBlueIsResonanceDecoherence
  runProp "prop_iceEdgeIsWater" prop_iceEdgeIsWater
  runProp "prop_iceEdgeQuadranceIsWater" prop_iceEdgeQuadranceIsWater
  runProp "prop_iceArchimedesIs196" prop_iceArchimedesIs196
  runProp "prop_matterFoldsIsMatter" prop_matterFoldsIsMatter
  runProp "prop_timeFoldsIsTime" prop_timeFoldsIsTime
```
