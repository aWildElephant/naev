--[[
<?xml version='1.0' encoding='utf8'?>
<mission name="The Meeting">
  <flags>
   <unique />
  </flags>
  <avail>
   <priority>3</priority>
   <done>Invitation</done>
   <chance>100</chance>
   <location>Bar</location>
   <planet>Darkshed</planet>
  </avail>
  <notes>
   <campaign>Nexus show their teeth</campaign>
  </notes>
 </mission>
 --]]
--[[

   This is the fifth mission of the Shark's teeth campaign. The player has to go to a planet in Za'lek space.

   Stages :
   0) Way to Za'lek system
   1) Way back to Darkshed

   TODO: I'm not really happy with the drone's behaviour: it's quite too obvious

--]]

--needed scripts
require "proximity"
require "numstring"
local fleet = require "fleet"
require "missions/shark/common"


title = {}
text = {}
osd_msg = {}
npc_desc = {}
bar_desc = {}

title[1] = _("Travel")
text[1] = _([["OK, are you ready for the travel to %s in the %s system?"]])

refusetitle = _("Sorry, not interested")
refusetext = _([["OK, come back when you are ready."]])

title[2] = _("Time to go")
text[2] = _([["Let's go, then."]])

title[3] = _("End of mission")
text[3] = _([[Smith gets out of your ship and looks at you, smiling. "You know, it's like that in our kind of job. Sometimes it works and sometimes it fails. It's not our fault. Anyway, here is your pay."]])

title[4] = _("The meeting")
text[4] = _([[As you land, you see a group of people that were waiting for your ship. Smith hails them and tells you to wait in the ship while he goes to a private part of the bar.
    A few periods later, he comes back and explains that he wasn't able to improve Nexus sales in the Frontier, but he was able to stop House Sirius from entering the picture, at least.]])

title[5] = _("What is going on?")
text[5] = _([[Suddenly, a Za'lek drone starts attacking you! As you wonder what to do, you hear a broadcast from a remote Za'lek ship. "Attention please, it seems some of our drones have gone haywire. If a drone attacks you and you aren't wanted by the authorities, you are hereby granted authorization to destroy it."]])

-- Mission details
misn_title = _("The Meeting")
misn_desc = _("Nexus Shipyards asks you to take part in a secret meeting")

-- NPC
npc_desc[1] = _("Arnold Smith")
bar_desc[1] = _([[He is waiting for you.]])

-- OSD
osd_title = _("The Meeting")
osd_msg[1] = _("Go to the %s system and land on %s")
osd_msg[2] = _("Bring Smith back to %s in the %s system")

log_text = _([[You transported Arnold Smith to a secret meeting for Nexus Shipyards. The meeting supposedly did not go as well as he hoped, but was a partial success.]])


function create ()

   --Change here to change the planets and the systems
   mispla, missys = planet.get("Curie")
   pplname = "Darkshed"
   psyname = "Alteris"
   paysys = system.get(psyname)
   paypla = planet.get(pplname)

   if not misn.claim(missys) then
      misn.finish(false)
   end

   misn.setNPC(npc_desc[1], "neutral/unique/arnoldsmith.webp", bar_desc[1])
end

function accept()

   stage = 0
   reward = 750000
   proba = 0.3  --the probability of ambushes will change
   firstambush = true  --In the first ambush, there will be a little surprise text

   if tk.yesno(title[1], text[1]:format(mispla:name(), missys:name())) then
      misn.accept()
      tk.msg(title[2], text[2])

      osd_msg[1] = osd_msg[1]:format(missys:name(), mispla:name())
      osd_msg[2] = osd_msg[2]:format(paypla:name(), paysys:name())

      misn.setTitle(misn_title)
      misn.setReward(creditstring(reward))
      misn.setDesc(misn_desc)
      osd = misn.osdCreate(osd_title, osd_msg)
      misn.osdActive(1)

      marker = misn.markerAdd(missys, "low")

      local c = misn.cargoNew( N_("Smith"), N_("Arnold Smith of Nexus Shipyards.") )
      smith = misn.cargoAdd( c, 0 )

      landhook = hook.land("land")
      enterhook = hook.enter("enter")
      else
      tk.msg(refusetitle, refusetext)
      misn.finish(false)
   end
end

function land()
   --The player is landing on the mission planet
   if stage == 0 and planet.cur() == mispla then
      tk.msg(title[4], text[4]:format(paysys:name()))
      stage = 1
      misn.osdActive(2)
      misn.markerRm(marker)
      marker2 = misn.markerAdd(paysys, "low")
   end

   --Job is done
   if stage == 1 and planet.cur() == paypla then
      if misn.cargoRm(smith) then
         tk.msg(title[3], text[3])
         player.pay(reward)
         misn.osdDestroy(osd)
         hook.rm(enterhook)
         hook.rm(landhook)
         shark_addLog( log_text )
         misn.finish(true)
      end
   end
end

function enter()
   --This timer will ensure that the hacked drones don't reveal themselves during the jumping
   enable = false
   hook.timer(5.0,"enabling")
   -- Ambush !
   if system.cur():presence(faction.get("Za'lek")) > 50 then  -- Only in Za'lek space
      if stage == 0 and rnd.rnd() < proba then
         ambush()
      else
         --the probability of an ambush grows up when you cross a system without meeting any enemy
         proba = proba + 0.2
      end
   end
end

function ambush()
   -- Adds the drones.
   badguy = fleet.add(4, {"Za'lek Light Drone", "Za'lek Heavy Drone", "Za'lek Bomber Drone"}, "Za'lek", nil, "collective")
   badguyprox = {}

   for i, j in ipairs(badguy) do
      --Makes the drones follow the player
      j:control()
      j:follow(player.pilot())

      --as the player approaches, the drones reveal to be bad guys!
      badguyprox[i] = hook.timer(0.5, "proximity", {anchor = j, radius = 1000, funcname = "reveal"})
   end
end

function abort()
   misn.cargoRm(smith)
   misn.finish(false)
end

function reveal()  --transforms the spawn drones into baddies
   if enable == true then  --only if this happens a few time after the jumping/taking off
      for i, j in ipairs(badguy) do
         if j:exists() then
            j:rename(_("Hacked Drone"))
            j:setHostile()
            j:setFaction("Mercenary")
            j:control(false)
            hook.rm(badguyprox[i]) -- Only one drone needs to trigger this function.
         end
      end
      if firstambush == true then
         --Surprise message
         tk.msg(title[5], text[5])
         firstambush = false
      end
      proba = proba - 0.1 * #badguy --processing the probability change
   end
end

function enabling()
   enable = true
end
