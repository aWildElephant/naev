--[[
<?xml version='1.0' encoding='utf8'?>
<event name="Pirate Fame">
  <trigger>enter</trigger>
  <chance>100</chance>
 </event>
 --]]

--[[
-- Pirate Fame/Faction Standing script

   When the player enters a system, his fame has a chance of being lowered.

   If he is using a pirate ship, the chances of his fame being lowered are
   reduced. If the player is using an impressive non-pirate ship, like the
   cruiser or carrier of a major faction, will lower a bit less often, but
   will lower more often than if he was using a purely pirate ship.

   This event will not reduce the player’s fame below a given level.

--]]

--[[
-- Returns a boolean indicating whether or not the player is using a pirate
-- ship.
--]]
local function using_pirate_ship()
   local pirships = {
      ["Hyena"]            = true,
      ["Pirate Kestrel"]   = true,
      ["Pirate Admonisher"]= true,
      ["Pirate Phalanx"]   = true,
      ["Pirate Ancestor"]  = true,
      ["Pirate Vendetta"]  = true,
      ["Pirate Shark"]     = true,
      ["Pirate Starbridge"]= true,
      ["Pirate Rhino"]     = true,
   }
   return pirships[ player.pilot():ship():nameRaw() ]
end

--[[
-- Returns a boolean indicating whether or not the player is using some
-- kind of monstrously powerful or intimidating ship, like a
-- cruiser or carrier.
--]]
local function using_impressive_ship()
   local c = player.pilot():ship():class()
   return ( c == "Cruiser" or c == "Carrier" or c == "Battleship" )
end

function create()
   local fame = faction.playerStanding("Pirate")

   local floor = var.peek("_ffloor_decay_pirate")
   if floor == nil then floor = -20 end
   if fame <= floor then
      evt.finish()
   end

   local amt
   if using_pirate_ship() then
      amt = 0.15 + rnd.sigma() * 0.05
   elseif using_impressive_ship() then
      amt = 0.5 + rnd.sigma() * 0.10
   else
      amt = 1 + rnd.sigma() * 0.25
   end

   faction.modPlayerSingle( "Pirate", -amt )

   evt.finish()
end

