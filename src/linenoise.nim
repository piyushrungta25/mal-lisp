{.passC: "-Ilib/linenoise".}
{.compile: "linenoise.c".}

proc linenoise*(prompt: cstring): cstring {.importc, header: "linenoise.h".}


