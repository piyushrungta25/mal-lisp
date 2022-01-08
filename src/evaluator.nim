import std/strformat
import std/tables
import std/sequtils
import std/options
import std/logging
import MalTypes
import boolUtils
import env


proc eval*(ast: MalData, replEnv: var ReplEnv): MalData
proc evalAst(ast: MalData, replEnv: var ReplEnv): MalData


proc createEnvBindings(replEnv: var ReplEnv, bindings: MalData) =
    let bindingList = case bindings.dataType
        of List, Vector: bindings.items
        else: raise newException(ValueError, fmt"malfolmed `let*` expression." &
            "expected bindings to be a list or vector, found `{$bindings.dataType}`")

    if bindingList.len mod 2 != 0:
        raise newException(ValueError, "odd number of values found in bind list")

    var i = 0
    while i < bindingList.len:
        replEnv.set(bindingList[i], eval(bindingList[i+1], replEnv))
        i += 2


proc applyDef(args: seq[MalData], replEnv: var ReplEnv): MalData =
    if args.len != 2:
        raise newException(ValueError, fmt"malfolmed `def!` expression." &
            "Expected `2` arguments, found `{args.len}`")
    result = eval(args[1], replEnv)
    replEnv.set(args[0], result)


proc applyLet(bindings: MalData, exprsn: MalData, replEnv: var ReplEnv): (ReplEnv, MalData) =
    var ne = newEnv(some(replEnv))
    createEnvBindings(ne, bindings)
    return (ne, exprsn)


proc applyList(ast: MalData, replEnv: var ReplEnv): MalData =
    var evaled = evalAst(ast, replEnv)
    let envVal: MalData = evaled.items[0]
    assert envVal.dataType == Function

    return envVal.fun(evaled.items[1..^1])


proc applyDo(args: seq[MalData], replEnv: var ReplEnv): (ReplEnv, MalData) =
  if args.len == 0:
    raise newException(ValueError, "not enough args to `do`")

  var i: int
  while i < (args.len - 1):
    discard args[i].eval(replEnv)
    inc i

  return (replEnv, args[^1])


proc applyIf(args: seq[MalData], replEnv: var ReplEnv): (ReplEnv, MalData) =
    if args.len == 0:
        raise newException(ValueError, "not enough args to `if`")

    let predicate = args[0].eval(replEnv)

    if predicate.isTruthy:
        return (replEnv, args[1])

    if args.len > 2:
        return (replEnv, args[2])

    return (replEnv, MalData(dataType: Nil))


proc applyFn(args: seq[MalData], replEnv: ReplEnv): MalData =
    let fnClosure = proc (exprs: varargs[MalData]): MalData =
        var closedEnv = newEnv(some(replEnv), args[0].items, exprs.toSeq)
        return eval(args[1], closedEnv)

    return MalData(dataType: Function, fun: fnClosure)


proc eval*(ast: MalData, replEnv: var ReplEnv): MalData =
  var ast = ast
  var replEnv = replEnv

  while true:
    if ast.dataType != List: return ast.evalAst(replEnv)
    elif ast.items.len == 0: return ast

    # non empty list type, apply all operations
    if ast.items[0].isDefSym:
      return applyDef(ast.items[1..^1], replEnv)
    elif ast.items[0].isLetSym:
      (replEnv, ast) = applyLet(ast.items[1], ast.items[2], replEnv)
    elif ast.items[0].isDoSym:
      (replEnv, ast) = applyDo(ast.items[1..^1], replEnv)
    elif ast.items[0].isIfSym:
       (replEnv, ast) = applyIf(ast.items[1..^1], replEnv)
    elif ast.items[0].isFnSym:
      return applyFn(ast.items[1..^1], replEnv)
    else:
      return applyList(ast, replEnv)


proc evalAst(ast: MalData, replEnv: var ReplEnv): MalData =
    case ast.dataType
        of Symbol:
            result = replEnv.get(ast)
        of List:
            result = MalData(dataType: List, items: ast.items.mapIt(eval(it, replEnv)))
        of Vector:
            result = MalData(dataType: Vector, items: ast.items.mapIt(eval(it, replEnv)))
        of HashMap:
            result = MalData(dataType: HashMap)
            for (k, v) in ast.map.pairs:
                result.map[eval(k, replEnv)] = eval(v, replEnv)
        else: return ast

