import std/strformat
import std/tables
import MalTypes
import replEnv


proc eval*(data: MalData): MalData
proc evalAst(data: MalData): MalData


proc eval*(data: MalData): MalData =
    case data.dataType:
        of List:
            if data.data.len == 0:
                return data

            var evaluatedList = evalAst(data)
            if evaluatedList.data[0].dataType != Symbol:
                raise newException(ValueError,
                        fmt"can not evaluate `{evaluatedList.data[0].dataType}`")
            let symbol: string = evaluatedList.data[0].symbol
            let args: seq[MalData] = evaluatedList.data[1..^1]
            let fun: MalEnvFunctions = prelude[symbol]
            return fun(args)
        else:
            return data.evalAst


proc evalAst(data: MalData): MalData =
    case data.dataType
        of Symbol:
            if not prelude.contains(data.symbol):
                raise newException(ValueError, fmt"`{data.symbol}` not defined")
            return data
        of List:
            result = MalData(dataType: List)
            for d in data.data:
                result.data.add eval(d)
        else:
            return data

