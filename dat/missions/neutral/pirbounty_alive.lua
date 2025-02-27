--[[
<?xml version='1.0' encoding='utf8'?>
<mission name="Alive Bounty">
 <avail>
  <priority>4</priority>
  <cond>player.numOutfit("Mercenary License") &gt; 0</cond>
  <chance>360</chance>
  <location>Computer</location>
  <faction>Empire</faction>
  <faction>Frontier</faction>
  <faction>Goddard</faction>
  <faction>Independent</faction>
  <faction>Sirius</faction>
  <faction>Soromid</faction>
  <faction>Za'lek</faction>
 </avail>
 <notes>
  <tier>3</tier>
 </notes>
</mission>
--]]
--[[

   Alive Pirate Bounty

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.

--

   Bounty mission where you must capture the target alive.
   Can work with any faction.

--]]

require "numstring"
require "missions/neutral/pirbounty_dead"

-- Localization
kill_instead_title   = _("Better Dead than Free")
kill_instead_text    = {}
kill_instead_text[1] = _([[As you return to your ship, you are contacted by an officer. "I see you were unable to capture %s," the officer says. "Disappointing. However, we would rather this pirate be dead than roaming free, so you will be paid %s if you finish them off right now."]])
kill_instead_text[2] = _([[On your way back to your ship, you receive a message from an officer. It reads, "Your failure to capture %s is disappointing. We really wanted to capture this pirate alive. However, we would rather he be dead than roaming free, so if you kill the pirate now, you will be paid the lesser sum of %s."]])
kill_instead_text[3] = _([[When you return to your cockpit, you are contacted by an officer. "Pathetic! If I were in charge, I'd say you get no bounty! Can't fight off a couple low-life pirates?!" He sighs. "But lucky for you, I'm not in charge, and my higher-ups would rather %s be dead than free. So if you finish that scum off, you'll get %s. Just be snappy about it!" Having finished delivering the message, the officer then ceases communication.]])
kill_instead_text[4] = _([[When you get back to the ship, you see a message giving you a new mission to kill %s; the reward is %s. Well, that's pitiful compared to what you were planning on collecting, but it's better than nothing.]])

pay_capture_text    = {}
pay_capture_text[1] = _("An officer takes %s into custody and hands you your pay.")
pay_capture_text[2] = _("The officer seems to think your acceptance of the alive bounty for %s was foolish. They carefully take the pirate off your hands, taking precautions you think are completely unnecessary, and then hand you your pay.")
pay_capture_text[3] = _("The officer you deal with seems to especially dislike %s. They take the pirate off your hands and hand you your pay without speaking a word.")
pay_capture_text[4] = _("A fearful-looking officer rushes %s into a secure hold, pays you the appropriate bounty, and then hurries off.")
pay_capture_text[5] = _("The officer you deal with thanks you profusely for capturing %s alive, pays you, and sends you off.")
pay_capture_text[6] = _("Upon learning that you managed to capture %s alive, the officer who previously sported a defeated look suddenly brightens up. The pirate is swiftly taken into custody as you are handed your pay.")
pay_capture_text[7] = _("When you ask the officer for your bounty on %s, they sigh, take the pirate into custody, go through some paperwork, and hand you your pay, mumbling something about how useless capturing pirates alive is.")

pay_kill_text    = {}
pay_kill_text[1] = _("After verifying that you killed %s, an officer hands you your pay.")
pay_kill_text[2] = _("After verifying that %s is indeed dead, the officer sighs and hands you your pay.")
pay_kill_text[3] = _("This officer is clearly annoyed that %s is dead. They mumble something about incompetent bounty hunters the entire time as they takes care of the paperwork and hand you your bounty.")
pay_kill_text[4] = _("The officer seems disappointed, yet unsurprised that you failed to capture %s alive. You are handed your lesser bounty without a word.")
pay_kill_text[5] = _("When you ask the officer for your bounty on %s, they sigh, lead you into an office, go through some paperwork, and hand you your pay, mumbling something about how useless bounty hunters are.")
pay_kill_text[6] = _("The officer verifies the death of %s, goes through the necessary paperwork, and hands you your pay, looking annoyed the entire time.")

fail_kill_text = _("MISSION FAILURE! %s has been killed.")

misn_title = {}
misn_title[1] = _("Tiny Alive Bounty in %s")
misn_title[2] = _("Small Alive Bounty in %s")
misn_title[3] = _("Moderate Alive Bounty in %s")
misn_title[4] = _("High Alive Bounty in %s")
misn_title[5] = _("Dangerous Alive Bounty in %s")
misn_desc   = _("The pirate known as %s was recently seen in the %s system. %s authorities want this pirate alive.")

osd_msg[2] = _("Capture %s")
osd_msg_kill = _("Kill %s")


function pilot_death ()
   if board_failed then
      succeed()
      target_killed = true
   else
      fail( fail_kill_text:format( name ) )
   end
end


-- Set up the ship, credits, and reputation based on the level.
function bounty_setup ()
   if level == 1 then
      ship = "Hyena"
      credits = 100e3 + rnd.sigma() * 30e3
      reputation = 0
   elseif level == 2 then
      ship = "Pirate Shark"
      credits = 300e3 + rnd.sigma() * 100e3
      reputation = 1
   elseif level == 3 then
      if rnd.rnd() < 0.5 then
         ship = "Pirate Vendetta"
      else
         ship = "Pirate Ancestor"
      end
      credits = 800e3 + rnd.sigma() * 160e3
      reputation = 3
   elseif level == 4 then
      if rnd.rnd() < 0.5 then
         ship = "Pirate Admonisher"
      else
         ship = "Pirate Phalanx"
      end
      credits = 1.4e6 + rnd.sigma() * 240e3
      reputation = 5
   elseif level == 5 then
      ship = "Pirate Kestrel"
      credits = 2.5e6 + rnd.sigma() * 500e3
      reputation = 7
   end
end


function board_fail ()
   if rnd.rnd() < 0.25 then
      board_failed = true
      credits = credits / 5
      local t = kill_instead_text[ rnd.rnd( 1, #kill_instead_text ) ]:format(
         name, creditstring( credits ) )
      tk.msg( kill_instead_title, t )
      osd_msg[2] = osd_msg_kill:format( name )
      misn.osdCreate( osd_title, osd_msg )
      misn.osdActive( 2 )
   end
end
