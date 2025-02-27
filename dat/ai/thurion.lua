require 'ai.core.core'
require "numstring"

mem.shield_run = 20
mem.armour_run = 20
mem.defensive  = true
mem.enemyclose = 500
mem.distressmsgfunc = sos

local sos_msg_list = {
   _("Local security: requesting assistance!"),
   _("Requesting assistance. We are under attack!"),
   _("Vessel under attack! Requesting help!"),
   _("Help! Ship under fire!"),
   _("Taking hostile fire! Need assistance!"),
   _("We are under attack, require support!"),
   _("Mayday! Ship taking damage!"),
   _("01010101011011100110010001100101011100100010000001100001011101000111010001100001011000110110101100100001"), -- "Under attack!" in binary
}
local bribe_no_list = {
   _([["The Thurion will not be bribed!"]]),
   _([["I have no use for your money."]]),
   _([["Credits are no replacement for a good shield."]])
}

-- Sends a distress signal which causes faction loss
function sos ()
   ai.settarget( ai.taskdata() )
   ai.distress( sos_msg_list[ rnd.rnd(1,#sos_msg_list) ])
end

function create ()
   local price = ai.pilot():ship():price()

   -- Credits.
   ai.setcredits( rnd.rnd( price/500, price/200 ) )

   mem.loiter = 3 -- This is the amount of waypoints the pilot will pass through before leaving the system
   create_post()
end

function hail ()
   if mem.setuphail then return end

   -- Refuel
   mem.refuel = rnd.rnd( 1000, 3000 )
   mem.refuel_msg = string.format(_([["I'll supply your ship with fuel for %s."]]),
         creditstring(mem.refuel))

   -- No bribe
   mem.bribe_no = bribe_no_list[ rnd.rnd(1,#bribe_no_list) ]

   mem.setuphail = true
end
