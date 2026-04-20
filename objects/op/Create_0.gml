thanks = room_speed * 8
persistent = true

if (instance_number(op) > 1) {
    instance_destroy()
    exit
}

towerboxes = []
introplayed = false
introdelay = room_speed * 12
workerid = noone
debugnet = false
debugseen = {}
worldx = 0
worldy = 0
roomw = room_width
roomh = room_height
roomchanging = false
roomready = false
worldseed = 59001

gridsize = 64
gridoffx = 32
gridoffy = 32

wirecount = 100
towergoal = 6
connectedcount = 0
gamewin = false

poptext = ""
poptimer = 0
popdur = room_speed * 3
popqueue = []

roomdata = {}

towerrad = 3
treeturn = 8

gamestate = "menu"
musicid = noone
mastervol = 0.8
currentsong = -1

wiretimer = 0
wiregain = 0
wirestep = room_speed
wirecounts = [8, 0, 0, 0, 0, 0]
wireaccum = [0, 0, 0, 0, 0, 0]
//wirerates = [64, 32, 16, 8, 4, 2] // real
wirerates = [64, 64, 64, 64, 64, 64]  // for testing
wireunlocked = [false, false, false, false, false, false]
selwire = 0

boxinv = 1
nextboxtier = 0
boxesolved = 0
thanksdone = false
intower = false

sentencewords = ["Creatures", "from", "below", "will", "surface,", "prepare"]
nextwordi = 0

function shufflewords() {
    for (var i = array_length(sentencewords) - 1; i > 0; i -= 1) {
        var j = irandom(i)
        var t = sentencewords[i]
        sentencewords[i] = sentencewords[j]
        sentencewords[j] = t
    }
}

function wireword(n) {
    switch (n) {
        case 0: return "one"
        case 1: return "two"
        case 2: return "three"
        case 3: return "four"
        case 4: return "five"
        case 5: return "six"
    }
    return "one"
}

function wireuspr(n) {
    switch (n) {
        case 0: return swireuone
        case 1: return swireutwo
        case 2: return swireuthree
        case 3: return swireufour
        case 4: return swireufive
        case 5: return swireusix
    }
    return swireuone
}

function wirecspr(n) {
    switch (n) {
        case 0: return swirecone
        case 1: return swirectwo
        case 2: return swirecthree
        case 3: return swirecfour
        case 4: return swirecfive
        case 5: return swirecsix
    }
    return swirecone
}

function pushtowerbox(px, py, ptier, pword, pactive) {
    array_push(towerboxes, {
        x: px,
        y: py,
        tier: ptier,
        word: pword,
        active: pactive
    })
}

function savetowerboxes() {
    towerboxes = []

    with (obox) {
        op.pushtowerbox(x, basey, tier, word, active)
    }
}

function cleartowerinterior() {
    with (obox) instance_destroy()
    with (oboxshadow) instance_destroy()
    with (ointower) instance_destroy()
    with (oworker) instance_destroy()
}

function loadtowerinterior() {
    clearroomvisuals()
    cleartowerinterior()

    instance_create_layer(0, 0, "Instances", ointower)

    for (var i = 0; i < array_length(towerboxes); i += 1) {
        var tb = towerboxes[i]
        var b = instance_create_layer(tb.x, tb.y, "Instances", obox)
        b.basey = tb.y
        b.tier = tb.tier
        b.word = tb.word
        b.active = tb.active
    }

    if (!introplayed) {
        workerid = instance_create_layer(1658, 300, "Instances", oworker)
    }

    intower = true
    roomready = true
}

function entertower() {
    clearroomvisuals()
    roomready = true
    intower = true

    if (instance_exists(oplayer)) {
        oplayer.x = room_width * 0.5
        oplayer.y = room_height * 0.75
        oplayer.vx = 0
        oplayer.vy = 0
    }

    if (!introplayed) {
        setstate("intro")
    } else {
        setstate("tower")
    }

    loadtowerinterior()
}

