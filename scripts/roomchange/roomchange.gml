function roomchange(dx, dy) {
    if (!instance_exists(op)) {
        return
    }
    if (op.roomchanging) {
        return
    }

    op.roomchanging = true
    op.worldx += dx
    op.worldy += dy

    if (instance_exists(oplayer)) {
        if (dx < 0) {
            oplayer.x = room_width - op.gridoffx
        }
        else if (dx > 0) {
            oplayer.x = op.gridoffx
        }

        if (dy < 0) {
            oplayer.y = room_height - op.gridoffy
        }
        else if (dy > 0) {
            oplayer.y = op.gridoffy
        }
    }

    op.loadroom()
}