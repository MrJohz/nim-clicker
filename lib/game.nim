import "shop"

import strutils
import tables
from marshal import nil
from json import EJsonParsingError
import streams
import os
import times
import sets
import hashes

# Deal with bonus tuples
type
  BonusTuple = tuple[id:string, ticksLeft:int]

proc hash(bonus: BonusTuple): THash =
  return hash(bonus.id)

type

  ActiveBonuses = TSet[tuple[id: string, ticksLeft: int]]

  ClickerGame* = object
    clicks*: float
    time*: TTime
    shop*: ClickerShop
    activeBonus*: ActiveBonuses

  ClickerGameSerial* = tuple
    clicks: float
    time: TTime
    shop: ClickerShopSerial
    activeBonus: seq[BonusTuple]

  PurchaseError* = enum
    peSuccess
    peInvalidKey
    peNotEnoughMoney
    peMaxLevel

const ONE_SECOND = fromSeconds(1)

proc toSerial(game: var ClickerGame): ClickerGameSerial =
  var bonuses: seq[BonusTuple] = @[]
  for bonus in game.activeBonus:
    bonuses.add(game.activeBonus.mget(bonus))

  var tup = (clicks: game.clicks, time: getTime(),
             shop: toSerial(game.shop), activeBonus: bonuses)
  return tup

proc fromSerial(tup: ClickerGameSerial): ClickerGame =
  var bonuses = initSet[BonusTuple](16)
  for bonus in tup.activeBonus:
    bonuses.incl(bonus)

  var game = ClickerGame(clicks: tup.clicks,
                         time: tup.time,
                         activeBonus: bonuses,
                         shop: fromSerial(tup.shop))
  return game

proc makeGame*(): ClickerGame =
  return ClickerGame(clicks: 0, time: getTime(), shop: initShop(), activeBonus: initSet[BonusTuple]())

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
  var cps = game.getCurrentCPS()
  var cpc = game.getCurrentCPC()

  var addition = 0.float

  for bonus in game.activeBonus:
    if bonus.ticksLeft == 0:  # if ticksLeft < 0, ignore it
      game.activeBonus.excl(bonus)
      continue

    var powerup = game.shop.powerups.mget(bonus.id)
    var bonusProc = powerup.callback
    let bonusAddition = bonusProc(tick, bonus.ticksLeft, powerup.level, cpc, cps)
    addition += bonusAddition

    var mBonus = game.activeBonus.mget(bonus)
    mBonus.ticksLeft -= 1

  game.clicks += cps
  game.clicks += addition

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
  if game.shop.items.hasKey(arg):
    var item = game.shop.items.mget(arg)
    if item.price > int(game.clicks):
      return peNotEnoughMoney

    game.clicks -= float(item.price)
    item.level += 1

    game.shop.items[arg] = item
    return peSuccess
  elif game.shop.powerups.hasKey(arg):
    var pwrup = game.shop.powerups.mget(arg)
    if pwrup.price.float > game.clicks:
      return peNotEnoughMoney
    elif pwrup.level == pwrup.maxLevel and pwrup.maxLevel > 0:
      return peMaxLevel

    game.clicks -= pwrup.price.float
    pwrup.level += 1

    if pwrup.autocall:
      game.activeBonus.incl((id: pwrup.id, ticksLeft: pwrup.tickLength))

    game.shop.powerups[arg] = pwrup
