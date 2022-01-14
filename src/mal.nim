import std/strformat
import std/options
import std/os
import std/sequtils
import linenoise
import reader
import printer
import evaluator
import env
import MalTypes

include logger

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
    """(def! load-file (fn* (f) (eval (read-string (str "(do " (slurp f) "\nnil)")))))""",
    """(defmacro! cond (fn* (& xs) (if (> (count xs) 0) (list 'if (first xs) (if (> (count xs) 1) (nth xs 1) (throw "odd number of forms to cond")) (cons 'cond (rest (rest xs)))))))""",
  ]

  for fun in functions:
    discard fun.rep(prelude)


# required to satisfy the GC
proc envClosure(env: ReplEnv): MalEnvFunctions =
  var envirn = env
  return proc(ast: varargs[MalData]): MalData = eval(ast[0], envirn)


proc registerEval(prelude: var ReplEnv) =
  prelude.set(newSymbol("eval"), MalData(dataType: Function, fun: envClosure(prelude)))


proc registerCmdArgs(prelude: var ReplEnv) =
  let params = commandLineParams()
  let items = if params.len > 1: params[1..^1].map(newString)
    else: @[]
  prelude.set(newSymbol("*ARGV*"), MalData(dataType: List, items: items))

when isMainModule:
  var prelude = getPrelude()
  prelude.registerSelfHostedFunctions
  prelude.registerEval
  prelude.registerCmdArgs


  if commandLineParams().len > 0:
    let programFileName = commandLineParams()[0]
    echo rep(fmt"""(load-file "{programFileName}")""", prelude)
    quit()



  while true:
    let inputLine = getInputLine()
    if inputLine.isNone: break

    try:
      echo rep(inputLine.get, prelude)
    except MalException as e:
      echo fmt"[ERROR] {e.malObj}"
    except Exception as e:
      echo fmt"[ERROR] {e.msg}"
