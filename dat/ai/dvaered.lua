require 'ai.core.core'
require "numstring"

-- Settings
mem.aggressive = true

local bribe_no_list = {
   _([["You insult my honour."]]),
   _([["I find your lack of honour disturbing."]]),
   _([["You disgust me."]]),
   _([["Bribery carries a harsh penalty."]]),
   _([["House Dvaered does not lower itself to common scum."]])
}
local taunt_list = {
   _("Prepare to face annihilation!"),
   _("I shall wash my hull in your blood!"),
   _("Your head will make a great trophy!"),
   _("You're no match for the Dvaered!"),
   _("Death awaits you!")
}

-- Create function
function create ()
   local p = ai.pilot()
   local ps = p:ship()

   -- Credits.
   ai.setcredits( rnd.rnd(ps:price()/300, ps:price()/100) )

   -- Handle misc stuff
   mem.loiter = 3 -- This is the amount of waypoints the pilot will pass through before leaving the system

   -- Set how far they attack
   mem.enemyclose = 3000 * ps:size()

   create_post()
end

-- When hailed
function hail ()
   if mem.setuphail then return end

   -- Handle refueling
   local standing = ai.getstanding( player.pilot() ) or -1
   if standing < 50 then
      mem.refuel_no = _([["You are not worthy of my attention."]])
   else
      mem.refuel = rnd.rnd( 1000, 3000 )
      mem.refuel_msg = string.format(_([["For you I could make an exception for %s."]]), creditstring(mem.refuel))
   end

   -- Handle bribing
   if rnd.rnd() > 0.4 then
      mem.bribe_no = _([["I shall especially enjoy your death."]])
   else
      mem.bribe_no = bribe_no_list[ rnd.rnd(1,#bribe_no_list) ]
   end

   mem.setuphail = true
end

-- taunts
function taunt ( target, offense )
   -- Only 50% of actually taunting.
   if rnd.rnd(0,1) == 0 then
      return
   end

   -- Offense is not actually used
   local taunts = taunt_list
   ai.pilot():comm( target, taunts[ rnd.rnd(1,#taunts) ] )
end

