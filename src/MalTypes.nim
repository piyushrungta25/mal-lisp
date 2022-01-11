import std/[strformat, sequtils, strutils, sugar, tables, hashes, options]
import stringUtils


type
  MalEnvFunctions* = proc(args: varargs[MalData]): MalData

  ReplEnv* = ref object
    outer*: Option[ReplEnv]
    properties*: Table[MalData, MalData]

  MalDataType* = enum
    List
    Digit
    String
    Boolean
    Nil
    Symbol
    Vector
    HashMap
    Function
    Lambda
    Atom

  MalData* = ref object
    case dataType*: MalDataType
      of List, Vector:
        items*: seq[MalData]
      of Digit:
        digit*: int
      of String:
        str*: string
      of Boolean:
        value*: bool
      of Nil:
        discard
      of Symbol:
        symbol*: string
      of HashMap:
        map*: OrderedTable[MalData, MalData]
      of Function:
        fun*: MalEnvFunctions
      of Lambda:
        expression*: MalEnvFunctions
        fnBody*: MalData
        parameters*: seq[MalData]
        replEnv*: ReplEnv
        fnClosure*: MalData
      of Atom:
        reference*: MalData


proc toString*(malData: MalData, print_readably: bool = true): string =
  case malData.dataType
    of Digit:
      result = $malData.digit
    of String:
      if malData.str.len > 0 and $malData.str[0] == KEYWORD_PREFIX:
        result = ":" & malData.str[1..^1]
      else:
        if print_readably:
          result = "\"" & stringUtils.unescape(malData.str) & "\""
        else:
          result = malData.str
    of Boolean:
      result = $malData.value
    of Nil:
      result = "nil"
    of Symbol:
      result = malData.symbol
    of List:
      result = fmt"({malData.items.mapIt(it.toString(print_readably)).join($' ')})"
    of Vector:
      result = fmt"[{malData.items.mapIt(it.toString(print_readably)).join($' ')}]"
    of HashMap:
      let kvPairs = collect:
        for (k, v) in malData.map.pairs:
          k.toString(print_readably) & " " & v.toString(print_readably)
      result = "{" & kvPairs.join(" ") & "}"
    of Function:
      result = fmt"<fun at 0x{cast[int](malData.fun.rawProc):0x}>"
    of Lambda:
      result = fmt"<fun at 0x{cast[int](malData.expression.rawProc):0x}>"
    of Atom:
      result = fmt"(atom {malData.reference.toString})"

proc isListLike*(dataType: MalDataType): bool =
  dataType == List or dataType == Vector

proc isCallable*(dataType: MalDataType): bool =
  dataType == Function or dataType == Lambda

proc `$`*(malData: MalData): string = malData.toString
proc hash*(malData: MalData): Hash = hash($malData)


proc `==`*(d1, d2: MalData): bool =
  if d1.dataType.isListLike and d2.dataType.isListLike:
    return d1.items == d2.items

  if d1.dataType != d2.dataType: return false
  case d1.dataType:
    of Digit: result = d1.digit == d2.digit
    of String: result = d1.str == d2.str
    of Boolean: result = d1.value == d2.value
    of Nil: result = true
    of Symbol: result = d1.symbol == d2.symbol
    of Function: result = d1.fun.rawProc == d2.fun.rawProc
    of HashMap: result = d1.map == d2.map
    of Atom: result = d1.reference == d2.reference
    else: return d1.items == d2.items


proc newSymbol*(str: string): MalData =
  MalData(dataType: Symbol, symbol: str)

proc newString*(str: string): MalData =
  MalData(dataType: String, str: str)

proc isSym*(data: MalData): bool =
  data.dataType == Symbol

proc isDefSym*(data: MalData): bool =
  data.isSym and data.symbol == "def!"

proc isLetSym*(data: MalData): bool =
  data.isSym and data.symbol == "let*"

proc isDoSym*(data: MalData): bool =
  data.isSym and data.symbol == "do"

proc isIfSym*(data: MalData): bool =
  data.isSym and data.symbol == "if"

proc isFnSym*(data: MalData): bool =
  data.isSym and data.symbol == "fn*"

proc isVariadicMarkerSym*(data: MalData): bool =
  data.isSym and data.symbol == "&"

