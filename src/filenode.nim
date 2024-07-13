import std/[os, strutils]
import ./[types, parser, utils]
import results

const NULL_STR = newString(0)

proc createFileNoCheck*(node: FileNode): Result[void, string] {.inline.} =
  template failed() =
    return err("could not create file '$1': $2" % [node.name, exc.msg])

  try:
    writeFile(node.name, NULL_STR)
    return ok()
  except IOError as exc:
    failed
  except OSError as exc:
    failed

proc createFileNode*(node: FileNode): Result[void, string] =
  let abscurrpath = getCurrentDir()
    # `getCurrentDir` automatically returns the absolute path

  if fileExists(node.name) or dirExists(node.name):
    return ok()
  else:
    if node.name.contains(OUTER_SEP) and
        node.name.get(uint(node.name.len - 1)) != some(OUTER_SEP):
      let lasti = getLastIndex(node.name, OUTER_SEP)

      if !lasti:
        return err("No occurence of $1 found!" % ["" & OUTER_SEP])

      let
        directory = node.name.splitAt(@[&lasti])[0]
        creationResult = newFileNode(directory, true).createFileNode()

      if creationResult.isOk:
        return node.createFileNoCheck()
      else:
        return creationResult

    template failed() =
      return err("could not create file $1'$2': $3" % [abscurrpath, node.name, exc.msg])

    if not node.isDir and node.name.get(uint(node.name.len - 1)) != some(OUTER_SEP):
      try:
        writeFile(node.name, NULL_STR)
        return ok()
      except IOError as exc:
        failed
      except OSError as exc:
        failed
    else:
      template failed() =
        return err(
          "could not create directory '$1' in supposingly existing folder '$2': $3" %
            [node.name, abscurrpath, exc.msg]
        )

      try:
        createDir(node.name)
        return ok()
      except IOError as exc:
        failed
      except OSError as exc:
        failed

export types