function exittower() {
    savetowerboxes()
    cleartowerinterior()

    intower = false
    setstate("world")
    roomready = false

    loadroom()
    checknet()

    var r = getroomdata(0, 0)
    if (instance_exists(oplayer)) {
        oplayer.x = r.maintowerx + gridsize * 6
        oplayer.y = r.maintowery
        oplayer.vx = 0
        oplayer.vy = 0
    }
}

function startintro() {
    worldx = 0
    worldy = 0
    roomready = true
    entertower()
}

function startwiregain(tier) {
    if (tier < 0 || tier > 5) {
        return
    }
    wireunlocked[tier] = true
    pushpopup("wire type " + string(tier + 1) + " active")
}

function stepwiregain() {
    for (var i = 0; i < 6; i += 1) {
        if (wireunlocked[i]) {
            wireaccum[i] += wirerates[i] / 60 / room_speed
            while (wireaccum[i] >= 1) {
                wireaccum[i] -= 1
                wirecounts[i] += 1
            }
        }
    }
}

function nextboxword() {
    if (nextwordi >= array_length(sentencewords)) {
        return "..."
    }
    var w = sentencewords[nextwordi]
    nextwordi += 1
    return w
}

function onconnecttower() {
    boxinv += 1
    //pushpopup("box gained")
}

function onsolvebox(boxref) {
    var tier = boxref.tier
    startwiregain(tier)

    boxesolved += 1
    pushpopup(boxref.word)

    if (boxesolved >= 6 && !thanksdone) {
        thanksdone = true
        pushpopup("thanks for playing")
    }
}

function tryplacebox() {
    if (!intower) {
        return
    }
    if (boxinv <= 0) {
        return
    }
    if (nextboxtier > 5) {
        return
    }
    if (mouse_check_button_pressed(mb_left)) {
        var b = instance_create_layer(mouse_x, mouse_y, "Instances", obox)
        b.depth = -100
        b.tier = nextboxtier
        b.word = nextboxword()
        boxinv -= 1
        nextboxtier += 1
    }
}

function roomkey(wx, wy) {
    return string(wx) + "," + string(wy)
}

function cellkey(gx, gy) {
    return string(gx) + "," + string(gy)
}

function snapx(px) {
    return round((px - gridoffx) / gridsize) * gridsize + gridoffx
}

function snapy(py) {
    return round((py - gridoffy) / gridsize) * gridsize + gridoffy
}

function pushpopup(msg) {
    array_push(popqueue, msg)
}

function processpopup() {
    if (poptimer > 0) {
        poptimer -= 1
    } else {
        if (array_length(popqueue) > 0) {
            poptext = popqueue[0]
            array_delete(popqueue, 0, 1)

            if (poptext == "thanks for playing") {
                poptimer = thanksdur
            } else {
                poptimer = popdur
            }
        }
    }
}

function playmusic(snd) {
    if (currentsong == snd && musicid != noone && audio_is_playing(musicid)) {
        return
    }

    if (musicid != noone) {
        audio_stop_sound(musicid)
        musicid = noone
    }

    musicid = audio_play_sound(snd, 0, true)
    audio_sound_gain(musicid, mastervol, 0)
    currentsong = snd
}

function stopmusic() {
    if (musicid != noone) {
        audio_stop_sound(musicid)
        musicid = noone
    }
    currentsong = -1
}

function setstate(s) {
    gamestate = s
}

function makerdata(wx, wy) {
    var r = {
        trees: [],
        treecells: {},
        wires: {},
        wireinsts: {},
        towers: {},
        towerinsts: {},
        maintowerx: -1,
        maintowery: -1
    }

    var oldseed = random_get_seed()
    random_set_seed(worldseed + wx * 10007 + wy * 30011)

    var cols = floor(room_width / gridsize)
    var rows = floor(room_height / gridsize)
    var cx = room_width * 0.5
    var cy = room_height * 0.5

    for (var i = 0; i < 32; i += 1) {
        var gx = irandom_range(1, cols - 2) * gridsize + gridoffx
        var gy = irandom_range(1, rows - 2) * gridsize + gridoffy
        var ck = cellkey(gx, gy)

        if (!variable_struct_exists(r.treecells, ck)) {
            if (point_distance(gx, gy, cx, cy) > 160) {
                array_push(r.trees, {
                    x: gx,
                    y: gy,
                    ang: random_range(-treeturn, treeturn)
                })
                variable_struct_set(r.treecells, ck, true)
            }
        }
    }

    random_set_seed(oldseed)
    return r
}

