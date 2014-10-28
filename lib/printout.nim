import terminal

type
  TColorEnabled* = enum
    tceAlways
    tceAuto
    tceNever

var colorEnabled = tceAuto

proc setColorEnabled*(ce: TColorEnabled) =
  colorEnabled = ce

proc getColorEnabled*(): TColorEnabled =
  return colorEnabled

template makeTerminalColors(color: expr, key: string) {.immediate.} =
  const `color C` = key
  when hostOS != "windows":
    proc color*(): string {.inline.} =
      if colorEnabled == tceAlways:
        return `color C`
      elif colorEnabled == tceAuto and stdout.isatty:
        return `color C`
      else:
        return ""
  else:
    proc color*(): string {.inline.} =
      return ""

# font formatting
makeTerminalColors(BOLD, "\e[1m")
makeTerminalColors(DIM, "\e[2m")
makeTerminalColors(UNDERLINE, "\e[4m")

makeTerminalColors(CLEARBOLD, "\e[21m")
makeTerminalColors(CLEARDIM, "\e[22m")
makeTerminalColors(CLEARUNDERLINE, "\e[24m")

# color formatting
makeTerminalColors(RED, "\e[31m")
makeTerminalColors(GREEN, "\e[32m")
makeTerminalColors(YELLOW, "\e[33m")
makeTerminalColors(BLUE, "\e[34m")
makeTerminalColors(MAGENTA, "\e[35m")
makeTerminalColors(CYAN, "\e[36m")
makeTerminalColors(GRAY, "\e[37m")

makeTerminalColors(CLEARCOLOR, "\e[39m")

