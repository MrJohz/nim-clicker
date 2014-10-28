import unittest
import terminal

#{.hints: off.}

import "../lib/clargs"

type
  E_Testing = object of E_Base

setForegroundColor(fgYellow)
writeStyled "===========================\n"
writeStyled "  File: `test_clargs.nim`  \n"
writeStyled "==========================="
echo "\e[39m"


suite "Test normal execution":

  setForegroundColor(fgMagenta)
  writeStyled "----------------------------\n"
  writeStyled "Suite: Test normal execution\n"
  writeStyled "----------------------------"
  echo "\e[39m"

  test "Normal execution":
    var parser = newParser()
    parser.addArgument(newArgument("arg1", "desc"))
    parser.addOption(newOption("opt1", "option", ["o", "opt"]))

    discard parser.parse(@["hello", "-o"])


suite "Test clargs with no commands":
  
  setForegroundColor(fgMagenta)
  writeStyled "-----------------------------------\n"
  writeStyled "Suite: Test clargs with no commands\n"
  writeStyled "-----------------------------------"
  echo "\e[39m"

  setup:
    var parserWithArgs = newParser()
    parserWithArgs.addArgument(newArgument("arg1", "First Argument"))
    parserWithArgs.addArgument(newArgument("arg2", "Second Argument"))

    var parserWithOpts = newParser()
    parserWithOpts.addOption(newOption("opt1", "First Option", ["o", "1"]))
    parserWithOpts.addOption(newOption("long-form", "Long Form Option", ["long-form"]))
    parserWithOpts.addOption(newOption("mixedForm", "Mixed Option", ["m", "mixedopt"]))

    var res: PResult

  test "Parser with args can retrieve args":
    res = parserWithArgs.parse(@["myarg1", "myarg2"])
    assert res.arguments["arg1"] == "myarg1"
    assert res.arguments["arg2"] == "myarg2"

  test "Parser with missing args fails":
    expect EClarg:
      discard parserWithArgs.parse(@["myarg1"])

    expect EClarg:
      discard parserWithArgs.parse(@[])

  test "Parser with opts can retrieve long-form opts":
    res = parserWithOpts.parse(@["--long-form"])
    assert res.options.hasKey("long-form")

    res = parserWithOpts.parse(@["--mixedopt:withKey"])
    assert res.options["mixedForm"] == "withKey"

  test "Parser with opts can retrieve short-form opts":
    res = parserWithOpts.parse(@["-o"])
    assert res.options.hasKey("opt1")

    res = parserWithOpts.parse(@["-1:72", "-m"])
    assert res.options["opt1"] == "72"
    assert res.options.hasKey("mixedForm")

  test "Parser does not fail with no options":
    res = parserWithOpts.parse(@[])

  test "Parser does fail with unwanted options":
    expect EClarg:
      res = parserWithOpts.parse(@["--unwanted:opt"])

  test "Base parser should return command == ''":
    res = parserWithArgs.parse(@["myarg1", "myarg2"])
    assert res.command == ""


suite "Test with single-level subcommand":
  
  setForegroundColor(fgMagenta)
  writeStyled "----------------------------------\n"
  writeStyled "Suite: Test with single subcommand\n"
  writeStyled "----------------------------------"
  echo "\e[39m"

  setup:
    var parserWithSingleSubcommand = newParser()

    var subcommand = newCommand("command")
    subcommand.addOption(newOption("opt1", "Option", ["o", "option"]))
    parserWithSingleSubcommand.addCommand(subcommand)

    var subcommand2 = newCommand("second-comm")
    subcommand2.addArgument(newArgument("argr", "Argument"))
    parserWithSingleSubcommand.addCommand(subcommand2)

    parserWithSingleSubcommand.addArgument(newArgument("arg2", "Argument of main command"))

    var res: PResult

  test "Subcommand exists":
    res = parserWithSingleSubcommand.parse(@["command"])
    assert res.command == "command"

  test "Subcommand does not overwrite other args to main command":
    res = parserWithSingleSubcommand.parse(@["argument"])
    assert res.command == ""
    assert res.arguments["arg2"] == "argument"

  test "Subcommands can take opts":
    res = parserWithSingleSubcommand.parse(@["command", "--option:x"])
    assert res.command == "command"
    assert res.options["opt1"] == "x"

    res = parserWithSingleSubcommand.parse(@["command", "-o"])
    assert res.command == "command"
    assert res.options.hasKey("opt1")

  test "Subcommands can take args":
    res = parserWithSingleSubcommand.parse(@["second-comm", "argum"])
    assert res.command == "second-comm"
    assert res.arguments["argr"] == "argum"


