--[[
<?xml version='1.0' encoding='utf8'?>
<mission name="Racing Skills 1">
  <flags>
    <unique />
  </flags>
  <avail>
   <priority>3</priority>
   <cond>player.pilot():ship():class() == "Yacht" and planet.cur():class() ~= "1" and planet.cur():class() ~= "2" and planet.cur():class() ~= "3" and system.cur():presences()["Independent"] ~= nil and system.cur():presences()["Independent"] &gt; 0</cond>
   <chance>10</chance>
   <location>Bar</location>
  </avail>
 </mission>
 --]]
--[[
--
-- MISSION: Racing Skills 1
-- DESCRIPTION: A person asks you to join a race, where you fly to various checkpoints and board them before landing back at the starting planet
--
--]]

require "numstring"


text = {}
title = {}
ftitle = {}
ftext = {}

title[1] = _("Looking for a 4th")
text[1] = _([["Hiya there! We're having a race around this system system soon and need a 4th person to participate. You have to bring a Yacht class ship, and there's a prize of %s if you win. Interested?"]])

title[2] = _("Awesome")
text[2] = _([["That's great! Here's how it works: We will all be in a Yacht class ship. Once we take off from %s, there will be a countdown, and then we will proceed to the various checkpoints in order, boarding them before going to the next checkpoint. After the last checkpoint has been boarded, head back to %s and land. Let's have some fun!"]])

title[3] = _("Checkpoint %s reached")
text[3] = _("Proceed to Checkpoint %s")

text[4] = _("Land on %s")
refusetitle = _("Refusal")
refusetext = _([["I guess we'll need to find another pilot."]])

wintitle = _("You Won!")
wintext = _([[The laid back person comes up to you and hands you a credit chip.
   "Nice racing! Here's your prize money. Let's race again sometime soon!"]])

ftitle[1] = _("Illegal ship!")
ftext[1] = _([["You have switched to a ship that's not allowed in this race. Mission failed."]])

ftitle[2] = _("You left the race!")
ftext[2] = _([["Because you left the race, you have been disqualified."]])

ftitle[3] = _("You failed to win the race.")
ftext[3] = _([[As you congratulate the winner on a great race, the laid back person comes up to you.
   "That was a lot of fun! If you ever have time, let's race again. Maybe you'll win next time!"]])

NPCname = _("A laid back person")
NPCdesc = _("You see a laid back person, who appears to be one of the locals, looking around the bar.")

misndesc = _("You're participating in a race!")

OSDtitle = _("Racing Skills 1")
OSD = {}
OSD[1] = _("Board checkpoint 1")
OSD[2] = _("Board checkpoint 2")
OSD[3] = _("Board checkpoint 3")
OSD[4] = _("Land at %s")

chatter = {}
chatter[1] = _("Let's do this!")
chatter[2] = _("Wooo!")
chatter[3] = _("Time to Shake 'n Bake")
chatter[4] = _("Checkpoint %s baby!")
chatter[5] = _("Hooyah")
chatter[6] = _("Next!")
timermsg = "%s"
target = {1,1,1,1}

positionmsg = _("%s just reached checkpoint %s")
landmsg = _("%s just landed at %s and finished the race")


function create ()
   this_planet, this_system = planet.cur()
   missys = {this_system}
   if not misn.claim(missys) then
      misn.finish(false)
   end
   cursys = system.cur()
   curplanet = planet.cur()
   misn.setNPC(NPCname, "neutral/unique/laidback.webp", NPCdesc)
   credits = rnd.rnd(20000, 100000)
end


function accept ()
   if tk.yesno(title[1], text[1]:format(creditstring(credits))) then
      misn.accept()
      OSD[4] = string.format(OSD[4], curplanet:name())
      misn.setDesc(misndesc)
      misn.setReward(creditstring(credits))
      misn.osdCreate(OSDtitle, OSD)
      tk.msg(title[2], string.format(text[2], curplanet:name(), curplanet:name()))
      hook.takeoff("takeoff")
   else
      tk.msg(refusetitle, refusetext)
   end
end


