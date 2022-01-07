import std/os
import options

{.passC: "-Ilib/linenoise".}
{.compile: "linenoise.c".}

{.push header: "linenoise.h".}

proc linenoise(prompt: cstring): cstring {.importc.}
proc linenoiseHistorySetMaxLen(len: cint): cint {.importc, discardable.}
proc linenoiseHistoryAdd(line: cstring): cint {.importc, discardable.}
proc linenoiseSetMultiLine(flag: cint) {.importc.}
proc linenoiseFree(line: pointer) {.importc.}
proc linenoiseHistorySave(filename: cstring): cint {.importc, discardable.}
proc linenoiseHistoryLoad(filename: cstring): cint {.importc, discardable.}

{.pop.}

const historyFileName = "/tmp/mal.history"
const maxHistoryLength = 1000

linenoiseHistorySetMaxLen(maxHistoryLength)
linenoiseSetMultiLine(true.cint)
linenoiseHistoryLoad(historyFileName)


proc getInputLine*(): Option[string] =
  while true:
    let line = linenoise("user> ")
    if line == nil:
      return none(string)
    if line.len != 0:
      let s_line = some($line)
      linenoiseHistoryAdd(line)
      if os.getEnv("PERSIST_HISTORY") == "true":
        linenoiseHistorySave(historyFileName)
      linenoiseFree(line)
      return s_line

