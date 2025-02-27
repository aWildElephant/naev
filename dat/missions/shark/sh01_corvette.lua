--[[
<?xml version='1.0' encoding='utf8'?>
<mission name="Sharkman Is Back">
  <flags>
   <unique />
  </flags>
  <avail>
   <priority>3</priority>
   <done>A Shark Bites</done>
   <chance>10</chance>
   <location>Bar</location>
   <faction>Dvaered</faction>
   <faction>Empire</faction>
   <faction>Frontier</faction>
   <faction>Goddard</faction>
   <faction>Independent</faction>
   <faction>Sirius</faction>
   <faction>Soromid</faction>
   <faction>Traders Guild</faction>
   <faction>Za'lek</faction>
  </avail>
  <notes>
   <campaign>Nexus show their teeth</campaign>
  </notes>
 </mission>
 --]]
--[[

   This is the second mission of the Shark's teeth campaign. The player has to take part to a fake battle.

   Stages :
   0) Way to Toaxis
   1) Battle
   2) Going to Darkshed

--]]

require "numstring"
require "missions/shark/common"


title = {}
text = {}
osd_msg = {}
npc_desc = {}
bar_desc = {}

title[1] = _("Nexus Shipyards needs you")
text[1] = _([["I have another job for you. The Baron was unfortunately not as impressed as we hoped. So we need a better demonstration, and we think we know what to do: we're going to demonstrate that the Lancelot, our higher-end fighter design, is more than capable of defeating destroyer class ships.
    "Now, one small problem we face is that pirates almost never use destroyer class ships; they tend to stick to fighters, corvettes, and cruisers. More importantly, actually sending a fighter after a Destroyer is exceedingly dangerous, even if we could find a pirate piloting one. So we have another plan: we want someone to pilot a destroyer class ship and just let another pilot disable them with ion cannons.
    "What do you say? Are you interested?"]])

refusetitle = _("Sorry, not interested")
refusetext = _([["OK, that's alright."]])

title[2] = _("Wonderful")
text[2] = _([["Great! Go and meet our pilot in %s. After the job is done, meet me on %s in the %s system."]])

title[3] = _("Reward")
text[3] = _([[As you land, you see Arnold Smith waiting for you. He explains that the Baron was so impressed by the battle that he signed an updated contract with Nexus Shipyards, solidifying Nexus as the primary supplier of ships for his fleet. As a reward, they give you twice the sum of credits they promised to you.]])

title[4] = _("You ran away!")
title[5] = _("The Lancelot is destroyed!")
title[6] = _("The Lancelot ran away!")
text[4] = _([[Your mission failed.]])

-- Mission details
misn_title = _("Sharkman is back")
misn_desc = _("Nexus Shipyards wants you to fake a loss against a Lancelot while piloting a Destroyer class ship.")

-- NPC
npc_desc[1] = _("Arnold Smith")
bar_desc[1] = _([[The Nexus employee seems to be looking for pilots. Maybe he has an other task for you.]])

-- OSD
osd_title = _("Sharkman Is Back")
osd_msg[1] = _("Jump in %s with a destroyer class ship and let the Lancelot disable you")
osd_msg[2] = _("Go to %s in %s to collect your pay")

msg_run = _("MISSION FAILED: You ran away.")
msg_destroyed = _("MISSION FAILED: You destroyed the Lancelot.")

log_text = _([[You helped Nexus Shipyards fake a demonstration by allowing a Lancelot to disable your Destroyer-class ship.]])


function create ()

   --Change here to change the planet and the system
   bsyname = "Toaxis"
   psyname = "Alteris"
   pplname = "Darkshed"
   --System neighbouring Toaxis with zero pirate presence due to a "Virtual Pirate Unpresence" asset
   esyname = "Ingot"
   battlesys = system.get(bsyname)
   paysys = system.get(psyname)
   paypla = planet.get(pplname)
   escapesys = system.get(esyname)

   if not misn.claim(battlesys) then
      misn.finish(false)
   end

   misn.setNPC(npc_desc[1], "neutral/unique/arnoldsmith.webp", bar_desc[1])
