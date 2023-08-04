import Mathlib.Control.Random

@[export my_char]
def myChar (s : String) : BaseIO Char := do
  let i ← IO.runRand do Random.randFin (n := s.length)
  return s.iter.nextn i.val |>.curr
