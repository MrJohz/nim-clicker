import math

type

  PowerupCallback* = proc (currTick, ticksLeft, level: int, cpc, cps: var float): float

  Powerup* = object
    callback*: PowerupCallback
    ticklength*: int
    id*: string
    name*: string
    description*: string
    autocall*: bool
    basePrice*: float
    level*: int
    maxLevel*: int

  PowerupSerial* = tuple[id: string, level: int]

proc toSerial*(powerup: Powerup): PowerupSerial =
  return (id: powerup.id, level: powerup.level)

proc price*(item: Powerup, level: int): int {.inline.} =
  return int(float(item.basePrice) * (pow(float(level), 1.1)))

proc price*(item: Powerup): int {.inline.} =
  return item.price(item.level + 1)

include "powerupcallbacks"

proc makePowerups(): array[2, Powerup] {.compileTime.} =

  result[0] = Powerup(callback: bonusAfterXTicks,
                      ticklength: BONUSAFTERXTICKSTIMER,
                      id: "slowdown",
                      name: "Slowdown",
                      description: "Get more clicks if you leave the timer for a while",
                      autocall: true,
                      basePrice: 557,
                      level: 0,
                      maxLevel: -1)

  result[1] = Powerup(callback: doubleCPSBonus,
                      ticklength: DOUBLECPSTICKSTIMER,
                      id: "doubler",
                      name: "Doubler",
                      description: "Use this to double your CPS for 60 seconds",
                      autocall: false,
                      basePrice: 853,
                      level: 0,
                      maxLevel: 1)

const POWERUPSET* = makePowerups()
