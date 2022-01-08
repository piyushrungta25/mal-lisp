import std/logging
import std/strformat
import std/options
import logger
import linenoise
import reader
import printer
import evaluator
import env
import MalTypes


proc read(str: string): MalData =
  reader.readStr(str)

proc eval(str: MalData, env: var ReplEnv): MalData =
  evaluator.eval(str, env)

proc print(str: MalData): string =
  printer.pr_str(str)

proc rep(str: string, prelude: var ReplEnv): string =
  return str.read.eval(prelude).print

proc registerSelfHostedFunctions(prelude: var ReplEnv) =
  let functions = @[
    "(def! not (fn* (a) (if a false true)))",
    "(def! factorial (fn* (a) (if (= a 1) 1 (* (factorial (- a 1)) a) )))",
    """(def! load-file (fn* (f) (eval (read-string (str "(do " (slurp f) "\nnil)")))))"""
  ]

  for fun in functions:
    discard fun.rep(prelude)


# required to satisfy the GC
proc envClosure(env: ReplEnv): MalEnvFunctions =
  var envirn = env
  return proc(ast: varargs[MalData]): MalData = eval(ast[0], envirn)


proc registerEval(prelude: var ReplEnv) =
  prelude.set(newSymbol("eval"), MalData(dataType: Function, fun: envClosure(prelude)))


when isMainModule:
  var prelude = getPrelude()
  prelude.registerSelfHostedFunctions
  prelude.registerEval


  while true:
    let inputLine = getInputLine()
    if inputLine.isNone: break

    try:
      echo rep(inputLine.get, prelude)
    except Exception as e:
      echo fmt"[ERROR] {e.msg}"
