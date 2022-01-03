import std/strformat

proc raiseEOF*() =
  raise newException(EOFError, "reached end of input.")

proc raiseNotFoundError*(val: string) =
    raise newException(EOFError, fmt"`{val}` not found")

