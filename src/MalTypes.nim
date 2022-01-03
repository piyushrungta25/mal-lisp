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

  MalData* = ref object
    case dataType*: MalDataType
      of List:
        data*: seq[MalData]
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
      of Vector:
        items*: seq[MalData]
      of HashMap:
        map*: OrderedTable[MalData, MalData]


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
      result = fmt"({malData.data.map(`$`).join($' ')})"
    of Vector:
      result = fmt"[{malData.items.map(`$`).join($' ')}]"
    of HashMap:
      let kvPairs = collect:
        for (k, v) in malData.map.pairs:
          $(k) & " " & $(v)

      result = "{" & kvPairs.join(" ") & "}"



proc hash*(malData: MalData): Hash = hash($malData)
proc `==`*(d1, d2: MalData): bool = $d1 == $d2
