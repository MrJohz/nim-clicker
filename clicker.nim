import "./lib/game"
import "./lib/clargs"
from "./lib/printout" import nil
import strtabs
import tables

const FILENAME = "clicks.json"

proc click(game: var ClickerGame, args: PResult): int =
  if args.options.hasKey("showGame"):
    echo game.clicks

proc shop(game: var ClickerGame, args: PResult): int =
  case args.command
  of "shop":
    echo "Clicks: ", game.clicks
    echo game.shop.makeShopTemplate()
  of "shop.buy":
    for arg in args.multargs["items"]:
      let err = game.buy(arg)
      case err
      of peNotEnoughMoney:
        echo "Error: Not enough money to purchase ", arg
      of peInvalidKey:
        echo "Error: Item ", arg, " does not exist"
      of peMaxLevel:
        echo "Error: Item ", arg, " is at the max level"
      of peSuccess:
        discard

proc use(game: var ClickerGame, args: PResult): int =
  let err = game.use(args.arguments["powerup"])
  case err
  of ueTooFast:
    echo "Error: Wait for the cooldown!"
  of ueNotBought:
    echo "You haven't bought that powerup"
  of ueUnknownItem:
    echo "That powerup doesn't exist"
  of ueSuccess:
    discard

proc help(game: var ClickerGame, args:PResult): int {.discardable.} =
  result = 0

  echo "The Clicker Game"
  echo ""
  echo "Every time you run this program, you get clicks."
  echo ""
  echo "Run `clicker -s` to see how many clicks you have."
  echo ""
  echo "Run `clicker shop` to find out what you can buy,"
  echo "and `clicker shop buy <id-name>` to buy the item"
  echo "with  your clicks."
  echo ""
  echo "Run `clicker use` to use the powerups you've bought."
  echo "(Note that some powerups are used automatically,"
  echo "and last for the length of the game.)"
  echo ""
  echo "Built (badly) with Nim by Johz"

proc main(args: PResult): int =
  result = 0 # default return code

  var game = makeGame()
  game.load(FILENAME)

  game.click()

  case args.command
  of "":
    result = click(game, args)
  of "shop", "shop.buy":
    result = shop(game, args)
  of "help":
    result = help(game, args)
  of "use":
    result = use(game, args)
  else:
    echo "Invalid command!"
    help(game, args)
    result = 1

  game.save(FILENAME)

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

  # use command
  var useCommand = newCommand("use")
  useCommand.addArgument(newArgument("powerup", "Powerup to use"))

  # help command
  var helpCommand = newCommand("help")

  # add all commands
  clParser.addCommand(shopCommand)
  clParser.addCommand(helpCommand)
  clParser.addCommand(useCommand)
  return clParser

when isMainModule:
  var parser = constructCLParser()
  let parseResult = parser.parse()
  quit(main(parseResult))