function getroomdata(wx, wy) {
    var rk = roomkey(wx, wy)
    if (!variable_struct_exists(roomdata, rk)) {
        variable_struct_set(roomdata, rk, makerdata(wx, wy))
    }
    return variable_struct_get(roomdata, rk)
}

function getroomdatamaybe(wx, wy) {
    var rk = roomkey(wx, wy)
    if (!variable_struct_exists(roomdata, rk)) {
        return undefined
    }
    return variable_struct_get(roomdata, rk)
}

function cleartreecell(r, gx, gy) {
    var ck = cellkey(gx, gy)

    if (variable_struct_exists(r.treecells, ck)) {
        variable_struct_remove(r.treecells, ck)
    }

    for (var i = array_length(r.trees) - 1; i >= 0; i -= 1) {
        if (r.trees[i].x == gx && r.trees[i].y == gy) {
            array_delete(r.trees, i, 1)
        }
    }
}

function clearroomvisuals() {
    with (otree) instance_destroy()
    with (owire) instance_destroy()
    with (otower) instance_destroy()
    with (omaintower) instance_destroy()
}

function wireupdateone(r, gx, gy) {
    var wk = cellkey(gx, gy)
    if (!variable_struct_exists(r.wires, wk)) {
        return
    }
    if (!variable_struct_exists(r.wireinsts, wk)) {
        return
    }

    var hasu = variable_struct_exists(r.wires, cellkey(gx, gy - gridsize))
    var hasr = variable_struct_exists(r.wires, cellkey(gx + gridsize, gy))
    var hasd = variable_struct_exists(r.wires, cellkey(gx, gy + gridsize))
    var hasl = variable_struct_exists(r.wires, cellkey(gx - gridsize, gy))

    var wireinst = variable_struct_get(r.wireinsts, wk)
    if (!instance_exists(wireinst)) {
        return
    }

    var w = variable_struct_get(r.wires, wk)
    var tier = w.type

    wireinst.image_angle = 0

    if ((hasu && hasr) && !hasd && !hasl) {
        wireinst.sprite_index = wirecspr(tier)
        wireinst.image_angle = 0
    }
    else if ((hasr && hasd) && !hasu && !hasl) {
        wireinst.sprite_index = wirecspr(tier)
        wireinst.image_angle = 90
    }
    else if ((hasd && hasl) && !hasu && !hasr) {
        wireinst.sprite_index = wirecspr(tier)
        wireinst.image_angle = 180
    }
    else if ((hasl && hasu) && !hasr && !hasd) {
        wireinst.sprite_index = wirecspr(tier)
        wireinst.image_angle = 270
    }
    else if ((hasl || hasr) && !hasu && !hasd) {
        wireinst.sprite_index = wireuspr(tier)
        wireinst.image_angle = 90
    }
    else {
        wireinst.sprite_index = wireuspr(tier)
        wireinst.image_angle = 0
    }
}

function wireupdateneighbors(r, gx, gy) {
    wireupdateone(r, gx, gy)
    wireupdateone(r, gx - gridsize, gy)
    wireupdateone(r, gx + gridsize, gy)
}

