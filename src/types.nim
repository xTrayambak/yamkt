const
  OUTER_SEP* = '/'
  INNER_SEP* = ','

type FileNode* = object
  name*: string
  isDir*: bool

{.push checks: off, inline.}
func newFileNode*(name: string, isDir: bool): FileNode =
  FileNode(name: name, isDir: isDir)
{.pop.}
