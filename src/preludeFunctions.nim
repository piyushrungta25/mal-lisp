import std/strformat
import std/tables
import std/sequtils
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

proc prn(args: varargs[MalData]): MalData =
    result = MalData(dataType: Nil)

    for arg in args:
        echo arg.pr_str


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

    if args[0].dataType != List:
        raise newException(ValueError, fmt"incorrect data to `empty?`, expcted `List`, found {args[0].dataType}")

    if args[0].items.len == 0:
        return MalData(dataType: Boolean, value: true)
    return MalData(dataType: Boolean, value: false)


proc count(args: varargs[MalData]): MalData =
    if args.len != 1:
        raise newException(ValueError, fmt"incorrect number of args to `count`, expcted 1, found {args.len}")

    if args[0].dataType == List:
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


proc getPreludeFunction*(): Table[MalData, MalData] =
    {
      newSymbol("+"): MalData(dataType: Function, fun: addition),
      newSymbol("-"): MalData(dataType: Function, fun: subtraction),
      newSymbol("*"): MalData(dataType: Function, fun: multiplication),
      newSymbol("/"): MalData(dataType: Function, fun: division),
      newSymbol("prn"): MalData(dataType: Function, fun: prn),
      newSymbol("="): MalData(dataType: Function, fun: equality),
      newSymbol("list"): MalData(dataType: Function, fun: list),
      newSymbol("list?"): MalData(dataType: Function, fun: isList),
      newSymbol("empty?"): MalData(dataType: Function, fun: isEmpty),
      newSymbol("count"): MalData(dataType: Function, fun: count),
      newSymbol(">"): MalData(dataType: Function, fun: greaterThan),
      newSymbol(">="): MalData(dataType: Function, fun: greaterThanEquals),
      newSymbol("<"): MalData(dataType: Function, fun: lessThan),
      newSymbol("<="): MalData(dataType: Function, fun: lessThanEquals),
    }.toTable

