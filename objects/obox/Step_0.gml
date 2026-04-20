hoverphase += hoverspd

var bob = sin(hoverphase) * hoveramp
y = basey + bob

if (instance_exists(shadowid)) {
    shadowid.x = x
    shadowid.y = basey + shadowoff

    var t = (bob + hoveramp) / (hoveramp * 2)
    shadowid.image_xscale = 1.15 - t * 0.25
    shadowid.image_yscale = 1.15 - t * 0.25
    shadowid.image_alpha = 0.55 - t * 0.15
}

if (mouse_check_button_pressed(mb_left) && point_distance(mouse_x, mouse_y, x, y) < 48) {
    if (!active && !instance_exists(owave)) {
        var w = instance_create_layer(room_width * 0.5, room_height * 0.5, "Instances", owave)
        w.boxid = id
        waveopen = true
    }
    else if (active) {
        op.pushpopup(word)
    }
}