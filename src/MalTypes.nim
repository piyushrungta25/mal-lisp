type
  Reader* = object
    tokens*: seq[string]
    position*: int
  
  MalDataType* = enum
    List
    Operator
    Digit
    String
    Boolean
    Nil
    Symbol
    Vector
  
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
