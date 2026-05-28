module Main

import Simplex.Core
import Evolution.Gate
import Physics.Scales.PythagoreanFixedPoint
import Physics.Scales.ScaleTrajectory

import Math.Multiset
import Math.IntPolynumber
import Math.SpreadPolynumber
import Math.Chromogeometry
import Data.List

%default covering

main : IO ()
main = do
  putStrLn "=== Full 137-Scale Trajectory ==="
  putStrLn ""

  putStrLn $ "  Grid wall: " ++ show gridWall
  putStrLn $ "  Observer epoch: k=" ++ show observerEpoch ++ " (n=" ++ show eddingtonGeneration ++ ")"
  putStrLn $ "  Eddington is coherent: " ++ show eddingtonIsCoherent
  putStrLn $ "  39 = 3 × 13: " ++ show eddingtonIsMatterTimesResonance
  putStrLn $ "  Gate-pure scales (of 137): " ++ show coherentScaleCount
  putStrLn $ "  Decoherent scales (of 137): " ++ show decoherentScaleCount
  putStrLn ""

  -- List all gate-pure generations 1..137
  putStrLn "--- Gate-Pure Generations (13-smooth numbers ≤ 138) ---"
  let allScales : List Nat = [0..136]
      pureGens = filter isCoherentGeneration allScales
      decoGens = filter (not . isCoherentGeneration) allScales
  traverse_ (\k => putStrLn $ "  k=" ++ show k ++ " n=" ++ show (cast {to=Integer} k + 1))
            pureGens
  
  putStrLn ""
  putStrLn $ "  Total gate-pure: " ++ show (length pureGens)
  
  putStrLn ""
  putStrLn "--- Decoherent Generations ---"
  traverse_ (\k => putStrLn $ "  k=" ++ show k ++ " n=" ++ show (cast {to=Integer} k + 1))
            decoGens
  
  putStrLn ""
  putStrLn $ "  Total decoherent: " ++ show (length decoGens)

  -- Check the grid wall itself
  putStrLn ""
  putStrLn "--- Grid Wall (k=136, n=137) ---"
  putStrLn $ "  137 is prime and NOT a gate prime"
  putStrLn $ "  isCoherent(136) = " ++ show (isCoherentGeneration 136)
  putStrLn $ "  The grid wall IS decoherence — 137 itself is the boundary"

  -- Check fingerprint invariance at a few key scales
  putStrLn ""
  putStrLn "--- Fingerprint Invariance Check ---"
  let checkInv : Nat -> IO ()
      checkInv k = putStrLn $ "  k=" ++ show k ++ " invariant: " ++ show (fingerprintInvariant k)
  traverse_ checkInv [0, 1, 10, 37, 38, 100, 136]

  -- What's k=137 (n=138 = 2×3×23)?
  putStrLn ""
  putStrLn "--- Beyond the Wall (k=137, n=138) ---"
  putStrLn $ "  138 = 2 × 3 × 23 → contains 23 (non-gate)"
  putStrLn $ "  isCoherent(137) = " ++ show (isCoherentGeneration 137)
  putStrLn $ "  Beyond 137 is decoherent — the grid cannot extend"
