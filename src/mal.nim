
import linenoise

proc read(str: string): string =
  str

proc eval(str: string): string =
  str

proc print(str: string): string =
  str

proc rep(str: string): string =
  return str.read.eval.print


when isMainModule:
  while true:
    let str = linenoise("user> ")
    if str == nil:
      break
    if str.len != 0:
      echo str







