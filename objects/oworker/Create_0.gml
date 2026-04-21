depth = -200
phase = 0
waitstart = room_speed * 2
waitmid = op.introdelay
walkspd = 2
timer = waitstart
voiceid = audio_play_sound(aworker, 1, false)
audio_sound_gain(voiceid, op.mastervol, 0)