var pad = 80
var bgx1 = wavex - pad
var bgy1 = wavey - 60
var bgx2 = wavex + wavew + pad
var bgy2 = knobampy + knobradius + 60

draw_set_color(c_black)
draw_rectangle(bgx1, bgy1, bgx2, bgy2, false)

draw_set_color(make_color_rgb(20, 20, 28))
draw_rectangle(wavex, wavey, wavex + wavew, wavey + waveh, false)

draw_set_color(c_dkgray)
draw_line(wavex, wavey + waveh * 0.5, wavex + wavew, wavey + waveh * 0.5)

var prevx = wavex
var prevy = wavey + waveh * 0.5
draw_set_color(c_aqua)

for (var i = 0; i <= wavew; i += 4) {
    var px = wavex + i
    var py = wavey + waveh * 0.5 + sin((i / wavelength) * pi * 2) * amp
    if (i > 0) draw_line(prevx, prevy, px, py)
    prevx = px
    prevy = py
}

function drawknob(_x, _y, _r, _ang) {
    draw_set_color(c_gray)
    draw_circle(_x, _y, _r, false)
    draw_set_color(c_white)
    var px = _x + lengthdir_x(_r - 6, _ang)
    var py = _y + lengthdir_y(_r - 6, _ang)
    draw_line(_x, _y, px, py)
    draw_circle(px, py, 3, false)
}

drawknob(knobampx, knobampy, knobradius, ampknobangle)
drawknob(knobwavex, knobwavey, knobradius, waveknobangle)