import std/strformat
import std/tables
import std/sequtils
import std/strutils
import std/sugar
import std/sets
import std/options
import std/times
import std/algorithm
import linenoise
import stringUtils
import reader
import MalTypes
import printer
import boolUtils
import utils


var preludeFunctions = initTable[MalData, MalData]()
proc getPreludeFunction*(): Table[MalData, MalData] = preludeFunctions


MalCoreFunction "+":
    result = MalData(dataType: Digit, digit: 0)

    for arg in args:
        if arg.dataType != Digit:
            raise newException(ValueError, "add not supported for non-digit types")
        result.digit += arg.digit


MalCoreFunction "*":
    result = MalData(dataType: Digit, digit: 1)

    for arg in args:
        if arg.dataType != Digit:
            raise newException(ValueError, "mul not supported for non-digit types")
        result.digit *= arg.digit


MalCoreFunction "-":
    result = MalData(dataType: Digit)

    for i, arg in args:
        if arg.dataType != Digit:
            raise newException(ValueError, "sub not supported for non-digit types")
        if i == 0: result.digit = arg.digit
        else: result.digit -= arg.digit


MalCoreFunction "/":
    result = MalData(dataType: Digit)

    for i, arg in args:
        if arg.dataType != Digit:
            raise newException(ValueError, "div not supported for non-digit types")
        if i != 0 and arg.digit == 0:
            raise newException(ValueError, "division by zero")

        if i == 0: result.digit = arg.digit
        else: result.digit = int(result.digit/arg.digit)


MalCoreFunction "=":
    if args.len != 2:
        raise newException(ValueError, fmt"incorrect number of args to `=`, expcted 2, found {args.len}")

    return MalData(dataType: Boolean, value: args[0] == args[1])


MalCoreFunction "list":
    return args.toSeq.toList


MalCoreFunction "list?":
    return newMalBool(args[0].dataType == List)


MalCoreFunction "empty?":
    if args.len != 1:
        raise newException(ValueError, fmt"incorrect number of args to `empty?`, expcted 1, found {args.len}")

    if not args[0].dataType.isListLike:
        raise newException(ValueError, fmt"incorrect data to `empty?`, expcted `List/Vector`, found {args[0].dataType}")

    return MalData(dataType: Boolean, value: args[0].items.len == 0)


MalCoreFunction "count":
    if args.len != 1:
        raise newException(ValueError, fmt"incorrect number of args to `count`, expcted 1, found {args.len}")

    if args[0].dataType.isListLike:
        return MalData(dataType: Digit, digit: args[0].items.len)
    elif args[0].dataType == Nil:
        return MalData(dataType: Digit, digit: 0)

    raise newException(ValueError, fmt"incorrect data to `count`, expcted `List/Nil`, found {args[0].dataType}")


MalCoreFunction "<":
    if args.len != 2:
        raise newException(ValueError, fmt"incorrect number of args to `<`, expcted 2, found {args.len}")

    if args[0].dataType != Digit or args[1].dataType != Digit:
        raise newException(ValueError, fmt"incorrect data, expcted `Digit`, found ({args[0].dataType}, {args[1].dataType})")

    return newMalBool(args[0].digit < args[1].digit)


MalCoreFunction "<=":
    if args.len != 2:
        raise newException(ValueError, fmt"incorrect number of args to `<=`, expcted 2, found {args.len}")

    if args[0].dataType != Digit or args[1].dataType != Digit:
        raise newException(ValueError, fmt"incorrect data, expcted `Digit`, found {args[0].dataType}, {args[1].dataType}")

    return newMalBool(args[0].digit <= args[1].digit)


MalCoreFunction ">":
    if args.len != 2:
        raise newException(ValueError, fmt"incorrect number of args to `>`, expcted 2, found {args.len}")

    if args[0].dataType != Digit or args[1].dataType != Digit:
        raise newException(ValueError, fmt"incorrect data, expcted `Digit`, found ({args[0].dataType}, {args[1].dataType})")

    return newMalBool(args[0].digit > args[1].digit)


MalCoreFunction ">=":
    if args.len != 2:
        raise newException(ValueError, fmt"incorrect number of args to `>=`, expcted 2, found {args.len}")

    if args[0].dataType != Digit or args[1].dataType != Digit:
        raise newException(ValueError, fmt"incorrect data, expcted `Digit`, found ({args[0].dataType}, {args[1].dataType})")

    return newMalBool(args[0].digit >= args[1].digit)


MalCoreFunction "pr-str":
    let str = args.mapIt(it.pr_str(true)).join(" ")
    return str.newString


MalCoreFunction "str":
    args.mapIt(it.pr_str(false)).join("").newString


MalCoreFunction "prn":
    let fnstr = args.mapIt(it.pr_str(true)).join(" ")
    echo fnstr
    return newMalNil()


MalCoreFunction "println":
    let fnstr = args.mapIt(it.pr_str(false)).join(" ")
    echo fnstr
    return newMalNil()


