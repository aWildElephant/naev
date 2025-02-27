--[[
<?xml version='1.0' encoding='utf8'?>
<mission name="Collective Espionage 1">
 <flags>
  <unique />
 </flags>
 <avail>
  <priority>2</priority>
  <cond>faction.playerStanding("Empire") &gt; 5 and var.peek("collective_fail") ~= true</cond>
  <done>Collective Scouting</done>
  <chance>100</chance>
  <location>Bar</location>
  <planet>Omega Station</planet>
 </avail>
 <notes>
  <campaign>Collective</campaign>
 </notes>
</mission>
--]]
--[[

   Collective Espionage I

   Author: bobbens
      minor edits by Infiltrator

   Second mission in the mini collective campaign.

   You must inspect a system for wireless communications.

]]--

require "numstring"
require "missions/empire/common"

bar_desc = _("You notice Lt. Commander Dimitri motioning for you to come over to him.")
misn_title = _("Collective Espionage")
misn_desc = {}
misn_desc[1] = _("Scan the Collective systems for wireless communications")
misn_desc[2] = _("Travel back to %s in %s")
misn_desc["__save"] = true

title = {}
title[1] = _("Lt. Commander Dimitri")
title[2] = _("Collective Espionage")
title[3] = _("Mission Accomplished")
text = {}
text[1] = _([[You meet up with Lt. Commander Dimitri.
    "We managed to capture the drone after you located it. It didn't seem to be in good health. Our scientists are studying it as we speak, but we've found something strange in it. Some sort of weird wireless module. We'd like you to do a deep scan of the nearby Collective systems to see if you can pick up any strange wireless communications. This will be a dangerous mission, because you'll need to stay in the system long enough for the scan to complete. I recommend a fast ship to outrun the drones. Are you interested in doing this now?"]])
text[2] = _([["You need to jump to each of the systems indicated on your map, and stay in the system until the scan finishes. If you jump out prematurely, you'll have to restart the scan from scratch when you return.
   "Of course, we're not sending you in unprepared. I have updated your ship's computer with a map of the Collective systems, at least the part we know about. I'm afraid it's not very complete intel, but it should be enough.
   "Like I said, it's best if you tried to avoid the drones, but if you think you can take them, go for it! Good luck."]])
text[3] = _([[After landing, Lt. Commander Dimitri greets you on the land pad.
    "I suppose all went well? Those drones can really give a beating. We'll have the researchers start looking at your logs right away. Meet me in the bar again in a while."]])

timermsg = _("Scanning... %ss remaining.")

log_text = _([[You helped gather intel on the Collective by scanning Collective systems. Lt. Commander Dimitri told you to meet him in the bar again on Omega Station.]])


function create ()
   -- Note: this mission does not make any system claims.
   misn.setNPC( _("Dimitri"), "empire/unique/dimitri.webp", bar_desc )
end


function accept ()
   -- Intro text
   if not tk.yesno( title[1], text[1] ) then
      misn.finish()
   end

   -- Accept mission
   misn.accept()

   credits = 600000

   misn_stage = 0
   systems_visited = 0 -- Number of Collective systems visited
   misn_base,misn_base_sys = planet.get("Omega Station")
   targsys1 = system.get("C-43")
   targsys2 = system.get("C-59")

   -- Mission details
   misn_desc[2] = misn_desc[2]:format(misn_base:name(), misn_base_sys:name())
   misn.setTitle(misn_title)
   misn.setReward( creditstring( credits ) )
   misn.setDesc(misn_desc[1])
   misn_marker1 = misn.markerAdd(targsys1, "low")
   misn_marker2 = misn.markerAdd(targsys2, "low")
   misn.osdCreate(misn_title, misn_desc)

   tk.msg( title[2], text[2] )
   player.outfitAdd("Map: Collective Space")

   hook.enter("enter")
   hook.land("land")
end


function enter()
    -- End any ongoing scans.
    if scanning then
        hook.rm(timerhook)
        player.omsgRm(omsg)
        scanning = false
    end

    if (system.cur() == targsys1 and not sysdone1) or (system.cur() == targsys2 and not sysdone2) then
        scantime = 90 -- seconds
        omsg = player.omsgAdd(timermsg:format(scantime), 0)
        timerhook = hook.timer(1.0, "scantimer")
        scanning = true
    end
end

function scantimer()
    scantime = scantime - 1
    if scantime == 0 then
        player.omsgRm(omsg)
        if system.cur() == targsys1 then
            misn.markerRm(misn_marker1)
            sysdone1 = true
        elseif system.cur() == targsys2 then
            misn.markerRm(misn_marker2)
            sysdone2 = true
        end
        scanning = false

        if sysdone1 and sysdone2 then
            misn.osdActive(2)
            misn.markerAdd(misn_base_sys, "low")
        end

        return
    end
    player.omsgChange(omsg, timermsg:format(scantime), 0)
    timerhook = hook.timer(1.0, "scantimer")
end

function land()
   if planet.cur() == misn_base and sysdone1 and sysdone2 then
      tk.msg( title[3], text[3] )
      player.pay(credits)
      faction.modPlayerSingle("Empire",5)
      emp_addCollectiveLog( log_text )
      misn.finish(true)
   end
end

