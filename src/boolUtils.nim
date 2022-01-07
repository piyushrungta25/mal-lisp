import MalTypes

proc isFalsy*(data: MalData): bool =
  case data.dataType:
    of Nil: return true
    of Boolean: return not data.value
    else: return false

proc isTruthy*(data: MalData): bool =
  return not data.isFalsy

