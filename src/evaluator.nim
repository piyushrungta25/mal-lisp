import std/strformat
import std/tables
import std/sequtils
import MalTypes
import env


proc eval*(ast: MalData, env: ReplEnv): MalData
proc evalAst(ast: MalData, env: ReplEnv): MalData


proc eval*(ast: MalData, env: ReplEnv): MalData =
    case ast.dataType:
        of List:
            if ast.data.len == 0:
                return ast

            var evaluatedList = evalAst(ast, env)
            if evaluatedList.data[0].dataType != Symbol:
                raise newException(ValueError,
                        fmt"can not evaluate `{evaluatedList.data[0].dataType}`")
            let symbol = evaluatedList.data[0]
            let args: seq[MalData] = evaluatedList.data[1..^1]
            let envVal: EnvValue = env.properties[symbol]
            assert envVal.valType == FunVal
            return envVal.fun(args)
        else:
            return ast.evalAst(env)


proc evalAst(ast: MalData, env: ReplEnv): MalData =
    case ast.dataType
        of Symbol:
            if not env.properties.contains(ast):
                raise newException(ValueError, fmt"`{ast.symbol}` not defined")
            return ast
        of List:
            result = MalData(dataType: List, data: ast.data.mapIt(it.eval(env)))
        of Vector:
            result = MalData(dataType: Vector, items: ast.items.mapIt(it.eval(env)))
        of HashMap:
            result = MalData(dataType: HashMap)
            for (k, v) in ast.map.pairs:
                result.map[eval(k, env)] = eval(v, env)
        else:
            return ast