function takeoff()
   if player.pilot():ship():class() ~= "Yacht" then
      tk.msg(ftitle[1], ftext[1])
      abort()
   end
   planetvec = planet.pos(curplanet)
   misn.osdActive(1)
   checkpoint = {}
   racers = {}
   pilot.toggleSpawn(false)
   pilot.clear()
   dist1 = rnd.rnd() * system.cur():radius()
   angle1 = rnd.rnd() * 2 * math.pi
   location1 = vec2.new(dist1 * math.cos(angle1), dist1 * math.sin(angle1))
   dist2 = rnd.rnd() * system.cur():radius()
   angle2 = rnd.rnd() * 2 * math.pi
   location2 = vec2.new(dist2 * math.cos(angle2), dist2 * math.sin(angle2))
   dist3 = rnd.rnd() * system.cur():radius()
   angle3 = rnd.rnd() * 2 * math.pi
   location3 = vec2.new(dist3 * math.cos(angle3), dist3 * math.sin(angle3))
   checkpoint[1] = pilot.add("Goddard", "Trader", location1, nil, {ai="stationary"})
   checkpoint[2] = pilot.add("Goddard", "Trader", location2, nil, {ai="stationary"})
   checkpoint[3] = pilot.add("Goddard", "Trader", location3, nil, {ai="stationary"})
   for i, j in ipairs(checkpoint) do
      j:rename( string.format(_("Checkpoint %s"), i) )
      j:setHilight(true)
      j:setInvincible(true)
      j:setActiveBoard(true)
      j:setVisible(true)
   end
   racers[1] = pilot.add("Llama", "Independent", curplanet)
   racers[1]:outfitAdd("Engine Reroute")
   racers[2] = pilot.add("Llama", "Independent", curplanet)
   racers[2]:outfitAdd("Engine Reroute")
   racers[3] = pilot.add("Llama", "Independent", curplanet)
   racers[3]:outfitAdd("Improved Stabilizer")
   for i, j in ipairs(racers) do
      j:rename(string.format(_("Racer %s"), i))
      j:setHilight(true)
      j:setInvincible(true)
      j:setVisible(true)
      j:control()
      j:face(checkpoint[1]:pos(), true)
      j:broadcast(chatter[i])
   end
   player.pilot():control()
   player.pilot():face(checkpoint[1]:pos(), true)
   countdown = 5 -- seconds
   omsg = player.omsgAdd(timermsg:format(countdown), 0, 50)
   counting = true
   counterhook = hook.timer(1.0, "counter")
   hook.board("board")
   hook.jumpin("jumpin")
   hook.land("land")
end


function counter()
   countdown = countdown - 1
   if countdown == 0 then
      player.omsgChange(omsg, _("Go!"), 1000)
      hook.timer(1.0, "stopcount")
      player.pilot():control(false)
      counting = false
      hook.rm(counterhook)
      for i, j in ipairs(racers) do
         j:control()
         j:moveto(checkpoint[target[i]]:pos())
         hook.pilot(j, "land", "racerland")
      end
      hp1 = hook.pilot(racers[1], "idle", "racer1idle")
      hp2 = hook.pilot(racers[2], "idle", "racer2idle")
      hp3 = hook.pilot(racers[3], "idle", "racer3idle")
   else
      player.omsgChange(omsg, timermsg:format(countdown), 0)
      counterhook = hook.timer(1.0, "counter")
   end
end


function racer1idle(p)
   player.msg( string.format( positionmsg, p:name(),target[1]) )
   p:broadcast(string.format( chatter[4], target[1]))
   target[1] = target[1] + 1
   hook.timer(2.0, "nexttarget1")
end


function nexttarget1()
   if target[1] == 4 then
      racers[1]:land(curplanet)
      hook.rm(hp1)
   else
      racers[1]:moveto(checkpoint[target[1]]:pos())
   end
end


function racer2idle(p)
   player.msg( string.format( positionmsg, p:name(),target[2]) )
   p:broadcast(chatter[5])
   target[2] = target[2] + 1
   hook.timer(2.0, "nexttarget2")
end


function nexttarget2()
   if target[2] == 4 then
      racers[2]:land(curplanet)
      hook.rm(hp2)
   else
      racers[2]:moveto(checkpoint[target[2]]:pos())
   end
end


function racer3idle(p)
   player.msg( string.format( positionmsg, p:name(),target[3]) )
   p:broadcast(chatter[6])
   target[3] = target[3] + 1
   hook.timer(2.0, "nexttarget3")
end


function nexttarget3()
   if target[3] == 4 then
      racers[3]:land(curplanet)
      hook.rm(hp3)
   else
      racers[3]:moveto(checkpoint[target[3]]:pos())
   end
end


function stopcount()
   player.omsgRm(omsg)
end


function board(ship)
   for i,j in ipairs(checkpoint) do
      if ship == j and target[4] == i then
         player.msg( string.format( positionmsg, player.name(),target[4]) )
         misn.osdActive(i+1)
         target[4] = target[4] + 1
         if target[4] == 4 then
            tk.msg(string.format(title[3], i), string.format(text[4], curplanet:name()))
         else
            tk.msg(string.format(title[3], i), string.format(text[3], i+1))
         end
         break
      end
   end
   player.unboard()
end


function jumpin()
   tk.msg(ftitle[2], ftext[2])
   abort()
end


function racerland(p)
   player.msg( string.format(landmsg, p:name(), curplanet:name()))
end


function land()
   if target[4] == 4 then
      if racers[1]:exists() and racers[2]:exists() and racers[3]:exists() then
         tk.msg(wintitle, wintext)
         player.pay(credits)
         misn.finish(true)
      else
         tk.msg(ftitle[3], ftext[3])
         abort()

      end
   else
      tk.msg(ftitle[2], ftext[2])
      abort()
   end
end


function abort ()
   misn.finish(false)
end
