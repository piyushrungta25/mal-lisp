import std/strformat
import std/tables
import std/sequtils
import MalTypes
import env


proc eval*(ast: MalData, replEnv: ReplEnv): MalData
proc evalAst(ast: MalData, replEnv: ReplEnv): MalData


proc eval*(ast: MalData, replEnv: ReplEnv): MalData =
    case ast.dataType:
        of List:
            if ast.data.len == 0: return ast

            var evaluatedList = evalAst(ast, replEnv)
            if evaluatedList.data[0].dataType != Symbol:
                raise newException(ValueError, fmt"can not evaluate `{evaluatedList.data[0].dataType}`")
            
            let envVal: EnvValue = replEnv.get(evaluatedList.data[0])
            assert envVal.valType == FunVal

            return envVal.fun(evaluatedList.data[1..^1])
        else:
            return ast.evalAst(replEnv)


proc evalAst(ast: MalData, replEnv: ReplEnv): MalData =
    case ast.dataType
        of List:
            result = MalData(dataType: List, data: ast.data.mapIt(it.eval(replEnv)))
        of Vector:
            result = MalData(dataType: Vector, items: ast.items.mapIt(it.eval(replEnv)))
        of HashMap:
            result = MalData(dataType: HashMap)
            for (k, v) in ast.map.pairs:
                result.map[eval(k, replEnv)] = eval(v, replEnv)
        else: return ast

