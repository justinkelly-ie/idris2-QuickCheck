module Tests

import System
import Test.Golden.RunnerHelper

main : IO ()
main = goldenRunner
  [ "Engine Verification" `atDir` "properties"
  , "Double Slit Interference" `atDir` "properties"
  , "Adaptive Cycle" `atDir` "properties"
  ]

