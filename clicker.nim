import "lib/game"
import "lib/clargs"
import strtabs

# proc main(printShop: bool): int =
  
#   var game = makeGame()
#   game.load()

#   game.clicks += 1
#   game.displayFull()

#   if printShop:
#     game.displayShop()

#   game.save()

#   return 0




when isMainModule:
  
  var parser = newParser()

  var clickCommand = newCommand("click")

  var shopCommand = newCommand("shop")
  var shopBuyCommand = newCommand("buy")
  shopBuyCommand.addArgument(newArgument("item", "The item to purchase"))
  shopCommand.addCommand(shopBuyCommand)
  var shopListCommand = newCommand("list")
  shopCommand.addCommand(shopListCommand)

  parser.addCommand(clickCommand)
  parser.addCommand(shopCommand)
  parser.addOption(newOption("hello", "An Argument", "hi", "hello", "h"))

  var result = parser.parse()
  echo("Args: " & $result.arguments)
  echo("Opts: " & $result.options)
  echo "Cmd:  " & result.command

  #quit(main(printShop=true))