import "./lib/game"
import "./lib/clargs"
from "./lib/printout" import nil
import strtabs
import tables

proc click(game: var TClickerGame, args: PResult): int =
  if args.options.hasKey("showGame"):
    echo game.clicks

proc shop(game: var TClickerGame, args: PResult): int =
  case args.command
  of "shop":
    echo game.shop.makeShopTemplate()
  of "shop.buy":
    for arg in args.multargs["items"]:
      game.shop.items.mget(arg).level += 1


proc help(game: var TClickerGame, args:PResult): int {.discardable.} =
  result = 0

proc main(args: PResult): int =
  result = 0 # default return code

  var game = makeGame()
  game.load()

  game.click()

  case args.command
  of "":
    result = click(game, args)
  of "shop", "shop.buy":
    result = shop(game, args)
  of "help":
    result = help(game, args)
  else:
    echo "Invalid command!"
    help(game, args)
    result = 1

  game.save()

proc isColorEnabled(inp: string) =
  if inp == "off":
    printout.setColorEnabled(printout.tceNever)
  elif inp == "auto":
    printout.setColorEnabled(printout.tceAuto)
  elif inp == "always":
    printout.setColorEnabled(printout.tceAlways)

proc constructCLParser(): TParser =
  var clParser = newParser()

  # default command
  clParser.addOption(newOption("help",
        "Display help", ["h", "help"]))
  clParser.addOption(newOption("showGame",
        "Display", ["s", "show"]))

  clParser.addGreedyOption(newOption("setColors",
        "Set color usage", ["set-color"], isColorEnabled))

  # shop command
  var shopCommand = newCommand("shop")

  # shop.buy command
  var shopBuyCommand = newCommand("buy")
  shopBuyCommand.addArgument(newArgument("items",
        "Items to purchase", vargs=true))
  shopCommand.addCommand(shopBuyCommand)

  # help command
  var helpCommand = newCommand("help")

  # add all commands
  clParser.addCommand(shopCommand)
  clParser.addCommand(helpCommand)
  return clParser

when isMainModule:
  var parser = constructCLParser()
  let parseResult = parser.parse()
  quit(main(parseResult))
