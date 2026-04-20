boxid = noone

wavew = 320
waveh = 120

var guiw = display_get_gui_width()
var guih = display_get_gui_height()

wavex = (guiw - wavew) * 0.5
wavey = (guih - waveh) * 0.5 - 70

amp = 20
wavelength = 80

ampmin = 5
ampmax = 50
wavemin = 40
wavemax = 180

targetamp = irandom_range(10, 45)
targetwavelength = irandom_range(50, 160)

knobampx = wavex + 90
knobampy = wavey + waveh + 90
knobwavex = wavex + wavew - 90
knobwavey = wavey + waveh + 90

knobradius = 28
ampknobangle = -90
waveknobangle = -90

draggingamp = false
draggingwave = false

amptolerance = 3
wavetolerance = 6

solved = false
solvecueplayed = false
loopid = noone
solvedloopid = noone

preverror = -1
cooldown = 0
lastcue = noone
errorthresh = 4
sampletimer = 0
samplegap = 6
sampleerror = -1

function anglewrap180(_ang) {
    return ((_ang + 180) mod 360) - 180
}