import std/[terminal, options, strutils]
import ./[types]
import results

const SPLIT_FMT_STR* {.strdefine: "SplitFormatString".} = "$1$2"

{.push checks: off, inline.}
func `*`*[T](opt: Option[T]): bool =
  opt.isSome

func `!`*[T](opt: Option[T]): bool =
  opt.isNone

proc `*`*[V, E](opt: Result[V, E]): bool =
  opt.isOk

proc `!`*[V, E](opt: Result[V, E]): bool =
  opt.isErr

func `&`*[T](opt: Option[T]): T =
  opt.unsafeGet()

{.pop.}

func splitAt*(s: string, i: uint): (string, string) =
  (s[0 ..< i], s[i ..< s.len])

func splitAt*(s: string, positions: seq[uint]): seq[string] =
  var
    res: seq[string]
    rest = deepCopy(s)

    n: uint

  for pos in positions:
    let (piche, age) = rest.splitAt(pos - n)

    n += piche.len.uint + 1'u
    res &= SPLIT_FMT_STR % [piche, "" & OUTER_SEP] # dumb
    rest = age[1 ..< age.len]

  if rest.len > 0:
    res &= rest

  res

func getLastIndex*(s: string, c: char): Option[uint] {.inline.} =
  for i in countDown(s.len, 0):
    if s[i] == c:
      return some(i.uint)

{.push inline, checks: off.}
proc errorStr*(msg: sink string) =
  styledWriteLine(
    stdout, styleBright, "[", resetStyle, fgRed, "ERROR", resetStyle, styleBright, "] ",
    resetStyle, msg,
  )

{.pop.}

export options, results
