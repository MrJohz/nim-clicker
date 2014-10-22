import strtabs
export strtabs.`[]`
export strtabs.hasKey
import tables
import critbits
import parseopt2
import strutils

type
  TParser* = object
    commands: TCritBitTree[TCommand]

  TCommand* = object
    key: string
    commands: TCritBitTree[TCommand]
    arguments: seq[TArgument]
    optionslong: TCritBitTree[TOption]
    optionsshort: TCritBitTree[TOption]

  TArgument* = object
    key: string
    desc: string

  TOption* = object
    key: string
    shorts: seq[string]
    longs: seq[string]
    desc: string

  PResult* = ref TResult

  TResult = object
    command*: string
    arguments*: PStringTable
    options*: PStringTable

  EClarg* = object of EInvalidValue


# This is the name of the default command that is attached to all parsers.  This command
# is used to refer to the command that occurs when no subcommands are given.
const DEFAULT_COMMAND = ""

proc newCommand*(key: string): TCommand =
  ## Creates a new command with the name `key`.
  return TCommand(key: key,
      commands: TCritBitTree[TCommand](),
      arguments: @[],
      optionslong: TCritBitTree[TOption](),
      optionsshort: TCritBitTree[TOption]())

proc newParser*(): TParser =
  ## Creates a new parser.  All commands, args, and opts can then be attached
  ## to this parser.
  result = TParser(commands: TCritBitTree[TCommand]())
  result.commands[DEFAULT_COMMAND] = newCommand(DEFAULT_COMMAND)

proc newArgument*(key: string, desc: string): TArgument =
  ## Constructs a new argument with the key `key` and description `desc`.
  return TArgument(key: key, desc: desc)

proc newOption*(key: string, desc: string, names: varargs[string]): TOption =
  ## Constructs a new option with key `key`, description `desc`.  The rest of the
  ## arguments should be all of the different names that can refer to the option.
  ## The key does *not* specify an option-name.  For example,
  ## `newOption("myopt", "Does stuff", "option", "m")` can be specified using the
  ## flags `"--option"` and `"-m"`, but not with the "--myopt" flag.  This is for
  ## convenience, although admittedly it's more my convenience than yours.
  result = TOption(key: key, desc: desc, shorts: @[], longs: @[])
  for name in names:
    if len(name) == 1:
      result.shorts.add(name)
    else:
      result.longs.add(name)

proc addCommand*(mainCommand: var TCommand, subCommand: var TCommand) =
  ## Adds a subcommand to a command
  ## N.B. The subcommand must be declared and assigned before it is passed -
  ## this proc uses reference semantics.  If your command has arguments and
  ## options, this should be obvious - you can't define a command, add options
  ## to it and use it all on the fly.  However, if your command has no options
  ## or arguments, this *may* be a potential gotcha - just define your commands
  ## before you add them.
  mainCommand.commands[subCommand.key] = subCommand

proc addCommand*(parser: var TParser, subCommand: var TCommand) =
  ## Adds a command to a parser.  (Internally, this adds a subcommand to the
  ## default command, but these two things *should* look identical if you
  ## don't want to worry about subcommands too much.)
  ## See `addCommand(mainCommand: var TCommand, subCommand: var TCommand)` for
  ## details about the pass-by-reference in this proc.
  addCommand(parser.commands.mget(DEFAULT_COMMAND), subCommand)

# I'm commenting these procs out for now, because I'm not sure how useful they are,
# and if I've written them for this, I probably ought to write them again and again
# and bugger that.  Bugger that to pieces.  There's probably a template or macro I
# could be writing here, right?
#
# proc addCommands*(mainCommand: var TCommand, subCommands: varargs[TCommand]) =
#   for command in subCommands:
#     addCommand(mainCommand, command)

# proc addCommands*(parser: var TParser, subCommands: varargs[TCommand]) =
#   for command in subCommands:
#     addCommand(parser, command)

proc addArgument*(command: var TCommand, argument: TArgument) =
  command.arguments.add(argument)

proc addArgument*(parser: var TParser, argument: TArgument) =
  addArgument(parser.commands.mget(DEFAULT_COMMAND), argument)

proc addOption*(command: var TCommand, option: TOption) =
  for key in option.longs:
    command.optionslong[key] = option
  for key in option.shorts:
    command.optionsshort[key] = option

proc addOption*(parser: var TParser, option: TOption) =
  addOption(parser.commands.mget(DEFAULT_COMMAND), option)

iterator optsFromParser(parser: var TOptParser): TGetoptResult =
  while true:
    if parser.kind == cmdEnd:
      break
    else:
      var r = (kind: parser.kind, key: parser.key, val: parser.val)
      yield r
    parser.next
  
proc parseCmd(cmdName: string, command: var TCommand, parsedArgs: var TOptParser): PResult =
  # is there a sub-command we can push to?  Assume no sub-commands have a default command
  if parsedArgs.kind == cmdArgument and command.commands.contains(parsedArgs.key):
    parsedArgs.next()
    var superCmd = command.commands.mget(parsedArgs.key)
    return parseCmd(cmdName & "." & superCmd.key, superCmd, parsedArgs)

  var ncmdName: string
  if cmdName.startsWith("."):
    ncmdName = cmdName[1..len(cmdName)]
  else:
    ncmdName = cmdName

  var result = PResult(command: ncmdName,
                       arguments: newStringTable(modeCaseSensitive),
                       options: newStringTable(modeCaseSensitive))

  var foundArgs = 0
  for kind, key, val in parsedArgs.optsFromParser():
    case kind
    of cmdArgument:
      if len(command.arguments) > foundArgs:
        result.arguments[command.arguments[foundArgs].key] = key
        foundArgs += 1
      else:
        raise newException(EClarg, "Extra unwanted argument: " & key)
    of cmdLongOption:
      if command.optionslong.hasKey(key):
        result.options[command.optionslong[key].key] = val
      else:
        raise newException(EClarg, "Extra unwanted long-form option: --" & key)
    of cmdShortOption:
      if command.optionsshort.hasKey(key):
        result.options[command.optionsshort[key].key] = val
      else:
        raise newException(EClarg, "Extra unwanted short-form option: -" & key)
    of cmdEnd:
      assert(false) # This should never be possible

  # test if all arguments have been used up
  if foundArgs != len(command.arguments):
    raise newException(EClarg, "Not enough arguments, should be " & $len(command.arguments))

  return result

proc parse(parser: var TParser, parsedArgs: var TOptParser): PResult =
  parsedArgs.next # because broken, that's why.
  if (parsedArgs.kind == cmdArgument) and parser.commands.contains(parsedArgs.key):
    var command = parser.commands.mget(parsedArgs.key)
    return parseCmd(command.key, command, parsedArgs)
  else:
    return parseCmd("", parser.commands.mget(DEFAULT_COMMAND), parsedArgs)

proc parse*(parser: var TParser): PResult =
  ## Parses command line.  Options are taken from current cl args.
  var parsedArgs = initOptParser()
  return parse(parser, parsedArgs)

proc parse*(parser: var TParser, cmdline: seq[string]): PResult =
  ## Parses command line.  Options are passed as a list of pre-seperated
  ## arguments.
  var parsedArgs = initOptParser(cmdline)
  return parse(parser, parsedArgs)