function loadroom() {
    clearroomvisuals()

    var r = getroomdata(worldx, worldy)
    r.wireinsts = {}
    r.towerinsts = {}

    for (var i = 0; i < array_length(r.trees); i += 1) {
        var t = r.trees[i]
        var treeinst = instance_create_layer(t.x, t.y, "Instances", otree)
        treeinst.image_angle = t.ang
    }

    var towernames = variable_struct_get_names(r.towers)
    for (var i = 0; i < array_length(towernames); i += 1) {
        var tk = towernames[i]
        var tower = variable_struct_get(r.towers, tk)
        var towerinst = instance_create_layer(tower.x, tower.y, "Instances", otower)
        towerinst.image_blend = tower.powered ? c_aqua : c_white
        variable_struct_set(r.towerinsts, tk, towerinst)
    }

    if (r.maintowerx != -1 && r.maintowery != -1) {
        instance_create_layer(r.maintowerx, r.maintowery, "Instances", omaintower)
    }

    var wirenames = variable_struct_get_names(r.wires)
    for (var i = 0; i < array_length(wirenames); i += 1) {
        var wk = wirenames[i]
        var w = variable_struct_get(r.wires, wk)
        var wireinst = instance_create_layer(w.x, w.y, "Instances", owire)
        wireinst.image_blend = w.powered ? c_aqua : c_white
        variable_struct_set(r.wireinsts, wk, wireinst)
    }

    for (var i = 0; i < array_length(wirenames); i += 1) {
        var wk = wirenames[i]
        var w = variable_struct_get(r.wires, wk)
        wireupdateone(r, w.x, w.y)
    }

    roomready = true
    roomchanging = false
}

function placewiremouse() {
    if (selwire < 0 || selwire > 5) {
        return
    }
    if (wirecounts[selwire] <= 0) {
        return
    }

    var gx = snapx(mouse_x)
    var gy = snapy(mouse_y)

    if (gx < gridoffx || gx > room_width - gridoffx) {
        return
    }
    if (gy < gridoffy || gy > room_height - gridoffy) {
        return
    }

    var r = getroomdata(worldx, worldy)
    var wk = cellkey(gx, gy)

    if (variable_struct_exists(r.treecells, wk)) {
        return
    }
    if (variable_struct_exists(r.towers, wk)) {
        return
    }
    if (r.maintowerx == gx && r.maintowery == gy) {
        return
    }
    if (variable_struct_exists(r.wires, wk)) {
        return
    }

    variable_struct_set(r.wires, wk, {
        x: gx,
        y: gy,
        powered: false,
        type: selwire
    })

    var wireinst = instance_create_layer(gx, gy, "Instances", owire)
    variable_struct_set(r.wireinsts, wk, wireinst)

    wirecounts[selwire] -= 1
    wireupdateneighbors(r, gx, gy)
    checknet()
}

function placetower(wx, wy, gx, gy, word) {
    var r = getroomdata(wx, wy)
    var tk = cellkey(gx, gy)

    cleartreecell(r, gx, gy)

    if (variable_struct_exists(r.wires, tk)) {
        return false
    }
    if (variable_struct_exists(r.towers, tk)) {
        return false
    }
    if (r.maintowerx == gx && r.maintowery == gy) {
        return false
    }

    variable_struct_set(r.towers, tk, {
        x: gx,
        y: gy,
        connected: false,
        powered: false,
        word: word
    })

    if (room == main && gamestate == "world" && wx == worldx && wy == worldy) {
        var towerinst = instance_create_layer(gx, gy, "Instances", otower)
        variable_struct_set(r.towerinsts, tk, towerinst)
    }

    return true
}

function placemaintower(wx, wy, gx, gy) {
    var r = getroomdata(wx, wy)

    cleartreecell(r, gx, gy)

    if (variable_struct_exists(r.wires, cellkey(gx, gy))) {
        return false
    }
    if (variable_struct_exists(r.towers, cellkey(gx, gy))) {
        return false
    }

    r.maintowerx = gx
    r.maintowery = gy

    if (room == main && gamestate == "world" && wx == worldx && wy == worldy) {
        instance_create_layer(gx, gy, "Instances", omaintower)
    }

    return true
}

function stepnode(wx, wy, gx, gy, dx, dy) {
    var cols = floor(room_width / gridsize)
    var rows = floor(room_height / gridsize)

    var ix = round((gx - gridoffx) / gridsize)
    var iy = round((gy - gridoffy) / gridsize)

    ix += dx
    iy += dy

    var nwx = wx
    var nwy = wy

    if (ix < 0) {
        ix = cols - 1
        nwx -= 1
    }
    else if (ix >= cols) {
        ix = 0
        nwx += 1
    }

    if (iy < 0) {
        iy = rows - 1
        nwy -= 1
    }
    else if (iy >= rows) {
        iy = 0
        nwy += 1
    }

    var ngx = ix * gridsize + gridoffx
    var ngy = iy * gridsize + gridoffy

    return [nwx, nwy, ngx, ngy]
}

