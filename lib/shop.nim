import tables
export tables.keys
export tables.values
export tables.pairs

type
  TClickerShop* = object
    items*: TTable[string, TShopItem]

  TShopItem = object
    name*: string
    price*: int
    level*: int
    cps*: int
    cpc*: int

proc newShopItem*(name: string, price: int, cps: int, cpc: int): TShopItem =
  return TShopItem(name: name, price: price, level: 0, cps: cps, cpc: cpc)

proc initShop*(): TClickerShop =
  var shop = TClickerShop(items: initTable[string, TShopItem]())
  shop.items["basic-cps"] = newShopItem("Basic CPS", 25, 5, 0)
  shop.items["basic-cpc"] = newShopItem("Basic CPC", 5, 0, 15)
  return shop

proc getCPC*(shop: var TClickerShop): int =
  var CPC = 0
  for key, item in shop.items.pairs:
    CPC += item.cpc
  return CPC
