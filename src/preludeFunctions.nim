import std/strformat
import std/tables
import std/sequtils
import std/strutils
import std/sugar
import reader
import MalTypes
import printer


proc addition(args: varargs[MalData]): MalData =
    result = MalData(dataType: Digit, digit: 0)

    for arg in args:
        if arg.dataType != Digit:
            raise newException(ValueError, "add not supported for non-digit types")
        result.digit += arg.digit


proc multiplication(args: varargs[MalData]): MalData =
    result = MalData(dataType: Digit, digit: 1)

    for arg in args:
        if arg.dataType != Digit:
            raise newException(ValueError, "mul not supported for non-digit types")
        result.digit *= arg.digit


proc subtraction(args: varargs[MalData]): MalData =
    result = MalData(dataType: Digit)

    for i, arg in args:
        if arg.dataType != Digit:
            raise newException(ValueError, "sub not supported for non-digit types")
        if i == 0: result.digit = arg.digit
        else: result.digit -= arg.digit


proc division(args: varargs[MalData]): MalData =
    result = MalData(dataType: Digit)

    for i, arg in args:
        if arg.dataType != Digit:
            raise newException(ValueError, "div not supported for non-digit types")
        if i != 0 and arg.digit == 0:
            raise newException(ValueError, "division by zero")

        if i == 0: result.digit = arg.digit
        else: result.digit = int(result.digit/arg.digit)


proc equality(args: varargs[MalData]): MalData =
    if args.len != 2:
        raise newException(ValueError, fmt"incorrect number of args to `=`, expcted 2, found {args.len}")

    return MalData(dataType: Boolean, value: args[0] == args[1])


proc list(args: varargs[MalData]): MalData =
    return MalData(dataType: List, items: args.toSeq)


proc isList(args: varargs[MalData]): MalData =
    return MalData(dataType: Boolean, value: args[0].dataType == List)


proc isEmpty(args: varargs[MalData]): MalData =
    if args.len != 1:
        raise newException(ValueError, fmt"incorrect number of args to `empty?`, expcted 1, found {args.len}")

    if not args[0].dataType.isListLike:
        raise newException(ValueError, fmt"incorrect data to `empty?`, expcted `List/Vector`, found {args[0].dataType}")

    return MalData(dataType: Boolean, value: args[0].items.len == 0)


proc count(args: varargs[MalData]): MalData =
    if args.len != 1:
        raise newException(ValueError, fmt"incorrect number of args to `count`, expcted 1, found {args.len}")

    if args[0].dataType.isListLike:
        return MalData(dataType: Digit, digit: args[0].items.len)
    elif args[0].dataType == Nil:
        return MalData(dataType: Digit, digit: 0)

    raise newException(ValueError, fmt"incorrect data to `count`, expcted `List/Nil`, found {args[0].dataType}")


proc lessThan(args: varargs[MalData]): Maldata =
    if args.len != 2:
        raise newException(ValueError, fmt"incorrect number of args to `<`, expcted 2, found {args.len}")

    if args[0].dataType != Digit or args[1].dataType != Digit:
        raise newException(ValueError, fmt"incorrect data, expcted `Digit`, found ({args[0].dataType}, {args[1].dataType})")

    let res = args[0].digit < args[1].digit
    return MalData(dataType: Boolean, value: res)


proc lessThanEquals(args: varargs[MalData]): Maldata =
    if args.len != 2:
        raise newException(ValueError, fmt"incorrect number of args to `<=`, expcted 2, found {args.len}")

    if args[0].dataType != Digit or args[1].dataType != Digit:
        raise newException(ValueError, fmt"incorrect data, expcted `Digit`, found {args[0].dataType}, {args[1].dataType}")

    let res = args[0].digit <= args[1].digit
    return MalData(dataType: Boolean, value: res)


proc greaterThan(args: varargs[MalData]): Maldata =
    if args.len != 2:
        raise newException(ValueError, fmt"incorrect number of args to `>`, expcted 2, found {args.len}")

    if args[0].dataType != Digit or args[1].dataType != Digit:
        raise newException(ValueError, fmt"incorrect data, expcted `Digit`, found ({args[0].dataType}, {args[1].dataType})")

    let res = args[0].digit > args[1].digit
    return MalData(dataType: Boolean, value: res)


proc greaterThanEquals(args: varargs[MalData]): Maldata =
    if args.len != 2:
        raise newException(ValueError, fmt"incorrect number of args to `>=`, expcted 2, found {args.len}")

    if args[0].dataType != Digit or args[1].dataType != Digit:
        raise newException(ValueError, fmt"incorrect data, expcted `Digit`, found ({args[0].dataType}, {args[1].dataType})")

    let res = args[0].digit >= args[1].digit
    return MalData(dataType: Boolean, value: res)


proc fn_pr_str(args: varargs[MalData]): MalData =
    let str = args.mapIt(it.pr_str(true)).join(" ")
    return MalData(dataType: String, str: str)


proc str(args: varargs[MalData]): MalData =
    let fnstr = args.mapIt(it.pr_str(false)).join("")
    return MalData(dataType: String, str: fnstr)


proc prn(args: varargs[MalData]): MalData =
    let fnstr = args.mapIt(it.pr_str(true)).join(" ")
    echo fnstr
    return MalData(dataType: Nil)


proc println(args: varargs[MalData]): MalData =
    let fnstr = args.mapIt(it.pr_str(false)).join(" ")
    echo fnstr
    return MalData(dataType: Nil)


