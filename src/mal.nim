
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
    let line = linenoise("user> ")
    if line == nil:
      break
    if line.len != 0:
      linenoiseHistoryAdd(line)
      echo rep($line)
      linenoiseFree(line)
