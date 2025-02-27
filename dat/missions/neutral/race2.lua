--[[
<?xml version='1.0' encoding='utf8'?>
<mission name="Racing Skills 2">
 <avail>
  <priority>3</priority>
  <cond>player.pilot():ship():class() == "Yacht" and planet.cur():class() ~= "1" and planet.cur():class() ~= "2" and planet.cur():class() ~= "3" and system.cur():presences()["Independent"] ~= nil and system.cur():presences()["Independent"] &gt; 0</cond>
  <done>Racing Skills 1</done>
  <chance>20</chance>
  <location>Bar</location>
 </avail>
 <notes>
  <tier>2</tier>
 </notes>
</mission>
--]]
--[[
   --
   -- MISSION: Racing Skills 2
   -- DESCRIPTION: A person asks you to join a race, where you fly to various checkpoints and board them before landing back at the starting planet
   --
--]]

require "numstring"


text = {}
title = {}
ftitle = {}
ftext = {}

title[1] = _("Another race")
text[1] = _([["Hey there, great to see you back! You want to have another race?"]])

title[5] = _("Choose difficulty")
text[5] = _([["There are two races you can participate in: an easy one, which is like the first race we had, or a hard one, with smaller checkpoints and no afterburners allowed. The easy one has a prize of %s, and the hard one has a prize of %s. Which one do you want to do?"]])
title[6] = _("Hard Mode")
text[6] = _([["You want a challenge huh? Remember, no afterburners on your ship or you will not be allowed to race. Let's go have some fun!"]])

choice1 = _("Easy")
choice2 = _("Hard")

title[2] = _("Easy Mode ")
text[2] = _([["Let's go have some fun then!"]])

title[3] = _("Checkpoint %s reached")
text[3] = _("Proceed to Checkpoint %s")

text[4] = _("Proceed to land at %s")
refusetitle = _("Refusal")
refusetext = _([["I guess we'll need to find another pilot."]])

wintitle = _("You Won!")
wintext = _([[A man in a suit and tie takes you up onto a stage. A large name tag on his jacket says 'Melendez Corporation'. "Congratulations on your win," he says, shaking your hand, "that was a great race. On behalf of Melendez Corporation, I would like to present to you your prize money of %s!" He hands you one of those fake oversized cheques for the audience, and then a credit chip with the actual prize money on it.]])
firstwintext = _([[A man in a suit and tie takes you up onto a stage. A large name tag on his jacket says 'Melendez Corporation'. "Congratulations on your win," he says, shaking your hand, "that was a great race. On behalf of Melendez Corporation, I would like to present to you your trophy and prize money of %s!" He hands you one of those fake oversized cheques for the audience, and then a credit chip with the actual prize money on it. At least the trophy looks cool.]])

ftitle[1] = _("Illegal ship!")
ftext[1] = _([["You have switched to a ship that's not allowed in this race. Mission failed."]])

ftitle[2] = _("You left the race!")
ftext[2] = _([["Because you left the race, you have been disqualified."]])

ftitle[3] = _("You failed to win the race.")
ftext[3] = _([[As you congratulate the winner on a great race, the laid back person comes up to you.
   "That was a lot of fun! If you ever have time, let's race again. Maybe you'll win next time!"]])

ftitle[4] = _("Illegal ship!")
ftext[4] = _([["You have outfits on your ship which is not allowed in this race in hard mode. Mission failed."]])

NPCname = _("A laid back person")
NPCdesc = _("You see a laid back person, who appears to be one of the locals, looking around the bar, apparently in search of a suitable pilot.")

misndesc = _("You're participating in another race!")

OSDtitle = _("Racing Skills 2")
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
marketing = _("This race is sponsored by Melendez Corporation. Problem-free ships for problem-free voyages!")
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
   credits_easy = rnd.rnd(20000, 100000)
   credits_hard = rnd.rnd(200000, 300000)
end


function accept ()
   if tk.yesno(title[1], text[1]) then
      misn.accept()
      OSD[4] = string.format(OSD[4], curplanet:name())
      misn.setDesc(misndesc)
      misn.osdCreate(OSDtitle, OSD)
      local s = text[5]:format(creditstring(credits_easy), creditstring(credits_hard))
      choice, choicetext = tk.choice(title[5], s, choice1, choice2)
      if choice == 1 then
         credits = credits_easy
         tk.msg(title[2], text[2])
      else
         credits = credits_hard
         tk.msg(title[6], text[6])
      end
      misn.setReward(creditstring(credits))
      hook.takeoff("takeoff")
      else
      tk.msg(refusetitle, refusetext)
   end
end

function takeoff()
   if player.pilot():ship():class() ~= "Yacht" then
      tk.msg(ftitle[1], ftext[1])
      misn.finish(false)
   end
   if choice ~= 1 then
      for k,v in ipairs(player.pilot():outfits()) do
         if v == outfit.get("Unicorp Light Afterburner") or v == outfit.get("Hellburner") then
            tk.msg(ftitle[4], ftext[4])
            misn.finish(false)
         end
      end
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
   if choice == 1 then
      shiptype = "Goddard"
   else
      shiptype = "Koala"
   end
   checkpoint[1] = pilot.add(shiptype, "Trader", location1, nil, {ai="stationary"})
   checkpoint[2] = pilot.add(shiptype, "Trader", location2, nil, {ai="stationary"})
   checkpoint[3] = pilot.add(shiptype, "Trader", location3, nil, {ai="stationary"})
   for i, j in ipairs(checkpoint) do
      j:rename(string.format(_("Checkpoint %s"), i))
      j:setHilight(true)
      j:setInvincible(true)
      j:setActiveBoard(true)
      j:setVisible(true)
   end
   racers[1] = pilot.add("Llama", "Independent", curplanet)
   racers[2] = pilot.add("Gawain", "Independent", curplanet)
   racers[3] = pilot.add("Llama", "Independent", curplanet)
   if choice == 1 then
      racers[1]:outfitAdd("Engine Reroute")
      racers[2]:outfitAdd("Engine Reroute")
      racers[3]:outfitAdd("Improved Stabilizer")
   else
      for i in pairs(racers) do
         racers[i]:outfitRm("all")
         racers[i]:outfitRm("cores")

         racers[i]:outfitAdd("Unicorp PT-16 Core System")
         racers[i]:outfitAdd("Unicorp D-2 Light Plating")
         local en_choices = {
            "Nexus Dart 150 Engine", "Tricon Zephyr Engine" }
         racers[i]:outfitAdd(en_choices[rnd.rnd(1, #en_choices)])
      end
   end
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
      player.msg(marketing)
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
   misn.finish(false)
end

function racerland(p)
   player.msg( string.format(landmsg, p:name(), curplanet:name()))
end

function land()
   if target[4] == 4 then
      if racers[1]:exists() and racers[2]:exists() and racers[3]:exists() then
         if choice==2 and player.numOutfit("Racing Trophy") <= 0 then
            tk.msg(wintitle, firstwintext:format(creditstring(credits)))
            player.outfitAdd("Racing Trophy")
         else
            tk.msg(wintitle, wintext:format(creditstring(credits)))
         end
         player.pay(credits)
         misn.finish(true)
      else
         tk.msg(ftitle[3], ftext[3])
         misn.finish(false)
      end
   else
      tk.msg(ftitle[2], ftext[2])
      misn.finish(false)
   end
end
