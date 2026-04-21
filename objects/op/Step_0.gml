if (gamestate == "intro" && !intower && room == main) {
    startintro()
}

if (room == main && gamestate == "world" && !intower && !roomready) {
    loadroom()
    checknet()
}

if (room == main) {
    if (!instance_exists(owave)) {
        if (!intower && gamestate == "world") {
            if (mouse_check_button_pressed(mb_left)) {
                placewiremouse()
            }
        } else if (intower) {
            tryplacebox()
        }
    }
/*
    if (keyboard_check_pressed(ord("1")) && wireunlocked[0]) selwire = 0
    if (keyboard_check_pressed(ord("2")) && wireunlocked[1]) selwire = 1
    if (keyboard_check_pressed(ord("3")) && wireunlocked[2]) selwire = 2
    if (keyboard_check_pressed(ord("4")) && wireunlocked[3]) selwire = 3
    if (keyboard_check_pressed(ord("5")) && wireunlocked[4]) selwire = 4
    if (keyboard_check_pressed(ord("6")) && wireunlocked[5]) selwire = 5
*/
/*
    if (keyboard_check_pressed(ord("J"))) jumproom(-1, 0)
    if (keyboard_check_pressed(ord("K"))) jumproom(0, -1)
    if (keyboard_check_pressed(ord("L"))) jumproom(0, 1)
    if (keyboard_check_pressed(ord("O"))) jumproom(1, 0)
*/
    if (keyboard_check_pressed(ord("Q")) && intower) {
        exittower()
        playmusic(Forest)
    }
}

if (keyboard_check_pressed(ord("Z"))) {
    game_end()
}

stepwiregain()
processpopup()