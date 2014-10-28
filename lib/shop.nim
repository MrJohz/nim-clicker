import tables
import os
import strutils
import pegs

import "items"
export items.price
export items.cpc
export items.cps

from "printout" import nil

type
  TClickerShop* = object
    items*: TTable[string, ShopItem]

proc initShop*(): TClickerShop =
  var shop = TClickerShop(items: initTable[string, ShopItem]())
  for item in items.ITEMSET:
    shop.items[item.id] = item
  return shop

proc getCPC*(shop: var TClickerShop): int =
  result = 1 # base clicks

  for item in shop.items.values():
    result += item.cpc

proc printAll*(shop: var TClickerShop): string =
  var strs = @[printout.BOLD(), "Items:\n\n", printout.CLEARBOLD()]
  for item in shop.items.values():
    strs.add("  " & printout.BOLD() & printout.BLUE())
    strs.add(item.name)
    strs.add(printout.CLEARBOLD() & printout.CLEARCOLOR() & " (" & printout.UNDERLINE())
    strs.add(item.id)
    strs.add(printout.CLEARUNDERLINE() & ")\n")
    strs.add("    " & printout.DIM())
    strs.add(item.description)
    strs.add(printout.CLEARDIM() & "\n")
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

  return strs.join("").strip() & "\n"
