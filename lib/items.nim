import os
import strutils
import math

type
  ShopItem* = object
    id*: string
    name*: string
    description*: string
    basePrice: int
    level*: int
    baseCPS*: int
    baseCPC*: int


# Getters and setters

proc price*(item: ShopItem, level: int): int {.inline.} =
  return int(float(item.basePrice) * (pow(float(level), 1.1)))

proc price*(item: ShopItem): int {.inline.} =
  return item.price(item.level + 1)

proc cpc*(item: ShopItem, level: int): int {.inline.} =
  return item.baseCPC * level

proc cpc*(item: ShopItem): int {.inline.} =
  return item.cpc(item.level)

proc cps*(item: ShopItem, level: int): int {.inline.} =
  return item.baseCPS * level

proc cps*(item: ShopItem): int {.inline.} =
  return item.cps(item.level)


# Compile-time procs

proc newShopItem(id: string): ShopItem {.compileTime.} =
  return ShopItem(id: id, name: "", description: "",
        basePrice: 0, level: 0, baseCPS: 0, baseCPC: 0)

proc makeShopItems(filename: string): seq[ShopItem] {.compileTime.} =
  result = @[]

  for ln in slurp("data" / filename).splitLines:
    var line: string
    if len(ln.strip()) > 0:
      line = ln.split('#')[0].strip()
    else:
      continue

    if line.startsWith("[") and line.endsWith("]"):
      result.add(newShopItem(line[1 .. -2]))
    elif len(line.strip()) > 0:
      var index = line.find({':', '='}) # can use either ':' or '='

      if index < 0: continue # no seperator found

      var key = line[0 .. index - 1].strip()
      var value = line[index + 1 .. -1].strip()
      case key
      of "name":
        result[len(result)-1].name = value
      of "description":
        result[len(result)-1].description = value
      of "price":
        result[len(result)-1].basePrice = parseInt(value)
      of "cps":
        result[len(result)-1].baseCPS = parseInt(value)
      of "cpc":
        result[len(result)-1].baseCPC = parseInt(value)
    else:
      discard

const
  ITEMSET*: seq[ShopItem] = makeShopItems("items.cfg")