MalCoreFunction "read-string":
    let str = args[0].str
    return str.readStr


MalCoreFunction "slurp":
    let filename = args[0].str
    return filename.readFile.newString


MalCoreFunction "atom":
    if args.len != 1:
        raise newException(ValueError, "only one value allowed for `atom`")

    return MalData(dataType: Atom, reference: args[0])


MalCoreFunction "atom?":
    if args.len != 1:
        raise newException(ValueError, "only one value allowed for `atom?`")
    return newMalBool(args[0].dataType == Atom)


MalCoreFunction "deref":
    if args.len != 1:
        raise newException(ValueError, "only one value allowed for `atom?`")
    if args[0].dataType != Atom:
        raise newException(ValueError, "argument should be atom type for `deref`")

    return args[0].reference


MalCoreFunction "reset!":
    if args.len != 2:
        raise newException(ValueError, "only 2 arguments allowed for `reset!`")
    if args[0].dataType != Atom:
        raise newException(ValueError, "first argument should be atom type for `deref`")

    args[0].reference = args[1]
    return args[1]


MalCoreFunction "swap!":
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


MalCoreFunction "cons":
    if args.len != 2:
        raise newException(ValueError, "exact 2 arguments required for `cons`")
    if not args[1].dataType.isListLike:
        raise newException(ValueError, "second argument should be list/vector type for `map`")

    let newItems = @[args[0]] & args[1].items

    return MalData(dataType: List, items: newItems)


MalCoreFunction "concat":
    var newItems: seq[MalData] = @[]

    for arg in args:
        if not arg.dataType.isListLike:
            raise newException(ValueError, "arguments should be list/vector type for `concat`")
        newItems &= arg.items

    return MalData(dataType: List, items: newItems)


MalCoreFunction "vec":
    if args.len == 0:
        raise newException(ValueError, "insufficient args to `vec`")

    let arg = args[0]

    if arg.dataType == Vector:
        return arg

    if arg.dataType == List:
        return MalData(dataType: Vector, items: arg.items)

    raise newException(ValueError, "Vector/List type required for `vec`")


MalCoreFunction "nth":
    if args.len != 2:
        raise newException(ValueError, fmt"required 2 args to `nth`, found {args.len}")
    if not args[0].dataType.isListLike:
        raise newException(ValueError, fmt"first argument to `nth` should be a list")
    if args[1].dataType != Digit:
        raise newException(ValueError, fmt"second argument to `nth` should be a digit")

    let n = args[1].digit
    let lst = args[0].items

    if lst.len <= n:
        raise newException(ValueError, "index out of range")

    return lst[n]


MalCoreFunction "first":
    if args.len != 1:
        raise newException(ValueError, fmt"required 1 arg to `first`, found {args.len}")
    if args[0].dataType == Nil:
        return newMalNil()
    if not args[0].dataType.isListLike:
        raise newException(ValueError, fmt"first argument to `first` should be a list")
    if args[0].items.len == 0:
        return newMalNil()

    return args[0].items[0]


MalCoreFunction "rest":
    if args.len != 1:
        raise newException(ValueError, fmt"required 1 arg to `rest`, found {args.len}")
    if args[0].dataType == Nil:
        return @[].toList
    if not args[0].dataType.isListLike:
        raise newException(ValueError, fmt"first argument to `rest` should be a list")
    if args[0].items.len == 0:
        return @[].toList

    return args[0].items[1..^1].toList


MalCoreFunction "throw":
    if args.len != 1:
        raise newException(ValueError, fmt"required 1 arg to `rest`, found {args.len}")

    raise MalException(malObj: args[0])


MalCoreFunction "nil?":
    if args.len != 1:
        raise newException(ValueError, fmt"required 1 arg, found {args.len}")

    return newMalBool(args[0].dataType == Nil)


MalCoreFunction "true?":
    if args.len != 1:
        raise newException(ValueError, fmt"required 1 arg, found {args.len}")

    return newMalBool(args[0].isMalTrue)


MalCoreFunction "false?":
    if args.len != 1:
        raise newException(ValueError, fmt"required 1 arg, found {args.len}")

    return newMalBool(args[0].isMalFalse)


MalCoreFunction "symbol?":
    if args.len != 1:
        raise newException(ValueError, fmt"required 1 arg, found {args.len}")

    return newMalBool(args[0].isSym)


MalCoreFunction "map":
    if args.len != 2:
        raise newException(ValueError, "exact 2 arguments required for `map`")
    if not args[0].dataType.isCallable:
        raise newException(ValueError, "first argument should be function type for `map`")
    if not args[1].dataType.isListLike:
        raise newException(ValueError, "second argument should be list/vector type for `map`")

    let newItems = collect:
        for i in args[1].items:
            args[0].invokeCallable(@[i])

    return MalData(dataType: List, items: newItems)


