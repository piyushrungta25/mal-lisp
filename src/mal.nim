
proc read(str: string): string =
  str

proc eval(str: string): string =
  str

proc print(str: string): string =
  str

proc rep(str: string): string =
  return str.read.eval.print


when isMainModule:
  while true:
    stdout.write "user> "
    let str = stdin.readLine
    echo str.rep


  

