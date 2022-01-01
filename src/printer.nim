import MalTypes
import std/[strformat, sequtils, strutils]

proc unescape(str: string): string = 
  for c in str:
    if c == '\"':
      result &= "\\\""
    elif c == '\\':
      result &= "\\\\"
    elif c == char(10):
      result &= "\\n"
    else:
      result &= c


proc pr_str*(malData: MalData): string =
    case malData.dataType
        of Operator:
            result = $malData.operator
        of Digit:
            result = $malData.digit
        of String:
            result = "\"" & malData.str.unescape & "\""
        of Boolean:
            result = $malData.value
        of Nil:
            result = "nil"
        of Symbol:
            result = malData.symbol
        of List:
            result = fmt"({malData.data.map(pr_str).join($' ')})"
        of Vector:
            result = fmt"[{malData.items.map(pr_str).join($' ')}]"

                