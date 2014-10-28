import nake
import strutils
import os
import terminal

const
  ROOT_TEST_DIR = "tests"

task "clean", "Removes nimcache folders, compiled exes":
  removeDir("nimcache")
  removeDir("bin")

task "build", "Builds clicker":
  createDir("bin")
  direshell("nimrod c --out:bin/clicker  clicker.nim")

task "test", "Runs tests":
  for ftype, testf in walkDir(ROOT_TEST_DIR):
    if testf.startsWith(os.joinPath(ROOT_TEST_DIR, "test_")) and testf.endsWith(".nim"):

      shell("nimrod", "c", "--verbosity:0", "-r", testf)