function normnode(wx, wy, gx, gy) {
    var cols = floor(room_width / gridsize)
    var rows = floor(room_height / gridsize)

    var ix = round((gx - gridoffx) / gridsize)
    var iy = round((gy - gridoffy) / gridsize)

    var nwx = wx
    var nwy = wy

    while (ix < 0) {
        ix += cols
        nwx -= 1
    }
    while (ix >= cols) {
        ix -= cols
        nwx += 1
    }

    while (iy < 0) {
        iy += rows
        nwy -= 1
    }
    while (iy >= rows) {
        iy -= rows
        nwy += 1
    }

    var ngx = ix * gridsize + gridoffx
    var ngy = iy * gridsize + gridoffy

    return [nwx, nwy, ngx, ngy]
}

function connecttowersnear(wx, wy, gx, gy) {
    for (var xx = -towerrad; xx <= towerrad; xx += 1) {
        for (var yy = -towerrad; yy <= towerrad; yy += 1) {
            var nd = normnode(wx, wy, gx + xx * gridsize, gy + yy * gridsize)
            var nwx = nd[0]
            var nwy = nd[1]
            var ngx = nd[2]
            var ngy = nd[3]

            if (hastower(nwx, nwy, ngx, ngy)) {
                var tr = getroomdata(nwx, nwy)
                var tk = cellkey(ngx, ngy)
                var tower = variable_struct_get(tr.towers, tk)

                tower.powered = true

                if (!tower.connected) {
                    tower.connected = true
                    onconnecttower()
                }

                variable_struct_set(tr.towers, tk, tower)
            }
        }
    }
}

function mainnearpowered(wx, wy, gx, gy) {
    var mainnode = findmain()
    if (mainnode[2] == -1) {
        return false
    }

    for (var xx = -towerrad; xx <= towerrad; xx += 1) {
        for (var yy = -towerrad; yy <= towerrad; yy += 1) {
            var nd = normnode(mainnode[0], mainnode[1], mainnode[2] + xx * gridsize, mainnode[3] + yy * gridsize)
            if (nd[0] == wx && nd[1] == wy && nd[2] == gx && nd[3] == gy) {
                return true
            }
        }
    }

    return false
}

function jumproom(dx, dy) {
    if (roomchanging) {
        return
    }

    worldx += dx
    worldy += dy

    if (instance_exists(oplayer)) {
        oplayer.x = room_width * 0.5
        oplayer.y = room_height * 0.5
        oplayer.vx = 0
        oplayer.vy = 0
    }

    loadroom()
    checknet()
}

function haswire(wx, wy, gx, gy) {
    var r = getroomdatamaybe(wx, wy)
    if (is_undefined(r)) {
        return false
    }
    return variable_struct_exists(r.wires, cellkey(gx, gy))
}

function hastower(wx, wy, gx, gy) {
    var r = getroomdatamaybe(wx, wy)
    if (is_undefined(r)) {
        return false
    }
    return variable_struct_exists(r.towers, cellkey(gx, gy))
}

function hasmain(wx, wy, gx, gy) {
    var r = getroomdatamaybe(wx, wy)
    if (is_undefined(r)) {
        return false
    }
    return r.maintowerx == gx && r.maintowery == gy
}

function findmain() {
    var rnames = variable_struct_get_names(roomdata)
    for (var i = 0; i < array_length(rnames); i += 1) {
        var rk = rnames[i]
        var r = variable_struct_get(roomdata, rk)
        if (r.maintowerx != -1 && r.maintowery != -1) {
            var comma = string_pos(",", rk)
            var wx = real(string_copy(rk, 1, comma - 1))
            var wy = real(string_delete(rk, 1, comma))
            return [wx, wy, r.maintowerx, r.maintowery]
        }
    }
    return [-9999, -9999, -1, -1]
}

