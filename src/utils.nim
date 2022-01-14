import MalTypes

proc isValidCatchExpr*(catchExpr: MalData): bool =
  catchExpr.dataType.isListLike and
    catchExpr.items.len == 3 and
    catchExpr.items[0].isCatchSym and
    catchExpr.items[1].isSym


proc invokeCallable*(fun: MalData, args: seq[MalData]): MalData =
  let fn = case fun.dataType
    of Function: fun.fun
    of Lambda: fun.expression
    else: raise newException(ValueError, "map operations needs to be a function")
  return fn(args)

template MalCoreFunction*(symName: string, body: untyped) =
  var thisProc = proc(args {.inject.}: varargs[MalData]): MalData =
    body

  preludeFunctions[symName.newSymbol] = MalData(dataType: Function, fun: thisProc)


