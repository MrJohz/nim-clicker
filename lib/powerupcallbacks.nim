const
  BONUSNOTICKSAFTER = 60 * 10 # 10 minutes
  BONUSAFTERXTICKSTIMER = -1

proc bonusAfterXTicks(currTick, ticksLeft, level: int, cpc, cps: var float): float =
  result = 0
  if currTick > BONUSNOTICKSAFTER:
    cps *= (1.5 * level.float/2.float)

const
  DOUBLECPSTICKSTIMER = 60

proc doubleCPSBonus(currTick, ticksLeft, level: int, cpc, cps: var float): float =
  cps *= 2
