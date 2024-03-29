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
    baseCPS*: float
    baseCPC*: float

  ShopItemSerial* = tuple[id: string, level: int]

proc toSerial*(item: ShopItem): ShopItemSerial =
  result = (id: item.id, level: item.level)


# Getters and setters

proc price*(item: ShopItem, level: int): int {.inline.} =
  return int(float(item.basePrice) * (pow(float(level), 1.1)))

proc price*(item: ShopItem): int {.inline.} =
  return item.price(item.level + 1)

proc cpc*(item: ShopItem, level: int): float {.inline.} =
  return item.baseCPC * (level / 2)

proc cpc*(item: ShopItem): float {.inline.} =
  return item.cpc(item.level)

proc cps*(item: ShopItem, level: int): float {.inline.} =
  return item.baseCPS * (level / 4)

proc cps*(item: ShopItem): float {.inline.} =
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
        result[len(result)-1].baseCPS = parseFloat(value)
      of "cpc":
        result[len(result)-1].baseCPC = parseFloat(value)
    else:
      discard

const
  ITEMSET*: seq[ShopItem] = makeShopItems("items.cfg")