function refreshconnectedvisuals() {
    var r = getroomdatamaybe(worldx, worldy)
    if (is_undefined(r)) {
        return
    }

    var tnames = variable_struct_get_names(r.towers)
    for (var i = 0; i < array_length(tnames); i += 1) {
        var tk = tnames[i]
        if (variable_struct_exists(r.towerinsts, tk)) {
            var towerinst = variable_struct_get(r.towerinsts, tk)
            var tower = variable_struct_get(r.towers, tk)
            if (instance_exists(towerinst)) {
                towerinst.image_blend = tower.connected ? c_aqua : c_white
            }
        }
    }
}

function clearpowered() {
    var rnames = variable_struct_get_names(roomdata)
    for (var i = 0; i < array_length(rnames); i += 1) {
        var r = variable_struct_get(roomdata, rnames[i])

        var wirenames = variable_struct_get_names(r.wires)
        for (var j = 0; j < array_length(wirenames); j += 1) {
            var wk = wirenames[j]
            var w = variable_struct_get(r.wires, wk)
            w.powered = false
            variable_struct_set(r.wires, wk, w)
        }

        var towernames = variable_struct_get_names(r.towers)
        for (var j = 0; j < array_length(towernames); j += 1) {
            var tk = towernames[j]
            var t = variable_struct_get(r.towers, tk)
            t.powered = false
            variable_struct_set(r.towers, tk, t)
        }
    }
}

function refreshwirevisuals() {
    var r = getroomdatamaybe(worldx, worldy)
    if (is_undefined(r)) {
        return
    }

    var wirenames = variable_struct_get_names(r.wires)
    for (var i = 0; i < array_length(wirenames); i += 1) {
        var wk = wirenames[i]
        if (variable_struct_exists(r.wireinsts, wk)) {
            var wireinst = variable_struct_get(r.wireinsts, wk)
            if (instance_exists(wireinst)) {
                wireinst.image_blend = c_white
            }
        }
    }
}

function refreshtowervisuals() {
    var r = getroomdatamaybe(worldx, worldy)
    if (is_undefined(r)) {
        return
    }

    var towernames = variable_struct_get_names(r.towers)
    for (var i = 0; i < array_length(towernames); i += 1) {
        var tk = towernames[i]
        if (variable_struct_exists(r.towerinsts, tk)) {
            var towerinst = variable_struct_get(r.towerinsts, tk)
            if (instance_exists(towerinst)) {
                towerinst.image_blend = c_white
            }
        }
    }
}

function recountconnected() {
    connectedcount = 0
    var rnames = variable_struct_get_names(roomdata)
    for (var i = 0; i < array_length(rnames); i += 1) {
        var r = variable_struct_get(roomdata, rnames[i])
        var tnames = variable_struct_get_names(r.towers)
        for (var j = 0; j < array_length(tnames); j += 1) {
            var tower = variable_struct_get(r.towers, tnames[j])
            if (tower.connected) {
                connectedcount += 1
            }
        }
    }
}

