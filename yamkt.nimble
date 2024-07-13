# Package

version       = "0.1.0"
author        = "xTrayambak"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
bin           = @["yamkt"]


# Dependencies

requires "nim >= 2.0.0"
requires "results >= 0.4.0"

taskRequires "fmt", "nph"

task fmt, "Format code":
  exec "nph src/"
