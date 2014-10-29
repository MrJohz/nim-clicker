import terminal

type
  TColorEnabled* = enum
    tceAlways
    tceAuto
    tceNever

  TColorFormat* = enum
    tcfBold = (1, "\e[1m")
    tcfDim = (2, "\e[2m")
    tcfUnderline = (4, "\e[4m")

    tcfClearBold = (21, "\e[21m")
    tcfClearDim = (22, "\e[22m")
    tcfClearUnderline = (24, "\e[24m")

    tcfRed = (31, "\e[31m")
    tcfGreen = (32, "\e[32m")
    tcfYellow = (33, "\e[33m")
    tcfBlue = (34, "\e[34m")
    tcfMagenta = (35, "\e[35m")
    tcfCyan = (36, "\e[36m")
    tcfGray = (37, "\e[37m")
    tcfClearColor = (39, "\e[39m")

var colorEnabled = tceAuto

proc setColorEnabled*(ce: TColorEnabled) =
  colorEnabled = ce

proc getColorEnabled*(): TColorEnabled =
  return colorEnabled

proc getColor*(color: TColorFormat): string {.inline.} =
  when hostOS != "windows":
    case colorEnabled
    of tceAlways:
      return $color
    of tceAuto:
      return (if stdout.isatty(): $color else: "")
    of tceNever:
      return ""
  else:
    return ""
