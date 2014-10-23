import unittest
import terminal

{.hints: off.}

import "../lib/clargs"

setForegroundColor(fgYellow)
writeStyled "===========================\n"
writeStyled "  File: `test_clargs.nim`  \n"
writeStyled "===========================\n"

suite "Test normal execution":

  setForegroundColor(fgMagenta)
  writeStyled "----------------------------\n"
  writeStyled "Suite: Test normal execution\n"
  writeStyled "----------------------------\n"
  
  test "Normal execution":
    var parser = newParser()
    parser.addArgument(newArgument("arg1", "desc"))
    parser.addOption(newOption("opt1", "option", "o", "opt"))

    discard parser.parse(@["hello", "-o"])

suite "Test clargs with no commands":
  
  setForegroundColor(fgMagenta)
  writeStyled "-----------------------------------\n"
  writeStyled "Suite: Test clargs with no commands\n"
  writeStyled "-----------------------------------\n"

  setup:
    var parserWithArgs = newParser()
    parserWithArgs.addArgument(newArgument("arg1", "First Argument"))
    parserWithArgs.addArgument(newArgument("arg2", "Second Argument"))

    var parserWithOpts = newParser()
    parserWithOpts.addOption(newOption("opt1", "First Option", "o", "1"))
    parserWithOpts.addOption(newOption("long-form", "Long Form Option", "long-form"))
    parserWithOpts.addOption(newOption("mixedForm", "Mixed Option", "m", "mixedopt"))

  test "Parser with args can retrieve args":
    var res = parserWithArgs.parse(@["myarg1", "myarg2"])
    assert res.arguments["arg1"] == "myarg1"
    assert res.arguments["arg2"] == "myarg2"

  test "Parser with missing args fails":
    expect EClarg:
      discard parserWithArgs.parse(@["myarg1"])

    expect EClarg:
      discard parserWithArgs.parse(@[])

  test "Parser with opts can retrieve long-form opts":
    var res = parserWithOpts.parse(@["--long-form"])
    assert res.options.hasKey("long-form")

    res = parserWithOpts.parse(@["--mixedopt:withKey"])
    assert res.options["mixedForm"] == "withKey"

  test "Parser with opts can retrieve short-form opts":
    var res = parserWithOpts.parse(@["-o"])
    assert res.options.hasKey("opt1")

    res = parserWithOpts.parse(@["-1:72", "-m"])
    assert res.options["opt1"] == "72"
    assert res.options.hasKey("mixedForm")

  test "Parser does not fail with no options":
    var res = parserWithOpts.parse(@[])

  test "Options can be passed as array as well as varargs":
    discard newOption("test-opt", "Test option", ["a", "opt"])

  test "Base parser should return command == ''":
    var res = parserWithArgs.parse(@["myarg1", "myarg2"])
    assert res.command == ""

suite "Test with single-level subcommand":
  
  setForegroundColor(fgMagenta)
  writeStyled "----------------------------------\n"
  writeStyled "Suite: Test with single subcommand\n"
  writeStyled "----------------------------------\n"

  setup:
    var parserWithSingleSubcommand = newParser()

    var subcommand = newCommand("command")
    subcommand.addOption(newOption("opt1", "Option", "o", "option"))
    parserWithSingleSubcommand.addCommand(subcommand)

    var subcommand2 = newCommand("second-comm")
    subcommand2.addArgument(newArgument("argr", "Argument"))
    parserWithSingleSubcommand.addCommand(subcommand2)

    parserWithSingleSubcommand.addArgument(newArgument("arg2", "Argument of main command"))

  test "Subcommand exists":
    var res = parserWithSingleSubcommand.parse(@["command"])
    assert res.command == "command"

  test "Subcommand does not overwrite other args to main command":
    var res = parserWithSingleSubcommand.parse(@["argument"])
    assert res.command == ""
    assert res.arguments["arg2"] == "argument"

  test "Subcommands can take opts":
    var res = parserWithSingleSubcommand.parse(@["command", "--option:x"])
    assert res.command == "command"
    assert res.options["opt1"] == "x"

    res = parserWithSingleSubcommand.parse(@["command", "-o"])
    assert res.command == "command"
    assert res.options.hasKey("opt1")

  test "Subcommands can take args":
    var res = parserWithSingleSubcommand.parse(@["second-comm", "argum"])
    assert res.command == "second-comm"
    assert res.arguments["argr"] == "argum"

suite "Test multiple levels of sub-commands":
  
  setForegroundColor(fgMagenta)
  writeStyled "-------------------------------------------\n"
  writeStyled "Suite: Test multiple levels of sub-commands\n"
  writeStyled "-------------------------------------------\n"

  test "Multiple levels of subcommand are possible":
    fail()  # Tests not yet written


suite "Improvements (TODO)":
  
  setForegroundColor(fgMagenta)
  writeStyled "--------------------------\n"
  writeStyled "Suite: Improvements (TODO)\n"
  writeStyled "--------------------------\n"

  test "Safe version of parse":

    var parser = newParser()
    parser.addArgument(newArgument("reqdarg", "Required Argument"))

    #parser.parseSafe(@[])
    fail()

  test "Varargs for arguments":

    var parser = newParser()
    #parser.addArgument(newArgument("files", "Many arguments here", varargs=true))
    fail()





