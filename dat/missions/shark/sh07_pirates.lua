--[[
<?xml version='1.0' encoding='utf8'?>
<mission name="The Last Detail">
  <flags>
   <unique />
  </flags>
  <avail>
   <priority>3</priority>
   <done>A Journey To Arandon</done>
   <chance>50</chance>
   <location>Bar</location>
   <planet>Darkshed</planet>
   <cond>not diff.isApplied( "flf_dead" )</cond>
  </avail>
  <notes>
   <campaign>Nexus show their teeth</campaign>
  </notes>
 </mission>
 --]]
--[[

   This is the climax mission of the Shark's teeth campaign. The player has to kill 4 pirates.

   Stages :
   0) There are pirates to kill
   1) Way to Alteris

--]]

--Needed scripts
require "pilot/pirate"
require "numstring"
require "jumpdist"
require "missions/shark/common"


title = {}
text = {}
osd_msg = {}
npc_desc = {}
bar_desc = {}

title[1] = _("The mission")
text[1] = _([["Hello again. As you know, I've agreed with the FLF on a contract that will extend our sales of ships to them substantially. Of course, this deal must remain a secret, which is why it is being done through a false black market dealer.
    "However, we have reason to suspect that a few key influential pirates may have their eyes on the FLF as possible buyers of the Skull and Bones pirate ships. We don't think the FLF will have any interest in those ships, but the pirates' ambitions could give them motivation to attack our false dealer's trade posts, destroying our deal with the FLF anyway. We of course can't have that.
    "So what we want you to do, quite simply, is to eliminate these pirates. It's not that many of them; there are four pirates we need eliminated, and thankfully, they're all spread out. That being said, some of them do have quite big ships, so you will have to make sure you can handle that. Are you willing to do this job for us?"]])

refusetitle = _("Sorry, not interested")
refusetext = _([["I'm sorry to hear that. Don't hesitate to come back if you change your mind."]])

title[2] = _("Very good")
text[2] = _([["So, here are the details we have gathered about these pirates:
    "%s should be in %s, flying a Gawain. He seems to be on a holiday, so he probably isn't able to fight back and will just run away.
    "%s should be in %s, flying a Kestrel. We believe he has some escorts.
    "%s should be in %s, also flying a Kestrel. He has escorts, too, according to our records.
    "And finally, %s is in %s. He stole and beefed up a Goddard recently, so make sure you're prepared for that. He also has escorts, according to our records.
    "And that's about it! Come back for your fee when you have finished."]])

title[4] = _("Mission accomplished")
text[4] = _("You have killed the four pirates. Now to return to %s and collect your payment...")

title[5] = _("That was impressive")
text[5] = _([[Smith awaits your arrival at the spaceport. When you exit your ship, he smiles and walks up to you. "Good job," he says. "Our deal is secure, thanks to you. Here is your pay and something extra for your hard work. Thank you for all your help!"
    He hands you a credit chip and what appears to be a Nexus Shipyards commemorative sandwich holder.]])

-- Mission details
misn_title = _("The Last Detail")
misn_desc = _("Nexus Shipyards has tasked you with killing four pirates.")

-- NPC
npc_desc[1] = _("Arnold Smith")
bar_desc[1] = _([[Perhaps it would be worthwhile to see if he has another job for you.]])

-- OSD
osd_title = _("The Last Detail")
osd_msg[1] = _("Kill the four pirates")
osd_msg[2] = _("Report back to %s in %s")

