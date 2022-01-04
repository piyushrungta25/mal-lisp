import std/re
import std/sequtils
import std/strutils
import std/tables

import MalTypes
import stringUtils
import exceptionUtils

let regex = re"""[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"?|;.*|[^\s\[\]{}('"`,;)]*)"""


type
  Reader* = object
    tokens*: seq[string]
    position*: int


proc peek(reader: Reader): string =
  if reader.position >= reader.tokens.len:
    raiseEOF()
  reader.tokens[reader.position]


proc next(reader: var Reader): string =
  result = reader.peek
  inc reader.position


# forward declaration
proc readForm(reader: var Reader): MalData


proc tokenize(str: string): seq[string] =
  str
    .findAll(regex)
    .map(sanitize)
    .filterIt(not it.startsWith(COMMENT_CHAR)) # filter out comments


proc readList(reader: var Reader): MalData =
  assert reader.next == "("

  result = MalData(dataType: List)
  while reader.peek != ")":
    result.items.add reader.readForm

  assert reader.next == ")"


proc readVector(reader: var Reader): MalData =
  assert reader.next == "["

  result = MalData(dataType: Vector)
  while reader.peek != "]":
    result.items.add reader.readForm

  assert reader.next == "]"


proc readHashMap(reader: var Reader): MalData =
  assert reader.next == "{"

  var map = initOrderedTable[MalData, MalData]()
  while reader.peek != "}":
    let key = reader.readForm
    let value = reader.readForm
    if key.dataType != String:
      raise newException(ValueError, "malformed hashMap key, string or keyword required")
    map[key] = value
  result = MalData(dataType: HashMap, map: map)

  assert reader.next == "}"



proc readAtom(reader: var Reader): MalData =
  let token = reader.next
  case token
    of "true":
      return MalData(dataType: Boolean, value: true)
    of "false":
      return MalData(dataType: Boolean, value: false)
    of "nil":
      return MalData(dataType: Nil)
    else:
      if token[0] == '\"':
        return MalData(dataType: String, str: stringUtils.escape(token))
      elif token[0] == ':':
        return MalData(dataType: String, str: KEYWORD_PREFIX & token[1..^1])
      try:
        return MalData(dataType: Digit, digit: parseInt(token))
      except ValueError:
        return MalData(dataType: Symbol, symbol: token)


proc readSpecialForms(reader: var Reader): MalData =
  let next = reader.next
  var symbol = case next
    of "'": "quote"
    of "~": "unquote"
    of "~@": "splice-unquote"
    of "`": "quasiquote"
    of "@": "deref"
    else:
      raise newException(ValueError, "bad symbol")

  let items = @[MalData(dataType: Symbol, symbol: symbol), reader.readForm]
  result = MalData(dataType: List, items: items)


proc readWithMetadata(reader: var Reader): MalData =
  assert reader.next == "^"

  let symbol = MalData(dataType: Symbol, symbol: "with-meta")
  let (arg, meta) = (reader.readForm, reader.readForm)

  result = MalData(dataType: List, items: @[symbol, meta, arg])


proc readForm(reader: var Reader): MalData =
  case reader.peek[0]
    of '(':
      return readList(reader)
    of '[':
      return readVector(reader)
    of '{':
      return readHashMap(reader)
    of '\'', '`', '~', '@':
      return readSpecialForms(reader)
    of '^':
      return readWithMetadata(reader)
    else:
      return readAtom(reader)


proc readStr*(str: string): MalData =
  var reader = Reader(tokens: str.tokenize)
  return readForm(reader)