MalCoreFunction "apply":
    if args.len < 2:
        raise newException(ValueError, fmt"required atleast 2 arg, found {args.len}")

    if not args[0].dataType.isCallable:
        raise newException(ValueError, "first argument should be function type for `apply`")

    if not args[^1].dataType.isListLike:
        raise newException(ValueError, "last argument should be list/vector type for `apply`")

    let funArgs = if args.len == 2: args[^1].items else: args[1..^2].concat(
            args[^1].items)
    return args[0].invokeCallable(funArgs)


MalCoreFunction "symbol":
    return args[0].str.newSymbol


MalCoreFunction "keyword":
    if $args[0].str[0] == KEYWORD_PREFIX: return args[0]
    else: return (KEYWORD_PREFIX & args[0].str).newString


MalCoreFunction "keyword?":
    return newMalBool(args[0].dataType == String and args[0].str.len != 0 and
            $args[0].str[0] == KEYWORD_PREFIX)


MalCoreFunction "vector":
    return MalData(dataType: Vector, items: args.toSeq)


MalCoreFunction "vector?":
    return newMalBool(args[0].dataType == Vector)


MalCoreFunction "sequential?":
    return newMalBool(args[0].dataType.isListLike)


MalCoreFunction "map?":
    return newMalBool(args[0].dataType == HashMap)


MalCoreFunction "hash-map":
    if args.len mod 2 != 0:
        raise newException(ValueError, "even number of args required for `hash-map`")

    var map = initOrderedTable[MalData, MalData]()
    var i = 0
    while i < args.len:
        map[args[i]] = args[i+1]
        i += 2

    return MalData(dataType: HashMap, map: map)


MalCoreFunction "contains?":
    return newMalBool(args[0].map.contains(args[1]))


MalCoreFunction "keys":
    return args[0].map.keys.toSeq.toList


MalCoreFunction "vals":
    return args[0].map.values.toSeq.toList


MalCoreFunction "get":
    if args[0].dataType == Nil: return newMalNil()
    return args[0].map.getOrDefault(args[1], newMalNil())


MalCoreFunction "dissoc":
    var map = initOrderedTable[MalData, MalData]()
    let oldKeys = args[0].map.keys.toSeq
    let ignoreKeys = args[1..^1].toHashSet

    for oldKey in oldKeys:
        if not ignoreKeys.contains(oldKey):
            map[oldKey] = args[0].map[oldKey]

    return MalData(dataType: HashMap, map: map)


MalCoreFunction "assoc":
    var map = initOrderedTable[MalData, MalData]()
    for (key, val) in args[0].map.pairs:
        map[key] = val

    let dataList = args[1..^1]
    var i = 0
    while i < dataList.len:
        map[dataList[i]] = dataList[i+1]
        i += 2

    return MalData(dataType: HashMap, map: map)


MalCoreFunction "readline":
    let prompt = args[0].str
    let inputLine = getInputLine(prompt)
    if inputLine.isNone: return newMalNil()
    return inputLine.get.newString


MalCoreFunction "string?":
    return newMalBool(args[0].dataType == String and (not args[0].isKeyword))


MalCoreFunction "number?":
    return newMalBool(args[0].dataType == Digit)


MalCoreFunction "fn?":
    return newMalBool(args[0].dataType.isCallable and (not args[0].isMalMacro))


MalCoreFunction "macro?":
    return newMalBool(args[0].isMalMacro)


MalCoreFunction "seq":
    let arg = args[0]
    case arg.dataType
    of List, Vector:
        if arg.items.len == 0: return newMalNil()
        return arg.items.toList
    of String:
        if arg.str.len == 0: return newMalNil()
        return arg.str.mapIt(($it).newString).toList
    of Nil:
        return newMalNil()
    else:
        raise newException(ValueError, "wrong type to seq")


MalCoreFunction "conj":
    if args.len < 2:
        raise newException(ValueError, "not enough args to conj")

    case args[0].dataType
    of List:
        return toList(args[1..^1].reversed.concat args[0].items)
    of Vector:
        return toVector(args[0].items.concat args[1..^1])
    else:
        raise newException(ValueError, "first argument to conj needs to to list/vector")


MalCoreFunction "time-ms":
    return MalData(dataType: Digit, digit: int(epochTime() * 1000))


MalCoreFunction "meta":
    case args[0].dataType:
        of List, Vector, HashMap, Function, Lambda:
            if args[0].metadata.isNil: return newMalNil()
            return args[0].metadata
        else:
            raise newException(ValueError,
                    fmt"metadata for support for {args[0].dataType}")


MalCoreFunction "with-meta":
    case args[0].dataType:
        of List, Vector, HashMap, Function, Lambda:
            if args.len > 1:
                var newData = deepCopy(args[0])
                newData.metadata = args[1]
                return newData
        else:
            raise newException(ValueError,
                    fmt"metadata for support for {args[0].dataType}")



