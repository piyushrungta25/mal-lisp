import std/strformat
import std/tables
import std/sequtils
import MalTypes
import replEnv


proc eval*(ast: MalData): MalData
proc evalAst(ast: MalData): MalData


proc eval*(ast: MalData): MalData =
    case ast.dataType:
        of List:
            if ast.data.len == 0:
                return ast

            var evaluatedList = evalAst(ast)
            if evaluatedList.data[0].dataType != Symbol:
                raise newException(ValueError,
                        fmt"can not evaluate `{evaluatedList.data[0].dataType}`")
            let symbol: string = evaluatedList.data[0].symbol
            let args: seq[MalData] = evaluatedList.data[1..^1]
            let fun: MalEnvFunctions = prelude[symbol]
            return fun(args)
        else:
            return ast.evalAst


proc evalAst(ast: MalData): MalData =
    case ast.dataType
        of Symbol:
            if not prelude.contains(ast.symbol):
                raise newException(ValueError, fmt"`{ast.symbol}` not defined")
            return ast
        of List:
            result = MalData(dataType: List, data: ast.data.map(eval))
        of Vector:
            result = MalData(dataType: Vector, items: ast.items.map(eval))
        of HashMap:
            result = MalData(dataType: HashMap)
            for (k, v) in ast.map.pairs:
                result.map[eval(k)] = eval(v)
        else:
            return ast

