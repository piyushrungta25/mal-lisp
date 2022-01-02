import std/tables
import MalTypes

proc addition(args: varargs[MalData]): MalData =
    result = MalData(dataType: Digit, digit: 0)

    for arg in args:
        if arg.dataType != Digit:
            raise newException(ValueError, "add not supported for non-digit types")
        result.digit += arg.digit


proc multiplication(args: varargs[MalData]): MalData =
    result = MalData(dataType: Digit, digit: 1)

    for arg in args:
        if arg.dataType != Digit:
            raise newException(ValueError, "mul not supported for non-digit types")
        result.digit *= arg.digit


proc subtraction(args: varargs[MalData]): MalData =
    result = MalData(dataType: Digit)

    for i, arg in args:
        if arg.dataType != Digit:
            raise newException(ValueError, "sub not supported for non-digit types")
        if i == 0: result.digit = arg.digit
        else: result.digit -= arg.digit


proc division(args: varargs[MalData]): MalData =
    result = MalData(dataType: Digit)

    for i, arg in args:
        if arg.dataType != Digit:
            raise newException(ValueError, "div not supported for non-digit types")
        if i != 0 and arg.digit == 0:
            raise newException(ValueError, "division by zero")

        if i == 0: result.digit = arg.digit
        else: result.digit = int(result.digit/arg.digit)


let prelude* = {
    "+": addition,
    "-": subtraction,
    "*": multiplication,
    "/": division
}.toTable
