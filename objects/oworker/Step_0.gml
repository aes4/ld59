switch (phase) {
    case 0:
        timer -= 1
        if (timer <= 0) {
            phase = 1
        }
    break

    case 1:
        x -= walkspd
        if (x <= 1200) {
            phase = 2
            timer = waitmid
        }
    break

    case 2:
        timer -= 1
        if (timer <= 0) {
            phase = 3
        }
    break

    case 3:
        x += walkspd
        if (x >= 1658) {
            op.introplayed = true
            op.setstate("tower")
            instance_destroy()
        }
    break
}