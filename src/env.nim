import std/tables
import std/options
import std/sequtils
import preludeFunctions
import MalTypes
import exceptionUtils


type
  ReplEnv* = ref object
    outer: Option[ReplEnv]
    properties: Table[MalData, MalData]


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


proc newEnv*(outer: Option[ReplEnv] = none(ReplEnv),
             binds: seq[MalData] = @[],
             exprs: seq[MalData] = @[]): ReplEnv =
  result = ReplEnv(outer: outer, properties: initTable[MalData, MalData]())
  for (bnd, expr) in zip(binds, exprs):
    result.set(bnd, expr)



proc getPrelude*(): ReplEnv =
  result = newEnv()
  result.properties = getPreludeFunction()

