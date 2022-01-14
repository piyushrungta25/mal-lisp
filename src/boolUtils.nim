import MalTypes

proc isFalsy*(data: MalData): bool =
  case data.dataType:
    of Nil: return true
    of Boolean: return not data.value
    else: return false

proc isTruthy*(data: MalData): bool =
  return not data.isFalsy

proc isMalTrue*(data: MalData): bool =
  return data.dataType == Boolean and data.value == true

proc isMalFalse*(data: MalData): bool =
  return not data.isMalTrue

proc newMalBool*(val: bool): Maldata =
  return Maldata(dataType: Boolean, value: val)
