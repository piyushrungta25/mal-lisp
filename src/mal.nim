import std/logging
import logger
import linenoise
import reader
import printer
import evaluator
import env
import MalTypes


proc read(str: string): MalData =
  reader.readStr(str)

proc eval(str: MalData, env: ReplEnv): MalData =
  evaluator.eval(str, env)

proc print(str: MalData): string =
  printer.pr_str(str)

proc rep(str: string): string =
  let prelude = getPrelude()
  return str.read.eval(prelude).print


when isMainModule:
  while true:
    let line = linenoise("user> ")
    if line == nil:
      break
    if line.len != 0:
      linenoiseHistoryAdd(line)
      try:
        echo rep($line)
      except Exception as e:
        error(e.msg)
      linenoiseFree(line)
