/*
draw_set_color(c_white)
draw_text(32, 120, "state " + string(gamestate))
draw_text(32, 140, "intower " + string(intower))
draw_text(32, 160, "roomready " + string(roomready))
draw_text(32, 180, "ointower " + string(instance_number(ointower)))
draw_text(32, 200, "obox " + string(instance_number(obox)))
draw_text(32, 220, "door " + string(instance_number(odoorhitbox)))
draw_text(32, 240, "main tower " + string(instance_number(omaintower)))
*/
if (poptimer > 0) {
    draw_set_halign(fa_center)
    draw_set_valign(fa_middle)
    draw_set_color(c_black)
    draw_rectangle(room_width * 0.5 - 176, 48, room_width * 0.5 + 176, 104, false)
    draw_set_color(c_white)
    draw_text(room_width * 0.5, 76, poptext)
}

var slotx = 32
var sloty = room_height - 96
var slotw = 72
var sloth = 72

for (var i = 0; i < 7; i += 1) {
    var xx = slotx + i * 80
    var yy = sloty

    draw_set_color(c_black)
    draw_rectangle(xx, yy, xx + slotw, yy + sloth, false)

    if (i < 6) {
        if (wireunlocked[i]) {
            var ws = wireuspr(i)
            if (ws != -1) {
                draw_sprite_ext(ws, 0, xx + 36, yy + 28, 1, 1, 0, c_white, 1)
            }
            draw_set_color(c_white)
            draw_text(xx + 8, yy + 48, string(i + 1))
            draw_text(xx + 8, yy + 60, string(floor(wirecounts[i])))

            if (selwire == i) {
                draw_set_color(c_lime)
                draw_rectangle(xx - 2, yy - 2, xx + slotw + 2, yy + sloth + 2, true)
            }
        }
    } else {
        draw_sprite(sbox, 0, xx + 36, yy + 28)
        draw_set_color(c_white)
        draw_text(xx + 8, yy + 60, string(boxinv))
    }
}

if (!debugnet) {
    exit
}

var r = getroomdatamaybe(worldx, worldy)
if (is_undefined(r)) {
    exit
}

var cols = floor(room_width / gridsize)
var rows = floor(room_height / gridsize)

for (var ix = 0; ix < cols; ix += 1) {
    for (var iy = 0; iy < rows; iy += 1) {
        var gx = ix * gridsize + gridoffx
        var gy = iy * gridsize + gridoffy
        var ck = cellkey(gx, gy)
        var sk = roomkey(worldx, worldy) + "|" + ck

        var left = gx - gridsize * 0.5
        var top = gy - gridsize * 0.5
        var right = gx + gridsize * 0.5
        var bottom = gy + gridsize * 0.5

        if (variable_struct_exists(debugseen, sk)) {
            draw_set_color(c_lime)
            draw_rectangle(left + 8, top + 8, right - 8, bottom - 8, true)
        }

        if (variable_struct_exists(r.wires, ck)) {
            draw_set_color(c_aqua)
            draw_circle(gx, gy, 8, false)
        }

        if (variable_struct_exists(r.towers, ck)) {
            draw_set_color(c_yellow)
            draw_rectangle(left + 16, top + 16, right - 16, bottom - 16, true)
        }

        if (r.maintowerx == gx && r.maintowery == gy) {
            draw_set_color(c_red)
            draw_circle(gx, gy, 16, false)
        }
    }
}
draw_set_color(c_white)
draw_text(32, 32, "room " + string(worldx) + "," + string(worldy))
draw_text(32, 52, "connected " + string(connectedcount) + "/" + string(towergoal))

if (!debugnet) {
    exit
}

var r = getroomdatamaybe(worldx, worldy)
if (is_undefined(r)) {
    exit
}

var wirenames = variable_struct_get_names(r.wires)
for (var i = 0; i < array_length(wirenames); i += 1) {
    var wk = wirenames[i]
    var w = variable_struct_get(r.wires, wk)

    draw_set_color(c_aqua)
    draw_circle(w.x, w.y, 10, false)

    if (variable_struct_exists(r.wireinsts, wk)) {
        var wireinst = variable_struct_get(r.wireinsts, wk)
        if (instance_exists(wireinst)) {
            draw_set_color(c_red)
            draw_line(w.x, w.y, wireinst.x, wireinst.y)
            draw_circle(wireinst.x, wireinst.y, 4, false)

            draw_set_color(c_white)
            draw_text(w.x + 8, w.y - 24, string(w.x) + "," + string(w.y))
            draw_text(wireinst.x + 8, wireinst.y - 8, string(wireinst.x) + "," + string(wireinst.y))
        }
    }
}