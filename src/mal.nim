
import logger
import linenoise
import reader
import printer
import MalTypes


proc read(str: string): MalData =
  reader.readStr(str)

proc eval(str: MalData): MalData =
  str

proc print(str: MalData): string =
  printer.pr_str(str)

proc rep(str: string): string =
  return str.read.eval.print


when isMainModule:
  while true:
    let line = linenoise("user> ")
    if line == nil:
      break
    if line.len != 0:
      linenoiseHistoryAdd(line)
      try:
        echo rep($line)
      except EOFError:
        echo "Error: EOF"
      linenoiseFree(line)
