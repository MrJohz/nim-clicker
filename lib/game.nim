import "shop"
import strutils

type
  TClickerGame = object
    clicks*: int
    shop*: TClickerShop

proc makeGame*(): TClickerGame =
  return TClickerGame(clicks: 0, shop: initShop())

proc load*(game: var TClickerGame) =
  var f: string

  try:
    f = readFile("clicks.txt")
  except EIO:
    game.clicks = 0
    return

  game.clicks = parseInt(f)

proc save*(game: var TClickerGame) =
  var f = $(game.clicks)
  writeFile("clicks.txt", f)

proc displayFull*(game: var TClickerGame) =
  echo "clicks: " & $game.clicks

proc displayShop*(game: var TClickerGame) =
  echo "Shop:"
  for id, item in game.shop.items.pairs:
    echo item.name & " -- " & $item.price
