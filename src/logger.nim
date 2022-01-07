import std/logging
import std/os


let level = case os.getEnv("LOGGING")
  of "debug": lvlDebug
  of "all": lvlAll
  else: lvlInfo


var consoleLogger* = newConsoleLogger(fmtStr = "[$levelname] ",
    levelThreshold = level)

addHandler(consoleLogger)
