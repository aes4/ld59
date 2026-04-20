if (mouse_check_button_pressed(mb_left)) {
    if (point_in_rectangle(mouse_x, mouse_y, x - sprite_width * 0.5, y - sprite_height * 0.5, x + sprite_width * 0.5, y + sprite_height * 0.5)) {
        op.setstate("intro")
        room_goto(main)
    }
}