suite "Test multiple levels of sub-commands":
  
  setForegroundColor(fgMagenta)
  writeStyled "-------------------------------------------\n"
  writeStyled "Suite: Test multiple levels of sub-commands\n"
  writeStyled "-------------------------------------------"
  echo "\e[39m"

  setup:
    var parserNestedSubcommands = newParser()

    var subcom1 = newCommand("tlc")
    subcom1.addOption(newOption("opt1", "Option", ["o", "option"]))

    var subcom2 = newCommand("2lc")
    subcom2.addOption(newOption("sec-lev-opt", "", ["o", "option"]))
    var deepNest = newCommand("deepnest")
    subcom2.addCommand(deepNest)

    subcom1.addCommand(subcom2)

    var subcom3 = newCommand("tlc-2")
    subcom3.addArgument(newArgument("argum", "Argument"))
    
    var subcom4 = newCommand("2-2lc")
    subcom4.addArgument(newArgument("argum2", "Argument 2"))
    subcom3.addCommand(subcom4)

    parserNestedSubcommands.addCommand(subcom1)
    parserNestedSubcommands.addCommand(subcom3)

    var res: PResult

  test "Second level subcommand possible (w/ & w/o option)":
    res = parserNestedSubcommands.parse(@["tlc", "2lc"])
    assert res.command == "tlc.2lc"

    res = parserNestedSubcommands.parse(@["tlc", "2lc", "-o:val"])
    assert res.command == "tlc.2lc"
    assert res.options["sec-lev-opt"] == "val"

  test "Second level subcommand possible with arguments":
    res = parserNestedSubcommands.parse(@["tlc-2", "argument"])
    assert res.command == "tlc-2"
    assert res.arguments["argum"] == "argument"

    res = parserNestedSubcommands.parse(@["tlc-2", "2-2lc", "argument-deep"])
    assert res.command == "tlc-2.2-2lc"
    assert res.arguments["argum2"] == "argument-deep"

  test "Deeper nesting (recusion inducts all levels deeper than this)":
    res = parserNestedSubcommands.parse(@["tlc", "2lc", "deepnest"])
    assert res.command == "tlc.2lc.deepnest"


suite "Greedy Options":
  
  setForegroundColor(fgMagenta)
  writeStyled "---------------------\n"
  writeStyled "Suite: Greedy Options\n"
  writeStyled "---------------------"
  echo "\e[39m"

  setup:
    var parser = newParser()
    parser.addGreedyOption(newOption("option", "Desc", ["o", "opt"]))

    var command = newCommand("subcom")
    command.addOption(newOption("secondary-option", "Another Desc", ["o", "opt2"]))

    parser.addCommand(command)

    var res: PResult
  
  test "Greedy options works on base parser":

    res = parser.parse(@["-o:arg"])
    assert res.options.hasKey("option")
    assert res.options["option"] == "arg"

  test "Ensure subcommand works as usual without greedy option":

    res = parser.parse(@["subcom", "--opt2"])
    assert res.options.hasKey("secondary-option")

  test "Greedy option proliferates upwards":

    res = parser.parse(@["subcom", "--opt"])
    assert res.options.hasKey("option")

  test "Greedy option overwrites other options":

    res = parser.parse(@["subcom", "-o"])
    assert res.options.hasKey("option")


suite "Callbacks work":

  setForegroundColor(fgMagenta)
  writeStyled "---------------------\n"
  writeStyled "Suite: Callbacks work\n"
  writeStyled "---------------------"
  echo "\e[39m"
  
  test "Basic callback operation for options":

    proc callback(x: string) {.closure.} =
      raise newException(E_Testing, "test-error")

    var parser = newParser()
    parser.addOption(newOption("option", "Desc", ["o"], callback))

    expect E_Testing:
      var x = parser.parse(@["-o:argument"])


suite "Improvements (TODO)":
  
  setForegroundColor(fgMagenta)
  writeStyled "--------------------------\n"
  writeStyled "Suite: Improvements (TODO)\n"
  writeStyled "--------------------------"
  echo "\e[39m"

  test "Safe version of parse":
    # Not very useful, tbh
    var parser = newParser()
    parser.addArgument(newArgument("reqdarg", "Required Argument"))

    var (suc, res) = parser.parseSafe(@[])
    assert suc == false
    assert res == nil

  test "Varargs for arguments":

    var parser = newParser()
    parser.addArgument(newArgument("files", "Many arguments here", vargs=true))

    var res = parser.parse(@["file1", "file2", "file3"])
    assert res.vargs == true
    assert len(res.multargs["files"]) == 3
    assert res.multargs["files"] == @["file1", "file2", "file3"]
