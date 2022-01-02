import std/[tables, hashes]


const STRIP_CHARS* = {' ', '\t', '\v', '\r', '\l', '\f', ','}
const COMMENT_CHAR* = ';'
const NEW_LINE_CHAR* = char(10)
const KEYWORD_PREFIX* = $char(127)


type
  MalDataType* = enum
    List
    Operator
    Digit
    String
    Boolean
    Nil
    Symbol
    Vector
    HashMap

  MalOperator* = enum
    Addition = "+"
    Subtraction = "-"
    Multiplication = "*"
    Division = "/"

  MalData* = ref object
    case dataType*: MalDataType
      of List:
        data*: seq[MalData]
      of Operator:
        operator*: MalOperator
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

proc hash*(malData: MalData): Hash = hash(cast[int](malData.unsafeAddr))
