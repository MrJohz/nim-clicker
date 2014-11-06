import "shop"
import strutils
import tables
from marshal import nil
from json import EJsonParsingError
import streams
import os
import times

type
  bonusCallback = proc (currentTick: int, game: var ClickerGame)

  ClickerGame* = object
    clicks*: float
    time*: TTime
    shop*: ClickerShop
    activeBonus*: seq[tuple[id, ticksLeft: int]]
    registeredBonuses*: array[0..20, bonusCallback]

  ClickerGameSerial* = tuple[clicks: float, time: TTime, shop: ClickerShopSerial]

  PurchaseError* = enum
    peSuccess
    peInvalidKey
    peNotEnoughMoney

const ONE_SECOND = fromSeconds(1)

proc toSerial(game: var ClickerGame): ClickerGameSerial =
  var tup = (clicks: game.clicks, time: getTime(), shop: toSerial(game.shop))
  return tup

proc fromSerial(tup: ClickerGameSerial): ClickerGame =
  return ClickerGame(clicks: tup.clicks, time: tup.time, shop: fromSerial(tup.shop))

proc makeGame*(): ClickerGame =
  return ClickerGame(clicks: 0, time: getTime(), shop: initShop())

proc makeGame*(game: ClickerGameSerial): ClickerGame =
  return fromSerial(game)

proc getCurrentCPC*(game: var ClickerGame): float =
  return game.shop.getCPC()

proc getCurrentCPS*(game: var ClickerGame): float =
  return game.shop.getCPS()

proc load*(game: var ClickerGame, filename: string) =
  var tup: ClickerGameSerial
  try:
    var stream = newFileStream(filename, fmRead)
    if stream == nil:
      game = makeGame()
    else:
      marshal.load(stream, tup)
      game = makeGame(tup)
  except EIO, EJsonParsingError:
    game = makeGame()

proc save*(game: var ClickerGame, filename: string) =
  var tup = toSerial(game)
  marshal.store(newFileStream(filename, fmWrite), tup)

proc tickClick(game: var ClickerGame, tick: int) =
  var clkpersec = game.getCurrentCPS()



proc click*(game: var ClickerGame) =
  game.clicks += game.getCurrentCPC()
  let
    currentTime = getTime()
    timeDif = if currentTime > game.time: currentTime - game.time else: 0

  for tick in 0..timeDif:
    game.tickClick(tick.int)
  game.time = currentTime

proc makeShopTemplate*(shop: var ClickerShop): string =
  return shop.printAll()

proc buy*(game: var ClickerGame, arg: string): PurchaseError =
  if not game.shop.items.hasKey(arg):
    return peInvalidKey

  var item = game.shop.items.mget(arg)
  if item.price > int(game.clicks):
    return peNotEnoughMoney

  game.clicks -= float(item.price)
  item.level += 1

  game.shop.items[arg] = item
  return peSuccess
