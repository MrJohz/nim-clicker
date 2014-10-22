import "lib/game"

proc main(displayFull: bool): int =
  
  var game = makeGame()
  game.load()

  game.clicks += 1
  game.displayFull()

  game.save()

  return 0


when isMainModule:
  quit(main(displayFull=true))