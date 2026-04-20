var mx = device_mouse_x_to_gui(0)
var my = device_mouse_y_to_gui(0)

if (mouse_check_button_pressed(mb_left)) {
    if (point_distance(mx, my, knobampx, knobampy) <= knobradius + 10) {
        draggingamp = true
    }
    else if (point_distance(mx, my, knobwavex, knobwavey) <= knobradius + 10) {
        draggingwave = true
    }
}

if (mouse_check_button_released(mb_left)) {
    draggingamp = false
    draggingwave = false
}

if (draggingamp) {
    var ang = point_direction(knobampx, knobampy, mx, my)
    ampknobangle = clamp(anglewrap180(ang), -135, 135)
    var t = (ampknobangle + 135) / 270
    amp = lerp(ampmin, ampmax, t)
}

if (draggingwave) {
    var ang2 = point_direction(knobwavex, knobwavey, mx, my)
    waveknobangle = clamp(anglewrap180(ang2), -135, 135)
    var t2 = (waveknobangle + 135) / 270
    wavelength = lerp(wavemin, wavemax, t2)
}

var ampok = abs(amp - targetamp) <= amptolerance
var waveok = abs(wavelength - targetwavelength) <= wavetolerance
solved = ampok && waveok

var totalerrorraw = abs(amp - targetamp) + abs(wavelength - targetwavelength)
var knobmoved = draggingamp || draggingwave

if (cooldown > 0) {
    cooldown -= 1
}

if (knobmoved && !solved) {
    sampletimer += 1

    var shouldsample = false

    if (mouse_check_button_pressed(mb_left)) {
        shouldsample = true
    }

    if (sampletimer >= samplegap) {
        shouldsample = true
        sampletimer = 0
    }

    if (shouldsample) {
        if (sampleerror >= 0 && cooldown <= 0) {
            var errordelta = sampleerror - totalerrorraw

            if (abs(errordelta) >= errorthresh) {
                if (lastcue != noone) {
                    audio_stop_sound(lastcue)
                    lastcue = noone
                }

                if (errordelta > 0) {
                    lastcue = audio_play_sound(ahot, 1, false)
                }
                else if (errordelta < 0) {
                    lastcue = audio_play_sound(acold, 1, false)
                }

                cooldown = 8
            }
        }

        sampleerror = totalerrorraw
    }
}
else {
    sampletimer = 0
    sampleerror = totalerrorraw
}

if (solved) {
    if (!solvecueplayed) {
        solvecueplayed = true

        if (lastcue != noone) {
            audio_stop_sound(lastcue)
            lastcue = noone
        }

        audio_play_sound(adone, 2, false)

        if (instance_exists(boxid)) {
            boxid.active = true
            boxid.waveopen = false
            op.onsolvebox(boxid)
        }

        instance_destroy()
    }
}