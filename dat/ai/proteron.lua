require 'ai.core.core'
require "numstring"

-- Settings
mem.armour_run = 40
mem.armour_return = 70
mem.aggressive = true

local bribe_no_list = {
   _([["You won't buy your way out of this one."]]),
   _([["We like to make examples out of scum like you."]]),
   _([["You've made a huge mistake."]]),
   _([["Bribery carries a harsh penalty, scum."]]),
   _([["I'm not interested in your blood money!"]]),
   _([["All the money in the world won't save you now!"]])
}

function create ()
   -- Not too many credits.
   ai.setcredits( rnd.rnd(ai.pilot():ship():price()/300, ai.pilot():ship():price()/70) )

   -- Lines to annoy the player.
   local r = rnd.rnd(0,20)
   if r == 0 then
      ai.pilot():broadcast(_("The Proteron are watching you."))
   end

   mem.loiter = 3 -- This is the amount of waypoints the pilot will pass through before leaving the system

   -- Finish up creation
   create_post()
end

function hail ()
   if mem.setuphail then return end

   -- Get refuel chance
   local standing = ai.getstanding( player.pilot() ) or -1
   mem.refuel = rnd.rnd( 2000, 4000 )
   if standing < 0 then
      mem.refuel_no = _([["My fuel isn't for sale."]])
   elseif standing < 50 then
      if rnd.rnd() > 0.8 then
         mem.refuel_no = _([["Sorry, my fuel isn't for sale."]])
      end
   else
      mem.refuel = mem.refuel * 0.6
   end
   -- Most likely no chance to refuel
   mem.refuel_msg = string.format( _([["I can transfer some fuel for %s."]]), creditstring(mem.refuel) )

   -- See if can be bribed
   mem.bribe = math.sqrt( ai.pilot():stats().mass ) * (500. * rnd.rnd() + 1750.)
   if (mem.natural or mem.allowbribe) and rnd.rnd() > 0.6 then
      mem.bribe_prompt = string.format(_([["The Proteron can always use some income. %s and you were never here."]]), creditstring(mem.bribe) )
      mem.bribe_paid = _([["Get lost before I have to dispose of you."]])
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

   -- some taunts
   local taunts
   if offense then
      taunts = {
            _("Animals like you don't deserve to live!"),
            _("Begone from this universe, inferior scum!"),
            _("We will cleanse you and all other scum from this universe!"),
            _("Enemies of the state will not be tolerated!"),
            _("Long live the Proteron!"),
            _("War is peace!"),
            _("Freedom is slavery!"),
      }
   else
      taunts = {
            _("How dare you attack the Proteron?!"),
            _("I will have your head!"),
            _("You'll regret that!"),
            _("Your fate has been sealed, dissident!"),
            _("You will pay for your treason!"),
            _("Die along with the old Empire!"),
      }
   end

   ai.pilot():comm(target, taunts[ rnd.rnd(1,#taunts) ])
end


