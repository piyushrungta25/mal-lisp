import MalTypes
import std/[strformat, sequtils, strutils, sugar, tables]

proc unescape(str: string): string =
  for c in str:
    if c == '\"':
      result &= "\\\""
    elif c == '\\':
      result &= "\\\\"
    elif c == NEW_LINE_CHAR:
      result &= "\\n"
    else:
      result &= c


proc pr_str*(malData: MalData): string =
  case malData.dataType
    of Digit:
      result = $malData.digit
    of String:
      if malData.str.len > 0 and $malData.str[0] == KEYWORD_PREFIX:
        result = ":" & malData.str[1..^1]
      else:
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
    of HashMap:
      let kvPairs = collect:
        for (k, v) in malData.map.pairs:
          pr_str(k) & " " & pr_str(v)

      result = "{" & kvPairs.join(" ") & "}"


