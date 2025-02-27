--[[
<?xml version='1.0' encoding='utf8'?>
<mission name="Dead Or Alive Bounty">
  <avail>
   <priority>4</priority>
   <cond>player.numOutfit("Mercenary License") &gt; 0</cond>
   <chance>360</chance>
   <location>Computer</location>
   <faction>Dvaered</faction>
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

   Dead or Alive Pirate Bounty

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

   Generalized replacement for bobbens' Empire Pirate Bounty mission.
   Can work with any faction.

--]]

require "numstring"
require "jumpdist"
require "pilot/pirate"

subdue_title   = _("Captured Alive")
subdue_text    = {}
subdue_text[1] = _("You and your crew infiltrate the ship's pathetic security and subdue %s. You transport the pirate to your ship.")
subdue_text[2] = _("Your crew has a difficult time getting past the ship's security, but eventually succeeds and subdues %s.")
subdue_text[3] = _("The pirate's security system turns out to be no match for your crew. You infiltrate the ship and capture %s.")
subdue_text[4] = _("Your crew infiltrates the pirate's ship and captures %s.")
subdue_text[5] = _("Getting past this ship's security was surprisingly easy. Didn't they know that %s was wanted?")

subdue_fail_title   = _("Capture Failed")
subdue_fail_text    = {}
subdue_fail_text[1] = _("Try as you might, you cannot get past the pirate's security system. Defeated, you and your crew return to the ship.")
subdue_fail_text[2] = _("The ship's security system locks you out.")
subdue_fail_text[3] = _("Your crew comes close to getting past the pirate's security system, but ultimately fails.")
subdue_fail_text[4] = _("It seems your crew is no match for this ship's security system. You return to your ship.")

pay_title   = _("Mission Completed")

pay_kill_text    = {}
pay_kill_text[1] = _("After verifying that you killed %s, an officer hands you your pay.")
pay_kill_text[2] = _("After verifying that %s is indeed dead, the tired-looking officer smiles and hands you your pay.")
pay_kill_text[3] = _("The officer seems pleased that %s is finally dead. They thank you and promptly hand you your pay.")
pay_kill_text[4] = _("The paranoid-looking officer takes you into a locked room, where the death of %s is quietly verified. The officer then pays you and sends you off.")
pay_kill_text[5] = _("When you ask the officer for your bounty on %s, they sigh, lead you into an office, go through some paperwork, and hand you your pay, mumbling something about how useless the bounty system is.")
pay_kill_text[6] = _("The officer verifies the death of %s, goes through the necessary paperwork, and hands you your pay, looking bored the entire time.")

pay_capture_text    = {}
pay_capture_text[1] = _("An officer takes %s into custody and hands you your pay.")
pay_capture_text[2] = _("The officer seems to think your decision to capture %s alive was foolish. They carefully take the pirate off your hands, taking precautions you think are completely unnecessary, and then hand you your pay")
pay_capture_text[3] = _("The officer you deal with seems to especially dislike %s. The pirate is taken off your hands and you are handed your pay without a word.")
pay_capture_text[4] = _("A fearful-looking officer rushes %s into a secure hold, pays you the appropriate bounty, and then hurries off.")
pay_capture_text[5] = _("The officer you greet gives you a puzzled look when you say that you captured %s alive. Nonetheless, they politely take the pirate off of your hands and hand you your pay.")

share_title   = _("A Smaller Reward")
share_text    = {}
share_text[1] = _([["Greetings. I can see that you were trying to collect a bounty on %s. Well, as you can see, I earned the bounty, but I don't think I would have succeeded without your help, so I've transferred a portion of the bounty into your account."]])
share_text[2] = _([["Sorry about getting in the way of your bounty. I don't really care too much about the money, but I just wanted to make sure the galaxy would be rid of that scum; I've seen the villainy of %s first-hand, you see. So as an apology, I would like to offer you the portion of the bounty you clearly earned. The money will be in your account shortly."]])
share_text[3] = _([["Hey, thanks for the help back there. I don't know if I would have been able to handle %s alone! Anyway, since you were such a big help, I have transferred what I think is your fair share of the bounty to your bank account."]])
share_text[4] = _([["Heh, thanks! I think I would have been able to take out %s by myself, but still, I appreciate your assistance. Here, I'll transfer some of the bounty to you, as a token of my appreciation."]])
share_text[5] = _([["Ha ha ha, looks like I beat you to it this time, eh? Well, I don't do this often, but here, have some of the bounty. I think you deserve it."]])