end

function accept()

   stage = 0
   reward = 750e3

   if tk.yesno(title[1], text[1]:format(battlesys:name(), numstring(reward/2))) then
      misn.accept()
      tk.msg(title[2], text[2]:format(battlesys:name(), paypla:name(), paysys:name()))

      osd_msg[1] = osd_msg[1]:format(battlesys:name())
      osd_msg[2] = osd_msg[2]:format(paypla:name(), paysys:name())

      misn.setTitle(misn_title)
      misn.setReward(creditstring(reward/2))
      misn.setDesc(misn_desc)
      osd = misn.osdCreate(osd_title, osd_msg)
      misn.osdActive(1)

      marker = misn.markerAdd(battlesys, "low")

      jumpouthook = hook.jumpout("jumpout")
      landhook = hook.land("land")
      enterhook = hook.enter("enter")
   else
      tk.msg(refusetitle, refusetext)
      misn.finish(false)
   end
end

function jumpout()
   if stage == 1 then --player trying to escape
      player.msg( "#r" .. msg_run .. "#0" )
      misn.finish(false)
   end
end

function land()
   if stage == 1 then --player trying to escape
      player.msg( "#r" .. msg_run .. "#0" )
      misn.finish(false)
   end
   if stage == 2 and planet.cur() == paypla then
      tk.msg(title[3], text[3])
      player.pay(reward)
      misn.osdDestroy(osd)
      hook.rm(enterhook)
      hook.rm(landhook)
      hook.rm(jumpouthook)
      shark_addLog( log_text )
      misn.finish(true)
   end
end

function enter()

   playerclass = player.pilot():ship():class()
   --Jumping in Toaxis for the battle with a destroyer class ship
   if system.cur() == battlesys and stage == 0 and playerclass == "Destroyer" then
      pilot.clear()
      pilot.toggleSpawn( false )

      hook.timer(2.0,"lets_go")
   end
end

function lets_go()
   -- spawns the Shark
   sharkboy = pilot.add( "Lancelot", "Mercenary", system.get("Raelid"), nil, {ai="baddie_norun"} )
   sharkboy:setHostile()
   sharkboy:setHilight()

   --The shark becomes nice outfits
   sharkboy:outfitRm("all")
   sharkboy:outfitRm("cores")

   sharkboy:outfitAdd("S&K Light Combat Plating")
   sharkboy:outfitAdd("Milspec Orion 3701 Core System")
   sharkboy:outfitAdd("Tricon Zephyr II Engine")

   sharkboy:outfitAdd("Reactor Class I",2)

   sharkboy:outfitAdd("Heavy Ion Cannon")
   sharkboy:outfitAdd("Ion Cannon",3)

   sharkboy:setHealth(100,100)
   sharkboy:setEnergy(100)
   sharkboy:setFuel(true)
   stage = 1

   shark_dead_hook = hook.pilot( sharkboy, "death", "shark_dead" )
   disabled_hook = hook.pilot( player.pilot(), "disable", "disabled" )
end

function shark_dead()  --you killed the shark
   player.msg( "#r" .. msg_destroyed .. "#0" )
   misn.finish(false)
end

function disabled(pilot, attacker)
   if attacker == sharkboy then
      stage = 2
      misn.osdActive(2)
      misn.markerRm(marker)
      marker2 = misn.markerAdd(paysys, "low")
      pilot.toggleSpawn( true )
   end
   sharkboy:control()
   --making sure the shark doesn't continue attacking the player
   sharkboy:hyperspace(escapesys)
   sharkboy:setNoDeath(true)

   -- Clean up now unneeded hooks
   hook.rm(shark_dead_hook)
   hook.rm(disabled_hook)
end
