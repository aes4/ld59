if (ihopping){
    t = hopt / hdur
    s = scalerest + (scalepeak - scalerest) * (1 - power(2 * t - 1, 2))
    image_xscale = s
    image_yscale = s
} else {
    image_xscale = lerp(image_xscale, scalerest, 0.25)
    image_yscale = lerp(image_yscale, scalerest, 0.25)
}
image_angle = dir + 90
draw_self()