-- Mission details
misn_title = {}
misn_title[1] = _("Tiny Dead or Alive Bounty in %s")
misn_title[2] = _("Small Dead or Alive Bounty in %s")
misn_title[3] = _("Moderate Dead or Alive Bounty in %s")
misn_title[4] = _("High Dead or Alive Bounty in %s")
misn_title[5] = _("Dangerous Dead or Alive Bounty in %s")
misn_desc   = _("The pirate known as %s was recently seen in the %s system. %s authorities want this pirate dead or alive.")

-- Messages
msg    = {}
msg[1] = _("MISSION FAILURE! %s got away.")
msg[2] = _("MISSION FAILURE! Another pilot eliminated %s.")
msg[3] = _("MISSION FAILURE! You have left the %s system.")

osd_title = _("Bounty Hunt")
osd_msg    = {}
osd_msg[1] = _("Fly to the %s system")
osd_msg[2] = _("Kill or capture %s")
osd_msg[3] = _("Land in %s territory to collect your bounty")
osd_msg["__save"] = true


hunters = {}
hunter_hits = {}


function create ()
   paying_faction = planet.cur():faction()
   target_faction = faction.get( "Pirate" )

   local systems = getsysatdistance( system.cur(), 1, 3,
      function(s)
         local p = s:presences()["Pirate"]
         return p ~= nil and p > 0
      end )

   if #systems == 0 then
      -- No pirates nearby
      misn.finish( false )
   end

   missys = systems[ rnd.rnd( 1, #systems ) ]
   if not misn.claim( missys ) then misn.finish( false ) end

   jumps_permitted = system.cur():jumpDist(missys) + rnd.rnd( 5 )
   if rnd.rnd() < 0.05 then
      jumps_permitted = jumps_permitted - 1
   end

   local num_pirates = missys:presences()["Pirate"]
   if num_pirates <= 25 then
      level = 1
   elseif num_pirates <= 50 then
      level = rnd.rnd( 1, 2 )
   elseif num_pirates <= 75 then
      level = rnd.rnd( 2, 3 )
   elseif num_pirates <= 100 then
      level = rnd.rnd( 3, 4 )
   else
      level = rnd.rnd( 4, #misn_title )
   end

   name = pirate_name()
   ship = "Hyena"
   credits = 50000
   reputation = 0
   board_failed = false
   bounty_setup()

   -- Set mission details
   misn.setTitle( misn_title[level]:format( missys:name() ) )
   misn.setDesc( misn_desc:format( name, missys:name(), paying_faction:name() ) )
   misn.setReward( creditstring( credits ) )
   marker = misn.markerAdd( missys, "computer" )
end


function accept ()
   misn.accept()

   osd_msg[1] = osd_msg[1]:format( missys:name() )
   osd_msg[2] = osd_msg[2]:format( name )
   osd_msg[3] = osd_msg[3]:format( paying_faction:name() )
   misn.osdCreate( osd_title, osd_msg )

   last_sys = system.cur()
   job_done = false
   target_killed = false

   hook.jumpin( "jumpin" )
   hook.jumpout( "jumpout" )
   hook.takeoff( "takeoff" )
   hook.land( "land" )
end


function jumpin ()
   -- Nothing to do.
   if system.cur() ~= missys then
      return
   end

   local pos = jump.pos( system.cur(), last_sys )
   local offset_ranges = { { -2500, -1500 }, { 1500, 2500 } }
   local xrange = offset_ranges[ rnd.rnd( 1, #offset_ranges ) ]
   local yrange = offset_ranges[ rnd.rnd( 1, #offset_ranges ) ]
   pos = pos + vec2.new( rnd.rnd( xrange[1], xrange[2] ), rnd.rnd( yrange[1], yrange[2] ) )
   spawn_pirate( pos )
end


function jumpout ()
   jumps_permitted = jumps_permitted - 1
   last_sys = system.cur()
   if not job_done and last_sys == missys then
      fail( msg[3]:format( last_sys:name() ) )
   end
end


function takeoff ()
   spawn_pirate()
end


function land ()
   jumps_permitted = jumps_permitted - 1
   if job_done and planet.cur():faction() == paying_faction then
      local pay_text
      if target_killed then
         pay_text = pay_kill_text[ rnd.rnd( 1, #pay_kill_text ) ]
      else
         pay_text = pay_capture_text[ rnd.rnd( 1, #pay_capture_text ) ]
      end
      tk.msg( pay_title, pay_text:format( name ) )
      player.pay( credits )
      paying_faction:modPlayerSingle( reputation )
      misn.finish( true )
   end
end


function pilot_disable ()
   if rnd.rnd() < 0.7 then
      for i, j in ipairs( pilot.get() ) do
         j:taskClear()
      end
   end
end


function pilot_board ()
   player.unboard()
   if can_capture then
      local t = subdue_text[ rnd.rnd( 1, #subdue_text ) ]:format( name )
      tk.msg( subdue_title, t )
      succeed()
      target_killed = false
      target_ship:changeAI( "dummy" )
      target_ship:setHilight( false )
      target_ship:disable() -- Stop it from coming back
      if death_hook ~= nil then hook.rm( death_hook ) end
   else
      local t = subdue_fail_text[ rnd.rnd( 1, #subdue_fail_text ) ]:format( name )
      tk.msg( subdue_fail_title, t )
      board_fail()
   end
end


function pilot_attacked( p, attacker, dmg )
   if attacker ~= nil then
      local found = false

      for i, j in ipairs( hunters ) do
         if j == attacker then
            hunter_hits[i] = hunter_hits[i] + dmg
            found = true
         end
      end

      if not found then
         local i = #hunters + 1
         hunters[i] = attacker
         hunter_hits[i] = dmg
      end
   end
end


function pilot_death( p, attacker )
   if attacker == player.pilot() or attacker:leader() == player.pilot() then
      succeed()
      target_killed = true
   else
      local top_hunter = nil
      local top_hits = 0
      local player_hits = 0
      local total_hits = 0
      for i, j in ipairs( hunters ) do
         total_hits = total_hits + hunter_hits[i]
         if j ~= nil and j:exists() then
            if j == player.pilot() or j:leader() == player.pilot() then
               player_hits = player_hits + hunter_hits[i]
            elseif hunter_hits[i] > top_hits then
               top_hunter = j
               top_hits = hunter_hits[i]
            end
         end
      end

      if top_hunter == nil or player_hits >= top_hits then
         succeed()
         target_killed = true
      elseif player_hits >= top_hits / 2 and rnd.rnd() < 0.5 then
         hailer = hook.pilot( top_hunter, "hail", "hunter_hail", top_hunter )
         credits = credits * player_hits / total_hits
         hook.pilot( top_hunter, "jump", "hunter_leave" )
         hook.pilot( top_hunter, "land", "hunter_leave" )
         hook.jumpout( "hunter_leave" )
         hook.land( "hunter_leave" )
         player.msg( "#r" .. msg[2]:format( name ) .. "#0" )
         hook.timer( 3.0, "timer_hail", top_hunter )
         misn.osdDestroy()
      else
         fail( msg[2]:format( name ) )
      end
   end
end


function pilot_jump ()
   fail( msg[1]:format( name ) )
end


function timer_hail( arg )
   if arg ~= nil and arg:exists() then
      arg:hailPlayer()
   end
end


function hunter_hail( arg )
   if hailer ~= nil then hook.rm( hailer ) end
   if rehailer ~= nil then hook.rm( rehailer ) end
   player.commClose()

   local text = share_text[ rnd.rnd( 1, #share_text ) ]
   tk.msg( share_title, text:format( name ) )

   player.pay( credits )
   misn.finish( true )
end


function hunter_leave ()
   misn.finish( false )
end


-- Set up the ship, credits, and reputation based on the level.
function bounty_setup ()
   if level == 1 then
      ship = "Hyena"
      credits = 50e3 + rnd.sigma() * 15e3
      reputation = 0
   elseif level == 2 then
      ship = "Pirate Shark"
      credits = 150e3 + rnd.sigma() * 50e3
      reputation = 0
   elseif level == 3 then
      if rnd.rnd() < 0.5 then
         ship = "Pirate Vendetta"
      else
         ship = "Pirate Ancestor"
      end
      credits = 400e3 + rnd.sigma() * 80e3
      reputation = 1
   elseif level == 4 then
      if rnd.rnd() < 0.5 then
         ship = "Pirate Admonisher"
      else
         ship = "Pirate Phalanx"
      end
      credits = 700e3 + rnd.sigma() * 120e3
      reputation = 2
   elseif level == 5 then
      ship = "Pirate Kestrel"
      credits = 1.2e6 + rnd.sigma() * 200e3
      reputation = 4
   end
end


-- Spawn the ship at the location param.
function spawn_pirate( param )
   if not job_done and system.cur() == missys then
      if jumps_permitted >= 0 then
         misn.osdActive( 2 )
         target_ship = pilot.add( ship, target_faction or "Pirate", param )
         local mem = target_ship:memory()
         mem.loiter = math.huge -- Should make them loiter forever
         set_faction( target_ship )
         target_ship:rename( name )
         target_ship:setHilight( true )
         hook.pilot( target_ship, "disable", "pilot_disable" )
         hook.pilot( target_ship, "board", "pilot_board" )
         hook.pilot( target_ship, "attacked", "pilot_attacked" )
         death_hook = hook.pilot( target_ship, "death", "pilot_death" )
         pir_jump_hook = hook.pilot( target_ship, "jump", "pilot_jump" )
         pir_land_hook = hook.pilot( target_ship, "land", "pilot_jump" )


         --[[
         local pir_crew = target_ship:stats().crew
         local pl_crew = player.pilot():stats().crew
         if rnd.rnd() > (0.5 * (10 + pir_crew) / (10 + pl_crew)) then
            can_capture = true
         else
            can_capture = false
         end
         --]]
         -- Disabling and boarding is hard enough as is to randomly fail
         -- TODO potentially do a small capturing minigame here
         can_capture = true
      else
         fail( msg[1]:format( name ) )
      end
   end
end


-- Adjust pirate faction (used for "alive" bounties)
function set_faction( p )
   if not _target_faction then
      _target_faction = faction.dynAdd( "Pirate", "Wanted Pirate", _("Wanted Pirate"), {clear_enemies=true, clear_allies=true} )
   end
   p:setFaction( _target_faction )
end


-- Fail to board the ship; must kill the target instead
-- (Unused in this mission; used by pirbounty_alive)
function board_fail ()
   board_failed = true
end


-- Succeed the mission, make the player head to a planet for pay
function succeed ()
   job_done = true
   misn.osdActive( 3 )
   if marker ~= nil then
      misn.markerRm( marker )
   end
   if pir_jump_hook ~= nil then
      hook.rm( pir_jump_hook )
   end
   if pir_land_hook ~= nil then
      hook.rm( pir_land_hook )
   end
end


-- Fail the mission, showing message to the player.
function fail( message )
   if message ~= nil then
      -- Pre-colourized, do nothing.
      if message:find("#") then
         player.msg( message )
      -- Colourize in red.
      else
         player.msg( "#r" .. message .. "#0" )
      end
   end
   misn.finish( false )
end
