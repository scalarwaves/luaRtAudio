lanes = require"lanes"lanes.configure({ nb_keepers = 1, with_timers = true, on_state_create = nil,track_lanes=true})local linda = lanes.linda()require"lanesutils"require("iuplua")require("iupluacontrols")soundfileName = [[C:\Users\victor\Desktop\musicas victor\resonator.wav]]rt = require"RtAudio"dac = rt.RtAudio(rt.RtAudio_WINDOWS_DS) function vumeter(nsamp)	local rt = require"RtAudio"	local sum = 0	local buf = {}	local count = 1	function callback(nFrames,data)		for i=1,nFrames*2 do			local squared = data[i]^2			sum = sum + squared			sum = sum - (buf[count] or 0)			buf[count] = squared			count = count + 1			if count > nsamp then 				count = 1 				linda:set("sum",math.sqrt(sum/nsamp))			end		end				return nil	end	rt.setCallbackLanesPost("callback")	linda:send("done",1)	local blocklinda = lanes.linda()	blocklinda:receive("dummy")	print"Should not be here"endlanegen(vumeter,"vumeter")(512*2)linda:receive("done")dac:openStream({0,2},nil,44100,512)dac:startStream()sndfile = rt.soundFile(soundfileName)sndfile:play()gauge = iup.gauge{}slider = iup.val{}dlg = iup.dialog{iup.vbox{gauge,slider}; title="Vumeter"}function slider:valuechanged_cb()	print(self.value)	sndfile:play(self.value)endfunction idle_cb2()    local val = linda:get("sum")	if val then		gauge.value = val	end    return iup.DEFAULTendiup.timer{TIME = 100, run = "YES", action_cb = idle_cb2}dlg:showxy(iup.CENTER, iup.CENTER)iup.MainLoop()