
proc raiseEOF*() =
  raise newException(EOFError, "reached end of input.")