function checknet() {
    var mainnode = findmain()
    if (mainnode[2] == -1) {
        return
    }

    clearpowered()
    debugseen = {}

    var q = ds_queue_create()
    var seen = {}

    for (var xx = -towerrad; xx <= towerrad; xx += 1) {
        for (var yy = -towerrad; yy <= towerrad; yy += 1) {
            var nd = normnode(mainnode[0], mainnode[1], mainnode[2] + xx * gridsize, mainnode[3] + yy * gridsize)
            var nwx = nd[0]
            var nwy = nd[1]
            var ngx = nd[2]
            var ngy = nd[3]

            if (haswire(nwx, nwy, ngx, ngy) || hastower(nwx, nwy, ngx, ngy)) {
                var sk0 = roomkey(nwx, nwy) + "|" + cellkey(ngx, ngy)
                if (!variable_struct_exists(seen, sk0)) {
                    variable_struct_set(seen, sk0, true)
                    variable_struct_set(debugseen, sk0, true)

                    ds_queue_enqueue(q, nwx)
                    ds_queue_enqueue(q, nwy)
                    ds_queue_enqueue(q, ngx)
                    ds_queue_enqueue(q, ngy)

                    if (haswire(nwx, nwy, ngx, ngy)) {
                        var wr0 = getroomdata(nwx, nwy)
                        var wk0 = cellkey(ngx, ngy)
                        var w0 = variable_struct_get(wr0.wires, wk0)
                        w0.powered = true
                        variable_struct_set(wr0.wires, wk0, w0)

                        connecttowersnear(nwx, nwy, ngx, ngy)
                    }

                    if (hastower(nwx, nwy, ngx, ngy)) {
                        var tr0 = getroomdata(nwx, nwy)
                        var tk0 = cellkey(ngx, ngy)
                        var tower0 = variable_struct_get(tr0.towers, tk0)

                        tower0.powered = true

                        if (!tower0.connected) {
                            tower0.connected = true
                            onconnecttower()
                        }

                        variable_struct_set(tr0.towers, tk0, tower0)
                    }
                }
            }
        }
    }

    while (!ds_queue_empty(q)) {
        var wx = ds_queue_dequeue(q)
        var wy = ds_queue_dequeue(q)
        var gx = ds_queue_dequeue(q)
        var gy = ds_queue_dequeue(q)

        for (var i = 0; i < 4; i += 1) {
            var dx = 0
            var dy = 0

            switch (i) {
                case 0: dx = 1; break
                case 1: dx = -1; break
                case 2: dy = 1; break
                case 3: dy = -1; break
            }

            var nxt = stepnode(wx, wy, gx, gy, dx, dy)
            var nwx = nxt[0]
            var nwy = nxt[1]
            var ngx = nxt[2]
            var ngy = nxt[3]

            var sk = roomkey(nwx, nwy) + "|" + cellkey(ngx, ngy)
            if (variable_struct_exists(seen, sk)) {
                continue
            }

            if (haswire(nwx, nwy, ngx, ngy) || hastower(nwx, nwy, ngx, ngy)) {
                variable_struct_set(seen, sk, true)
                variable_struct_set(debugseen, sk, true)

                ds_queue_enqueue(q, nwx)
                ds_queue_enqueue(q, nwy)
                ds_queue_enqueue(q, ngx)
                ds_queue_enqueue(q, ngy)

                if (haswire(nwx, nwy, ngx, ngy)) {
                    var wr = getroomdata(nwx, nwy)
                    var wk = cellkey(ngx, ngy)
                    var w = variable_struct_get(wr.wires, wk)
                    w.powered = true
                    variable_struct_set(wr.wires, wk, w)

                    connecttowersnear(nwx, nwy, ngx, ngy)
                }

                if (hastower(nwx, nwy, ngx, ngy)) {
                    var tr = getroomdata(nwx, nwy)
                    var tk = cellkey(ngx, ngy)
                    var tower = variable_struct_get(tr.towers, tk)

                    tower.powered = true

                    if (!tower.connected) {
                        tower.connected = true
                        onconnecttower()
                    }

                    variable_struct_set(tr.towers, tk, tower)
                }
            }
        }
    }

    ds_queue_destroy(q)

    recountconnected()
    refreshwirevisuals()
    refreshtowervisuals()

    if (!gamewin && connectedcount >= towergoal) {
        gamewin = true
        pushpopup("all towers connected")
    }
}
placemaintower(0, 0, snapx(room_width * 0.5), snapy(room_height * 0.5))
shufflewords()
placetower(1, 0, snapx(room_width * 0.5), snapy(room_height * 0.5), "one")
placetower(-1, 0, snapx(room_width * 0.5), snapy(room_height * 0.5), "two")
placetower(0, 1, snapx(room_width * 0.5), snapy(room_height * 0.5), "three")
placetower(0, -1, snapx(room_width * 0.5), snapy(room_height * 0.5), "four")
placetower(1, 1, snapx(room_width * 0.5), snapy(room_height * 0.5), "five")
placetower(-1, -1, snapx(room_width * 0.5), snapy(room_height * 0.5), "six")