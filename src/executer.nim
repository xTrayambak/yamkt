import std/[os]
import ./[parser, filenode, utils]

proc executeMultivec*(v: seq[seq[FileNode]]) =
  if v.len < 1:
    return

  let
    head = v[0].deepCopy()
    tail = v[1 ..< v.len].deepCopy()

  for file in head:
    let creationResult = file.createFileNode()
    if creationResult.isErr:
      errorStr(creationResult.error())
      continue

    if file.isDir:
      let absCurrPath = getCurrentDir()
      let absPath = absCurrPath / file.name

      setCurrentDir(absPath)
      executeMultivec(tail)
      setCurrentDir(absPath / "..")

{.push inline, checks: off.}
proc parseAndExecute*(expr: string) =
  executeMultivec(parseExpr(expr))

{.pop.}
