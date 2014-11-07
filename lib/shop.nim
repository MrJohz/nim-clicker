import tables
import os
import strutils
import pegs

import "items"
export items.price
export items.cpc
export items.cps

import "powerups"
export powerups.price

from "printout" import getColor

type
  ClickerShop* = object
    items*: TTable[string, ShopItem]
    powerups*: TTable[string, Powerup]

  ClickerShopSerial* = tuple[items: seq[ShopItemSerial], powerups: seq[PowerupSerial]]

proc toSerial*(shop: ClickerShop): ClickerShopSerial =
  var items: seq[ShopItemSerial] = @[]
  for item in shop.items.values:
    items.add(toSerial(item))
  var powerups: seq[PowerupSerial] = @[]
  for pwrup in shop.powerups.values:
    powerups.add(toSerial(pwrup))
  var tup = (items: items, powerups: powerups)
  return tup

proc initShop*(): ClickerShop =
  var shop = ClickerShop(items: initTable[string, ShopItem](), powerups: initTable[string, Powerup]())
  for item in items.ITEMSET:
    shop.items[item.id] = item
  for item in powerups.POWERUPSET:
    shop.powerups[item.id] = item

  return shop

proc fromSerial*(tup: ClickerShopSerial): ClickerShop =
  var shop = initShop()
  for item in tup.items:
    shop.items.mget(item.id).level = item.level

  for powerup in tup.powerups:
    shop.powerups.mget(powerup.id).level = powerup.level

  return shop

proc getCPC*(shop: var ClickerShop): float =
  result = 1.0 # base clicks

  for item in shop.items.values():
    result += item.cpc

proc getCPS*(shop: var ClickerShop): float =
  result = 0.0

  for item in shop.items.values():
    result += item.cps

proc printAll*(shop: var ClickerShop): string =
  var strs = @[getColor(printout.tcfBold), "Items:\n\n",
              getColor(printout.tcfClearBold)]

  for item in shop.items.values():
    strs.add("  " & getColor(printout.tcfBold) & getColor(printout.tcfBlue))
    strs.add(item.name)
    strs.add(getColor(printout.tcfClearBold) & getColor(printout.tcfClearColor))
    strs.add(" (" & getColor(printout.tcfUnderline))
    strs.add(item.id)
    strs.add(getColor(printout.tcfClearUnderline) & ")\n")
    strs.add("    " & getColor(printout.tcfDim))
    strs.add(item.description)
    strs.add(" [level: " & $item.level & "]")
    strs.add(getColor(printout.tcfClearDim) & "\n")
    strs.add("    Price: ")
    strs.add($item.price)
    strs.add(" clicks\n")
    if item.baseCPC > 0:
      strs.add("    Click bonus: ")
      strs.add($item.cpc(item.level + 1))
      strs.add("\n\n")
    if item.baseCPS > 0:
      strs.add("    Idle bonus: ")
      strs.add($item.cps(item.level + 1))
      strs.add("\n\n")

  strs.add(getColor(printout.tcfBold) & "Powerups:\n\n" & getColor(printout.tcfClearBold))
  for item in shop.powerups.values():
    strs.add("  " & getColor(printout.tcfBold) & getColor(printout.tcfBlue))
    strs.add(item.name)
    strs.add(getColor(printout.tcfClearBold) & getColor(printout.tcfClearColor))
    strs.add(" (" & getColor(printout.tcfUnderline))
    strs.add(item.id)
    strs.add(getColor(printout.tcfClearUnderline) & ")\n")
    strs.add("    " & getColor(printout.tcfDim))
    strs.add(item.description)
    strs.add(" [level: " & $item.level)
    if item.maxLevel > 0:
      strs.add("/" & $item.maxLevel)
    strs.add("]")
    strs.add(getColor(printout.tcfClearDim) & "\n")
    strs.add("    Price: ")
    strs.add($item.price)
    strs.add(" clicks\n")

  return strs.join("").strip() & "\n"
