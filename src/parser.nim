import std/[algorithm, strutils, sugar, sequtils]
import ./[utils, types]
import results

{.push inline, checks: off.}
func exprToSinglevec*(expr: string): seq[string] =
  expr.split(OUTER_SEP)

proc get*(s: string, i: uint): Option[char] =
  when not defined(danger):
    if s.len.uint >= i and i >= 0'u:
      return s[i].some()

type UnitParser* = object
  source*: string
  pos: uint

proc `=destroy`*(parser: UnitParser) =
  `=destroy`(parser.source)

{.push checks: off, inline.}
func newUnitParser*(src: string): UnitParser =
  UnitParser(source: src)

proc advance*(parser: var UnitParser, offset: uint = 1) =
  parser.pos += offset

func eof*(parser: UnitParser): bool =
  parser.pos >= parser.source.len.uint

proc next*(parser: var UnitParser): Option[char] =
  if not parser.eof():
    parser.advance()
    parser.source[parser.pos].some()
  else:
    none(char)

{.pop.}

proc multiUnitToSingleUnit*(parser: var UnitParser): Option[seq[FileNode]] =
  let (c1, c2, c3) = (parser.next(), parser.next(), parser.next())

  if c1 == some('(') and c3 == some(')') and c2 == some(OUTER_SEP):
    var source = parser.source.deepCopy()
    reverse source

    var subparser = newUnitParser(source)
    if (let res = subparser.multiUnitToSingleUnit(); *res):
      let value = collect:
        for file in &res:
          newFileNode(file.name, true)

      return some(value)
    else:
      return
  elif c1 == some('(') and c3 == some(')'):
    let stripped = parser.source[1 ..< parser.source.len]

    return
      some(stripped.split(INNER_SEP).filterIt(it.len > 0).mapIt(newFileNode(it, true)))

proc singleVecToMultiVec*(singlevec: seq[string]): seq[seq[FileNode]] =
  var
    tmp: seq[seq[FileNode]]
    res: seq[seq[FileNode]]

  for s in singlevec:
    var parser = newUnitParser(s)
    let value = parser.multiUnitToSingleUnit()

    if *value:
      tmp &= &value
    else:
      tmp &= @[newFileNode(s, true)]

  for i, filevec in tmp:
    if i == tmp.len - 1:
      res &=
        filevec.mapIt(
          newFileNode(it.name, get(it.name, uint(it.name.len - 1)) == some(OUTER_SEP))
        )
    else:
      res &= filevec

  res

proc parseExpr*(expr: string): seq[seq[FileNode]] =
  let
    first = exprToSingleVec(expr)
    second = singleVecToMultiVec(first)

  var res: seq[seq[FileNode]]

  for i, filevec in second:
    if i == second.len - 1:
      res &=
        filevec.mapIt(
          newFileNode(it.name, get(it.name, uint(it.name.len - 1)) == some(OUTER_SEP))
        )
    else:
      res &= filevec

  res

proc isValidParenthesis*(s: string): bool =
  var stack = newSeq[char]()

  for i, c in s:
    case c
    of '(':
      stack &= c
    of ')':
      if stack.len < 1:
        return false

      case stack.pop()
      of '(':
        discard
      else:
        return false
    else:
      discard

  stack.len < 1

proc isValidExpr*(s: string): Result[void, string] =
  if s.len < 1:
    err("empty expression")
  elif not s.isValidParenthesis():
    err("invalid parenthesis")
  elif s.get(1) == some(OUTER_SEP):
    err("first character cannot be '/'")
  elif s.contains("//"):
    err("cannot contain two consecutive '/'")
  elif s.contains(",,"):
    err("cannot contain two consecutive ','")
  else:
    ok()

export types
