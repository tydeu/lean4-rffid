import Lake
open System Lake DSL

package rffid

@[default_target]
lean_lib RFFID

require mathlib from git "https://github.com/leanprover-community/mathlib4"
  @ "526f38a054d7b1a95f9dd010190d7e77d60caee1"
