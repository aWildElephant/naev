--[[
<?xml version='1.0' encoding='utf8'?>
<mission name="The Search for Cynthia">
  <flags>
    <unique />
  </flags>
  <avail>
   <priority>4</priority>
   <done>The Runaway</done>
   <chance>11</chance>
   <location>Bar</location>
   <system>Goddard</system>
  </avail>
 </mission>
 --]]
--[[
   This is the second half of "The Runaway"
   Here, Cynthia's father pays you to track down his daughter.
   It is alluded to that Cynthia ran away due to her abusive mother.
   The father has been named after me, Old T. Man.
   I'm joking about the last line a little. If you want to name him, feel free.
--]]

require "numstring"
require "missions/neutral/common"


npc_name = _("Old Man")
bar_desc = _("An old man sits at a table with some missing person papers.")
title = _("The Search for Cynthia")
misn_desc_pre_accept = _([[Approaching him, he hands you a paper. It offers a 100,000 credit reward for the finding of a "Cynthia" person.
    "That's my girl. She disappeared quite a few decaperiods ago. We managed to track her down to here, but where she went afterwards remains a mystery. We know she was kidnapped, but if you know anything..." The man begins to cry. "Have you seen any trace of her?"]])
misn_desc = _("Search for Cynthia.")
reward_desc = _("%s on delivery.")
cargoname = N_("Cynthia")
cargodesc = N_("A young teenager.")

post_accept = {}
post_accept[1] = _([[Looking at the picture, you see that the locket matches the one that Cynthia wore, so you hand it to her father. "I believe that this was hers." Stunned, the man hands you a list of planets that they wanted to look for her on.]])

misn_nifiheim = _("After thoroughly searching the spaceport, you decide that she wasn't there.")
misn_nova_shakar = _("At last! You find her, but she ducks into a tour bus when she sees you. The schedule says it's destined for Torloth. You begin to wonder if she'll want to be found.")
misn_torloth = _([[After chasing Cynthia through most of the station, you find her curled up at the end of a hall, crying. As you approach, she screams, "Why can't you leave me alone? I don't want to go back to my terrible parents!" Will you take her anyway?]])
misn_capture = "Cynthia stops crying and proceeds to hide in the farthest corner of your ship. Attemps to talk to her turn up fruitless."
misn_release = _([["Please, please, please don't ever come looking for me again, I beg of you!"]])
misn_release_father = _([[You tell the father that you checked every place on the list, and then some, but his daughter was nowhere to be found. You buy the old man a drink, then go back to the spaceport. Before you leave, he hands you a few credits. "For your troubles."]])
misn_father = _("As Cynthia sees her father, she begins her crying anew. You overhear the father talking about how her abusive mother died. Cynthia becomes visibly happier, so you pick up your payment and depart.")

-- Here are stored the fake texts for the OSD
osd_text = {}
osd_text[1] = _("Search for Cynthia on Niflheim in Dohriabi")
osd_text[2] = _("Search for Cynthia on Nova Shakar in Shakar")
osd_text[3] = _("Search for Cynthia on Selphod in Eridani")
osd_text[4] = _("Search for Cynthia on Emperor's Fist in Gamma Polaris")
osd_text["__save"] = true

-- Can't let them see what's coming up, can I?
osd3 = _("Catch Cynthia on Torloth in Cygnus")
osd4 = _("Return Cynthia to her father on Zhiru in the Goddard system")
osdlie = _("Go to Zhiru in Goddard to lie to Cynthia's father")

log_text_capture = _([[The father of Cynthia, who you had given a lift before, asked you to find her and bring her back to him, thinking that she was kidnapped. Cynthia protested, telling you that she did not want to go back to her parents, but you took her anyway. When she saw her father, she started crying, but seemed to become visibly happier when her father told her that her abusive mother had died.]])
log_text_release = _([[The father of Cynthia, who you had given a lift before, asked you to find her and bring her back to him, thinking that she was kidnapped. Cynthia protested, telling you that she did not want to go back to her parents. Respecting her wishes, you let her be and lied to her father, saying that you couldn't find her no matter how hard you tried.]])


function create ()
   targetworld_sys = system.get("Dohriabi")
   targetworld = planet.get("Niflheim")

   releasereward = 25000
   reward = 100000

   misn.setNPC( npc_name, "neutral/unique/cynthia_father.webp", bar_desc )
end

function accept ()
   --This mission does not make any system claims
   if not tk.yesno( title, string.format( misn_desc_pre_accept, reward, targetworld:name() ) ) then
      misn.finish()
   end

   --Set up the OSD
   if misn.accept() then
      misn.osdCreate(title,osd_text)
      misn.osdActive(1)
   end

   misn.setTitle( title )
   misn.setReward( string.format( reward_desc, creditstring(reward) ) )

   misn.setDesc( string.format( misn_desc, targetworld:name(), targetworld_sys:name() ) )
   runawayMarker = misn.markerAdd(system.get("Dohriabi"), "low")

   tk.msg( title, post_accept[1] )


   hook.land("land")
end

function land ()
   -- Only proceed if at the target.
   if planet.cur() ~= targetworld then
      return
   end

   --If we land on Niflheim, display message, reset target and carry on.
   if planet.cur() == planet.get("Niflheim") then
      targetworld = planet.get("Nova Shakar")
      tk.msg(title, misn_nifiheim)
      misn.osdActive(2)
      misn.markerMove(runawayMarker, system.get("Shakar"))

   --If we land on Nova Shakar, display message, reset target and carry on.
   elseif planet.cur() == planet.get("Nova Shakar") then
      targetworld = planet.get("Torloth")
      tk.msg(title, misn_nova_shakar)

      --Add in the *secret* OSD text
      osd_text[3] = osd3
      osd_text[4] = osd4

      --Update the OSD
      misn.osdDestroy()
      misn.osdCreate(title,osd_text)
      misn.osdActive(3)

      misn.markerMove(runawayMarker, system.get("Cygnus"))

   --If we land on Torloth, change OSD, display message, reset target and carry on.
   elseif planet.cur() == planet.get("Torloth") then
      targetworld = planet.get("Zhiru")

      --If you decide to release her, speak appropriately, otherwise carry on
      if not tk.yesno(title, misn_torloth) then
         osd_text[4] = osdlie
         tk.msg(title, misn_release)
      else
         tk.msg(title, misn_capture)
         local c = misn.cargoNew( cargoname, cargodesc )
         cargoID = misn.cargoAdd( c, 0 )
      end

      --Update the OSD
      misn.osdDestroy()
      misn.osdCreate(title,osd_text)
      misn.osdActive(4)

      misn.markerMove(runawayMarker, system.get("Goddard"))

   --If we land on Zhiru to finish the mission, clean up, reward, and leave.
   elseif planet.cur() == planet.get("Zhiru") then
      misn.markerRm(runawayMarker)

      --Talk to the father and get the reward
      if misn.osdGetActive() == osd4 then
         tk.msg(title, misn_father)
         player.pay(reward)
         misn.cargoRm(cargoID)
         addMiscLog( log_text_capture )
      else
         tk.msg(title, misn_release_father)
         player.pay(releasereward)
         addMiscLog( log_text_release )
      end

      misn.finish(true)
   end
end

