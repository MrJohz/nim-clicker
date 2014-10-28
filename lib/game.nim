import "shop"
import strutils
import tables

type
  TClickerGame* = object
    clicks*: int
    shop*: TClickerShop

proc makeGame*(): TClickerGame =
  return TClickerGame(clicks: 0, shop: initShop())

proc getCurrentCPC*(game: var TClickerGame): int =
  return game.shop.getCPC()

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

proc click*(game: var TClickerGame) =
  game.clicks += game.getCurrentCPC()

proc makeShopTemplate*(shop: var TClickerShop): string =
  return shop.printAll()