proc read_string(args: varargs[MalData]): MalData =
    let str = args[0].str
    return str.readStr


proc slurp(args: varargs[MalData]): MalData =
    let filename = args[0].str
    return Maldata(dataType: String, str: filename.readFile)


proc makeAtom(args: varargs[MalData]): MalData =
    if args.len != 1:
        raise newException(ValueError, "only one value allowed for `atom`")

    return MalData(dataType: Atom, reference: args[0])


proc isAtom(args: varargs[MalData]): MalData =
    if args.len != 1:
        raise newException(ValueError, "only one value allowed for `atom?`")
    Maldata(dataType: Boolean, value: args[0].dataType == Atom)


proc atomDeref(args: varargs[MalData]): MalData =
    if args.len != 1:
        raise newException(ValueError, "only one value allowed for `atom?`")
    if args[0].dataType != Atom:
        raise newException(ValueError, "argument should be atom type for `deref`")

    return args[0].reference


proc atomReset(args: varargs[MalData]): MalData =
    if args.len != 2:
        raise newException(ValueError, "only 2 arguments allowed for `reset!`")
    if args[0].dataType != Atom:
        raise newException(ValueError, "first argument should be atom type for `deref`")

    args[0].reference = args[1]
    return args[1]


proc atomSwap(args: varargs[MalData]): MalData =
    if args.len < 2:
        raise newException(ValueError, "atleast 2 arguments allowed for `swap!`")
    if args[0].dataType != Atom:
        raise newException(ValueError, "first argument should be atom type for `swap!`")

    let data = args[0].reference
    let fn = case args[1].dataType
        of Function: args[1].fun
        of Lambda: args[1].fnClosure.fun
        else: raise newException(ValueError, "atom operations needs to be a function")
    let newData = fn(@[data] & args[2..^1])
    args[0].reference = newData
    return newData

proc mapListLike(args: varargs[MalData]): MalData =
    if args.len != 2:
        raise newException(ValueError, "exact 2 arguments required for `map`")
    if not args[0].dataType.isCallable:
        raise newException(ValueError, "first argument should be function type for `map`")
    if not args[1].dataType.isListLike:
        raise newException(ValueError, "second argument should be list/vector type for `map`")

    let newItems = collect:
        for i in args[1].items:
            # TODO: refactor this in a invokeCallable method
            let fn = case args[0].dataType
                of Function: args[0].fun
                of Lambda: args[0].fnClosure.fun
                else: raise newException(ValueError, "map operations needs to be a function")
            fn(@[i])

    return MalData(dataType: List, items: newItems)


proc cons(args: varargs[MalData]): MalData =
    if args.len != 2:
        raise newException(ValueError, "exact 2 arguments required for `cons`")
    if not args[1].dataType.isListLike:
        raise newException(ValueError, "second argument should be list/vector type for `map`")

    let newItems = @[args[0]] & args[1].items

    return MalData(dataType: List, items: newItems)


proc concat(args: varargs[MalData]): MalData =
    var newItems: seq[MalData] = @[]

    for arg in args:
      if not arg.dataType.isListLike:
        raise newException(ValueError, "arguments should be list/vector type for `concat`")
      newItems &= arg.items

    return MalData(dataType: List, items: newItems)


proc getPreludeFunction*(): Table[MalData, MalData] =
    {
      newSymbol("+"): MalData(dataType: Function, fun: addition),
      newSymbol("-"): MalData(dataType: Function, fun: subtraction),
      newSymbol("*"): MalData(dataType: Function, fun: multiplication),
      newSymbol("/"): MalData(dataType: Function, fun: division),
      newSymbol("="): MalData(dataType: Function, fun: equality),
      newSymbol("list"): MalData(dataType: Function, fun: list),
      newSymbol("list?"): MalData(dataType: Function, fun: isList),
      newSymbol("empty?"): MalData(dataType: Function, fun: isEmpty),
      newSymbol("count"): MalData(dataType: Function, fun: count),
      newSymbol(">"): MalData(dataType: Function, fun: greaterThan),
      newSymbol(">="): MalData(dataType: Function, fun: greaterThanEquals),
      newSymbol("<"): MalData(dataType: Function, fun: lessThan),
      newSymbol("<="): MalData(dataType: Function, fun: lessThanEquals),
      newSymbol("pr-str"): MalData(dataType: Function, fun: fn_pr_str),
      newSymbol("str"): MalData(dataType: Function, fun: str),
      newSymbol("prn"): MalData(dataType: Function, fun: prn),
      newSymbol("println"): MalData(dataType: Function, fun: println),
      newSymbol("read-string"): MalData(dataType: Function, fun: read_string),
      newSymbol("slurp"): MalData(dataType: Function, fun: slurp),
      newSymbol("atom"): MalData(dataType: Function, fun: makeAtom),
      newSymbol("atom?"): MalData(dataType: Function, fun: isAtom),
      newSymbol("deref"): MalData(dataType: Function, fun: atomDeref),
      newSymbol("swap!"): MalData(dataType: Function, fun: atomSwap),
      newSymbol("reset!"): MalData(dataType: Function, fun: atomReset),
      newSymbol("cons"): MalData(dataType: Function, fun: cons),
      newSymbol("concat"): MalData(dataType: Function, fun: concat),
      # off the books implementation
        newSymbol("map"): MalData(dataType: Function, fun: mapListLike),

    }.toTable