log_text = _([[You eliminated some pirates that were about to get in the way of Nexus Shipyards' business.]])


function create ()

   --Will now pick systems between min and max jumps in distance
   local min = 3
   local max = 7
   local systems = getsysatdistance(system.cur(), min, max)
   if #systems == 0 then
      local systems = getsysatdistance(system.cur(), 1, 15)
      if #systems == 0 then
         osd_title = _("Houston, we have a problem!")
         gawsys = system.get("Alteris")
         kersys1 = system.get("Alteris")
         kersys2 = system.get("Alteris")
         godsys = system.get("Alteris")
      end
   end
   local index = rnd.rnd(1, #systems/4) --This avoids picking the same
   gawsys = systems[index]
   local index = rnd.rnd(index, #systems/3) --system twice, which would
   kersys1 = systems[index]
   local index = rnd.rnd(index, #systems/2) --make the missions rather
   kersys2 = systems[index]
   local index = rnd.rnd(index, #systems) --harder!
   godsys = systems[index]

   pplname = "Darkshed"
   psyname = "Alteris"
   paysys = system.get(psyname)
   paypla = planet.get(pplname)

   if not misn.claim({gawsys, kersys1, kersys2, godsys}) then
      misn.finish(false)
   end

   misn.setNPC(npc_desc[1], "neutral/unique/arnoldsmith.webp", bar_desc[1])
end

function accept()

   reward = 3e6
   stage = 0

   --Initialization of dead pirate memory
   gawdead = false
   kerdead1 = false
   kerdead2 = false
   goddead = false

   --set the names of the pirates (and make sure they aren't duplicates)
   gawname = pirate_name()
   kername1 = string.format( _("%s III"), pirate_name() )
   kername2 = string.format( _("%s Jr." ), pirate_name() )
   godname = string.format( _("%s II"), pirate_name() )

   if tk.yesno(title[1], text[1]) then
      misn.accept()
      tk.msg(title[2], text[2]:format(gawname, gawsys:name(), kername1, kersys1:name(), kername2, kersys2:name(), godname, godsys:name()))

      osd_msg[2] = osd_msg[2]:format(pplname,psyname)

      misn.setTitle(misn_title)
      misn.setReward(creditstring(reward))
      misn.setDesc(misn_desc)
      osd = misn.osdCreate(osd_title, osd_msg)
      misn.osdActive(1)

      gawmarker = misn.markerAdd(gawsys, "low")
      kermarker1 = misn.markerAdd(kersys1, "high")
      kermarker2 = misn.markerAdd(kersys2, "high")
      godmarker = misn.markerAdd(godsys, "high")

      enterhook = hook.enter("enter")
      landhook = hook.land("land")

      else
      tk.msg(refusetitle, refusetext)
      misn.finish(false)
   end
end

function land()
   --Job is done
   if stage == 1 and planet.cur() == planet.get("Darkshed") then
      tk.msg(title[5], text[5])
      player.pay(reward)
      player.outfitAdd("Sandwich Holder")
      misn.osdDestroy(osd)
      hook.rm(enterhook)
      hook.rm(landhook)
      shark_addLog( log_text )
      misn.finish(true)
   end
end

function enter()
   --Arrived in system
   if system.cur() == gawsys and gawdead == false then  --The Gawain

      -- Choose a random point in the system for him to stay around
      sysrad = rnd.rnd() * system.cur():radius()
      angle = rnd.rnd() * 360
      pos = vec2.newP(sysrad, angle)

      baddie = pilot.add( "Gawain", "Thugs", nil, gawname, {ai="dummy"} )
      baddie:setHostile()
      baddie:setHilight()
      baddie:control()
      baddie:moveto(pos)

      --The pirate becomes nice defensive outfits
      baddie:outfitRm("all")
      baddie:outfitRm("cores")
      baddie:cargoRm( "all" )

      baddie:outfitAdd("Nexus Light Stealth Plating")
      baddie:outfitAdd("Milspec Orion 2301 Core System")
      baddie:outfitAdd("Tricon Zephyr Engine")

      baddie:outfitAdd("Shield Capacitor I")
      baddie:outfitAdd("Plasteel Plating")
      baddie:outfitAdd("Milspec Impacto-Plastic Coating")
      baddie:outfitAdd("Laser Cannon MK1",2)

      baddie:setHealth(100,100)
      baddie:setEnergy(100)

      hook.pilot(baddie, "idle", "idle", pos)
      hook.pilot(baddie, "attacked", "attacked")
      hook.pilot(baddie, "death", "gawain_dead")

   elseif system.cur() == kersys1 and kerdead1 == false then  --The Kestrel
      pilot.clear()
      pilot.toggleSpawn(false)

      baddie = pilot.add( "Pirate Kestrel", "Pirate", vec2.new(0,0), nil, {ai="pirate_norun"} )
      ancestor = pilot.add( "Pirate Ancestor", "Pirate", vec2.new(100,0) )
      hyena = pilot.add( "Hyena", "Pirate", vec2.new(0,100), _("Pirate Hyena") )

      baddie:rename(kername1)
      baddie:setHilight()
      baddie:setHostile()

      hook.pilot( baddie, "death", "kestrel_dead1")

   elseif system.cur() == kersys2 and kerdead2 == false then  --The Kestrel
      pilot.clear()
      pilot.toggleSpawn(false)

      baddie = pilot.add( "Pirate Kestrel", "Pirate", vec2.new(0,0), nil, {ai="pirate_norun"} )
      ancestor = pilot.add( "Pirate Ancestor", "Pirate", vec2.new(100,0) )
      shark = pilot.add( "Pirate Shark", "Pirate", vec2.new(0,100) )
      hyena = pilot.add( "Hyena", "Pirate", vec2.new(100,100), _("Pirate Hyena") )

      baddie:rename(kername2)
      baddie:setHilight()
      baddie:setHostile()

      hook.pilot( baddie, "death", "kestrel_dead2")

   elseif system.cur() == godsys and goddead == false then  --The Goddard
      pilot.clear()
      pilot.toggleSpawn(false)

      baddie = pilot.add( "Goddard", "Goddard", vec2.new(0,0), godname, {ai="pirate_norun"} ) --Faction's ships come with upgraded weaponry
      baddie:setFaction("Pirate")
      baddie:changeAI( "pirate" )

      ancestor = pilot.add( "Pirate Ancestor", "Pirate", vec2.new(100,0) )
      hyena = pilot.add( "Hyena", "Pirate", vec2.new(0,100), _("Pirate Hyena") )

      baddie:setHilight()
      baddie:setHostile()

      hook.pilot( baddie, "death", "goddard_dead")

   end

end

function idle(pilot,pos)  --the Gawain is flying around a random point
   baddie:moveto(pos + vec2.new( 800,  800), false, false)
   baddie:moveto(pos + vec2.new(-800,  800), false, false)
   baddie:moveto(pos + vec2.new(-800, -800), false, false)
   baddie:moveto(pos + vec2.new( 800, -800), false, false)
end

function attacked()  --the Gawain is going away
   if baddie:exists() then
      baddie:taskClear()
      baddie:runaway(player.pilot(), true)
   end
end

function gawain_dead()
   misn.markerRm(gawmarker)
   gawdead = true
   hook.timer(3.0,"generic_dead")
end

function kestrel_dead1()
   misn.markerRm(kermarker1)
   kerdead1 = true
   hook.timer(3.0,"generic_dead")
end

function kestrel_dead2()
   misn.markerRm(kermarker2)
   kerdead2 = true
   hook.timer(3.0,"generic_dead")
end

function goddard_dead()
   misn.markerRm(godmarker)
   goddead = true
   hook.timer(3.0,"generic_dead")
end

function generic_dead()
   --Are there still other pirates to kill ?
   if gawdead == true and kerdead1 == true and kerdead2 == true and goddead == true then
      tk.msg(title[4], text[4]:format(paysys:name()))
      stage = 1
      misn.osdActive(2)
      marker2 = misn.markerAdd(paysys, "low")
   end
end
