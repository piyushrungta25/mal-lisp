import std/strutils
import exceptionUtils

const STRIP_CHARS* = {' ', '\t', '\v', '\r', '\l', '\f', ','}
const COMMENT_CHAR* = ';'
const NEW_LINE_CHAR* = char(10)
const KEYWORD_PREFIX* = $char(127)


proc unescape*(str: string): string =
  for c in str:
    if c == '\"':
      result &= "\\\""
    elif c == '\\':
      result &= "\\\\"
    elif c == NEW_LINE_CHAR:
      result &= "\\n"
    else:
      result &= c


proc sanitize*(str: string): string =
  str.strip(chars = STRIP_CHARS)


proc escape*(str: string): string =
  if not (str.len >= 2 and str[0] == '\"' and str[str.len - 1] == '\"'):
    raiseEOF()
  let str = str[1..<str.len-1]

  var i = 0
  while i < str.len:
    if str[i] == '\\':
      if i+1 >= str.len:
        raiseEOF()
      if @['\"', '\\'].contains(str[i+1]):
        result &= str[i+1]
      elif str[i+1] == 'n':
        result &= NEW_LINE_CHAR
      else:
        raiseEOF()
      i += 2
    else:
      result &= str[i]
      i+=1


