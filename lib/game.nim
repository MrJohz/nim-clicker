import "shop"
import strutils
import tables
from marshal import nil
import streams
import os

type
  ClickerGame* = object
    clicks*: int
    shop*: ClickerShop

  ClickerGameSerial* = tuple[clicks: int, shop: ClickerShopSerial]

proc toSerial(game: var ClickerGame): ClickerGameSerial =
  var tup = (clicks: game.clicks, shop: toSerial(game.shop))
  return tup

proc fromSerial(tup: ClickerGameSerial): ClickerGame =
  return ClickerGame(clicks: tup.clicks, shop: fromSerial(tup.shop))

proc makeGame*(): ClickerGame =
  return ClickerGame(clicks: 0, shop: initShop())

proc makeGame*(game: ClickerGameSerial): ClickerGame =
  return fromSerial(game)

proc getCurrentCPC*(game: var ClickerGame): int =
  return game.shop.getCPC()

proc load*(game: var ClickerGame, filename: string) =
  var tup: ClickerGameSerial
  if not existsFile(filename):
    game = makeGame()
  else:
    marshal.load(newFileStream(filename, fmRead), tup)
    game = makeGame(tup)

proc save*(game: var ClickerGame, filename: string) =
  var tup = toSerial(game)
  marshal.store(newFileStream(filename, fmWrite), tup)

proc click*(game: var ClickerGame) =
  game.clicks += game.getCurrentCPC()

proc makeShopTemplate*(shop: var ClickerShop): string =
  return shop.printAll()
