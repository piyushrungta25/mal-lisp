import std/[strformat, sequtils, strutils, sugar, tables, hashes]
import stringUtils


type
  MalEnvFunctions* = proc(args: varargs[MalData]): MalData

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


proc `$`*(malData: MalData): string =
  case malData.dataType
    of Digit:
      result = $malData.digit
    of String:
      if malData.str.len > 0 and $malData.str[0] == KEYWORD_PREFIX:
        result = ":" & malData.str[1..^1]
      else:
        result = "\"" & stringUtils.unescape(malData.str) & "\""
    of Boolean:
      result = $malData.value
    of Nil:
      result = "nil"
    of Symbol:
      result = malData.symbol
    of List:
      result = fmt"({malData.items.map(`$`).join($' ')})"
    of Vector:
      result = fmt"[{malData.items.map(`$`).join($' ')}]"
    of HashMap:
      let kvPairs = collect:
        for (k, v) in malData.map.pairs:
          $(k) & " " & $(v)
      result = "{" & kvPairs.join(" ") & "}"
    of Function:
      result = fmt"<fun at 0x{cast[int](malData.fun.rawProc):0x}>"


proc hash*(malData: MalData): Hash = hash($malData)
proc `==`*(d1, d2: MalData): bool = $d1 == $d2


proc newSymbol*(str: string): MalData =
  MalData(dataType: Symbol, symbol: str)

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

