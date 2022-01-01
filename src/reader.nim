import std/re
import std/sequtils
import std/strutils
import std/logging

import MalTypes

let regex = re"""[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"?|;.*|[^\s\[\]{}('"`,;)]*)"""

proc readForm(reader: var Reader): MalData


proc peek(reader: Reader): string =
  if reader.position >= reader.tokens.len:
    raise newException(EOFError, "reached end of input.")
  reader.tokens[reader.position]


proc next(reader: var Reader): string =
  result = reader.peek
  inc reader.position

proc sanitize(str: string): string =
    result = str.strip(chars={' ', '\t', '\v', '\r', '\l', '\f', ','})
    debug(str, " sanitized to ", result)

proc tokenize(str: string): seq[string] =
  debug("tokenizing ", str)
  str.findAll(regex).filterIt(not it.startsWith(';')).map(sanitize)


proc readList(reader: var Reader): MalData =
  assert reader.next == "("

  result = MalData(dataType: List)
  while reader.peek != ")":
    result.data.add reader.readForm
  
  assert reader.next == ")"

proc readVector(reader: var Reader): MalData =
  assert reader.next == "["

  result = MalData(dataType: Vector)
  while reader.peek != "]":
    result.items.add reader.readForm
  
  assert reader.next == "]"


proc escape(str: string): string =
  if not (str.len >= 2 and str[0] == '\"' and str[str.len - 1] == '\"'):
    raise newException(EOFError, "reached end of input.")
  let str = str[1..<str.len-1]
  debug("stripped the quotes: ", str)
  var i = 0
  while i < str.len:
    if str[i] == '\\':
      if i+1 >= str.len:
        raise newException(EOFError, "reached end of input.")
      if @['\"', '\\'].contains(str[i+1]):
        result &= str[i+1]
      elif str[i+1] == 'n':
        result &= char(10)
      else:
        raise newException(EOFError, "reached end of input.")
      i += 2
    else:
      result &= str[i]
      i+=1



proc readAtom(reader: var Reader): MalData =
  let token = reader.next
  # echo "token: ", token
  case token
    of "+":
      return MalData(dataType: Operator, operator: Addition)
    of "-":
      return MalData(dataType: Operator, operator: Subtraction)
    of "*":
      return MalData(dataType: Operator, operator: Multiplication)
    of "/":
        return MalData(dataType: Operator, operator: Division)
    of "true":
      return MalData(dataType: Boolean, value: true)
    of "false":
      return MalData(dataType: Boolean, value: false)
    of "nil":
      return MalData(dataType: Nil)
    else:
      if token[0] == '\"':
        debug("tryting to parse string: ", token)
        return MalData(dataType: String, str: token.escape)
      if token[0] == ':':
        debug("storing keyword as string with special prefix")
        return MalData(dataType: String, str: $char(127) & token[1..^1])
      try:
        return MalData(dataType: Digit, digit: parseInt(token))
      except ValueError:
        return MalData(dataType: Symbol, symbol: token) # assert symbol is valid
        




proc readForm(reader: var Reader): MalData =
  case reader.peek[0]
    of '(':
      return readList(reader)
    of '[':
      return readVector(reader)
    else:
      return readAtom(reader)


proc readStr*(str: string): MalData =
  var reader  = Reader(
    tokens: str.tokenize,
    position: 0
  )

  # echo "Tokens: ", reader.tokens

  return readForm(reader)


