import nake
import strutils

task "clean", "Removes nimcache folders, compiled exes":
    direshell("rm -rf nimcache")
    direshell("rm -rf bin")

task "build", "Builds clicker":
    direshell("mkdir -p bin")
    direshell("nimrod c --out:bin/clicker clicker.nim")
