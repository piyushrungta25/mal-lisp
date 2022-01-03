import std/tables
import std/options
import preludeFunctions
import MalTypes
import exceptionUtils


type
  EnvKey* = MalData
  EnvValueTypes* = enum
    DataVal
    FunVal

  EnvValue* = ref object
    case valType*: EnvValueTypes
      of DataVal:
        data*: MalData
      of FunVal:
        fun*: MalEnvFunctions

  ReplEnv* = ref object
    outer: Option[ReplEnv]
    properties: Table[EnvKey, EnvValue]


proc newEnv*(): ReplEnv =
  ReplEnv(outer: none(ReplEnv), properties: initTable[EnvKey, EnvValue]())


proc newSymbol(str: string): MalData =
  MalData(dataType: Symbol, symbol: str)


proc getPrelude*(): ReplEnv =
  result = newEnv()
  result.properties = {
    newSymbol("+"): EnvValue(valType: FunVal, fun: addition),
    newSymbol("-"): EnvValue(valType: FunVal, fun: subtraction),
    newSymbol("*"): EnvValue(valType: FunVal, fun: multiplication),
    newSymbol("/"): EnvValue(valType: FunVal, fun: division),
  }.toTable

proc set*(env: var ReplEnv, key: EnvKey, val: EnvValue) =
  env.properties[key] = val


proc find*(env: ReplEnv, key: EnvKey): Option[EnvValue] =
  if env.properties.contains(key): return some(env.properties[key])

  if env.outer.isSome:
    return env.outer.get.find(key)

  return none(EnvValue)


proc get*(env: ReplEnv, key: EnvKey): EnvValue =
  let valMaybe = env.find(key)
  if valMaybe.isSome: return valMaybe.get
  raiseNotFoundError($key)
