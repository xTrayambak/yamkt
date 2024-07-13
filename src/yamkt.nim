import std/[os, sugar]
import ./[executer, utils, parser]

proc main() {.inline.} =
  let args = collect:
    for x in 1 .. paramCount():
      paramStr(x)

  if args.len < 1:
    return

  for arg in args:
    let valid = isValidExpr(arg)
    if valid.isErr:
      errorStr(valid.error())
      quit(1)
    else:
      parseAndExecute(arg)

when isMainModule:
  main()
