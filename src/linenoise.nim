{.passC: "-Ilib/linenoise".}
{.compile: "linenoise.c".}

{.push header: "linenoise.h".}

proc linenoise*(prompt: cstring): cstring {.importc.}
proc linenoiseHistorySetMaxLen(len: cint): cint {.importc, discardable.}
proc linenoiseHistoryAdd*(line: cstring): cint {.importc, discardable.}
proc linenoiseSetMultiLine(flag: cint) {.importc.}
proc linenoiseFree*(line: pointer) {.importc.}

linenoiseHistorySetMaxLen(100)
linenoiseSetMultiLine(true.cint)

{.pop.}
