import std/tables
import std/options
import preludeFunctions
import MalTypes
import exceptionUtils


proc set*(env: var ReplEnv, key: MalData, val: MalData) =
  env.properties[key] = val


proc find*(env: ReplEnv, key: MalData): Option[MalData] =
  if env.properties.contains(key): return some(env.properties[key])
  if env.outer.isSome: return env.outer.get.find(key)
  return none(MalData)


proc get*(env: ReplEnv, key: MalData): MalData =
  let valMaybe = env.find(key)
  if valMaybe.isSome: return valMaybe.get
  raiseNotFoundError($key)


proc bindEnv(env: var ReplEnv, binds: seq[MalData], exprs: seq[MalData]) =
  var i, j: int

  while i < binds.len:
    if binds[i].isVariadicMarkerSym:
      if i+1 >= binds.len:
        raise newException(ValueError, "variadic arg name not definied")
      if i+1 != binds.len - 1:
        raise newException(ValueError, "more than one variadic arg specified")
      let items = if j >= exprs.len: @[] else: exprs[j..^1]
      env.set(binds[i+1], MalData(dataType: List, items: items))
      return
    else:
      if j >= exprs.len: break
      env.set(binds[i], exprs[j])

    inc i
    inc j



proc newEnv*(outer: Option[ReplEnv] = none(ReplEnv),
             binds: seq[MalData] = @[],
             exprs: seq[MalData] = @[]): ReplEnv =
  result = ReplEnv(outer: outer, properties: initTable[MalData, MalData]())
  result.bindEnv(binds, exprs)



proc getPrelude*(): ReplEnv =
  result = newEnv()
  result.properties = getPreludeFunction()

