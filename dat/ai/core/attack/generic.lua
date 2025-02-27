--[[
--    Generic attack functions
--]]


--[[
-- Required initialization function
--]]
function atk_generic_init ()
   mem.atk_think  = atk_generic_think
   mem.atk        = atk_generic
end


--[[
-- Mainly manages targeting nearest enemy.
--]]
function atk_generic_think( target, si )
   -- Get new target if it's closer
   local enemy  = ai.getenemy()
   if enemy ~= target and enemy ~= nil then
      local dist  = ai.dist( target )
      local range = ai.getweaprange( 3 )

      -- Shouldn't switch targets if close
      if dist > range * mem.atk_changetarget then
         ai.pushtask( "attack", enemy )
      end
   end
end


--[[
-- Attacked function.
--]]
function atk_generic_attacked( attacker )
   local task = ai.taskname()
   local si = _stateinfo( ai.taskname() )

   if mem.recharge then
      mem.recharge = false
   end

   -- If no target automatically choose it
   if not si.attack then
      ai.pushtask("attack", attacker)
      return
   end

   local target = ai.taskdata()
   if not target:exists() then
      ai.pushtask("attack", attacker)
      return
   end
   local tdist  = ai.dist(target)
   local dist   = ai.dist(attacker)
   local range  = ai.getweaprange( 0 )

   if target ~= attacker and dist < tdist and
         dist < range * mem.atk_changetarget then
      ai.pushtask("attack", attacker)
   end
end


--[[
-- Generic "brute force" attack.  Doesn't really do anything interesting.
--]]
function atk_generic( target )
   target = __atk_com_think( target )
   if target == nil then return end

   -- Targeting stuff
   ai.hostile(target) -- Mark as hostile
   ai.settarget(target)

   -- See if the enemy is still seeable
   if not __atk_check_seeable( target ) then return end

   -- Get stats about enemy
   local dist  = ai.dist( target ) -- get distance
   local range = ai.getweaprange( 3 )

   -- We first bias towards range
   if dist > range * mem.atk_approach and mem.ranged_ammo > mem.atk_minammo then
      __atk_g_ranged( target, dist )

   -- Now we do an approach
   elseif dist > range * mem.atk_aim then
      __atk_g_approach( target, dist )

   -- Close enough to melee
   else
      __atk_g_melee( target, dist )
   end
end


function ___atk_g_ranged_dogfight( target, dist )
   local dir
   if not mem.careful or dist < 3 * ai.getweaprange(3, 0) * mem.atk_approach then
      dir = ai.face(target) -- Normal face the target
   else
      dir = ai.careful_face(target) -- Careful method
   end

   -- Check if in range to shoot missiles
   if dist < ai.getweaprange( 4 ) then
      if dir < 30 then
         ai.weapset( 4 ) -- Weaponset 4 contains weaponset 9
      else
         ai.weapset( 9 )
      end
   else
      -- Test if we should zz
      if ai.pilot():stats().mass < 400 and __atk_decide_zz() then
         ai.pushsubtask("_atk_zigzag", target)
      end
   end

   -- Approach for melee
   if dir < 10 then
      ai.accel()
      ai.weapset( 3 ) -- Set turret/forward weaponset.
      ai.shoot()
   end
end
function ___atk_g_ranged_strafe( target, dist )
--[[ The pilot tries first to place himself at range and at constant velocity.
      When he is stabilized, he starts shooting until he has to correct his trajectory again

      If he doesn't manage to shoot missiles after a few seconds
      (because the target dodges),
      he gives up and just faces the target and shoot (provided he is in range)
]]

   local p = ai.pilot()

   -- Estimate the range
   local radial_vel = ai.relvel(target, true)
   local range = ai.getweaprange( 4 )
   range = math.min ( range - dist * radial_vel / ( ai.getweapspeed( 4 ) - radial_vel ), range )

   local goal = ai.follow_accurate(target, range * 0.8, 0, 10, 20, "keepangle")
   local mod = vec2.mod(goal - p:pos())

   --Must approach or stabilize
   if mod > 3000 then
      -- mustapproach allows a hysteretic behaviour
      mem.mustapproach = true
   end
   if dist > range*0.95 then
      mem.outofrange = true
   end

   if (mem.mustapproach and not ai.timeup(1) ) or mem.outofrange then
      local dir   = ai.face(goal)
      if dir < 10 and mod > 300 then
         ai.accel()
         --mem.stabilized = false
      -- ship must be stabilized since 2 secs
      elseif ai.relvel(target) < 5 and not ai.timeup(1) then--[[if not mem.stabilized then
         mem.stabilized = true
         ai.settimer(0, 2.0)
      elseif not ai.timeup(1) and ai.timeup(0) then
         -- If the ship manages to catch its mark, reset the timer]]
         --ai.settimer(1, 10.0)
         mem.mustapproach = false
      end
      if dist < range*0.85 then
         mem.outofrange = false
      end

   else -- In range
      local dir  = ai.face(target)
      if dir < 30 then
         ai.set_shoot_indicator(false)
         ai.weapset( 4 )
         -- If he managed to shoot, reinitialize the timer
         if ai.shoot_indicator() and not ai.timeup(1) then
            ai.settimer(1, 13.0)
         end
      end
   end

   --The pilot just arrived in the good zone :
   --From now, if ship doesn't manage to stabilize within a few seconds, shoot anyway
   if dist < 1.5*range and not mem.inzone then
      mem.inzone = true
      ai.settimer(1, mod/p:stats().speed*0.7 )
   end
end
function ___atk_g_ranged_kite( target, dist )
   local p = ai.pilot()

   -- Estimate the range
   local range = ai.getweaprange( 4 )

   -- Try to keep velocity vector away from enemy
   local targetpos = target:pos()
   local selfpos = p:pos()
   local unused, targetdir = (selfpos-targetpos):polar()
   local velmod, veldir = p:vel():polar()
   if velmod < 0.8*p:stats().speed or math.abs(targetdir-veldir) > 30 then
      local dir = ai.face( target, true )
      if math.abs(180-dir) < 30 then
         ai.accel()
      end
      return
   end

   -- We are flying away, so try to kite
   local dir = ai.aim(target) -- aim instead of facing
   if dir < 30 then
      if dist < range*0.95 then
         ai.weapset( 4 )
      end

      if dir < 10 then
         ai.weapset( 3 ) -- Set turret/forward weaponset.
         ai.shoot()
      end
      ai.shoot(true)
   end
end
--[[
-- Enters ranged combat with the target
--]]
function __atk_g_ranged( target, dist )
   local range = ai.getweaprange( 4 )
   local relvel = ai.relvel( target )
   local istargeted = (target:target()==ai.pilot())
   local wrange = math.min( ai.getweaprange(3,0), ai.getweaprange(3,1) )

   -- Pilot thinks dogfight is the best
   if ai.relhp(target)*ai.reldps(target) >= 0.25
         or ai.getweapspeed(4) < target:stats().speed_max*1.2
         or range < ai.getweaprange(1)*1.5 then
      ___atk_g_ranged_dogfight( target, dist )
   elseif target:target()==ai.pilot() and dist < range and ai.hasprojectile() then
      local tvel = target:vel()
      local pvel = ai.pilot():vel()
      local vel = (tvel-pvel):polar()
      -- If will make contact soon, try to engage
      if dist < wrange+8*vel then
         ___atk_g_ranged_dogfight( target, dist )
      else
      -- Getting chased, try to kite
         ___atk_g_ranged_kite( target, dist )
      end
   else
      -- Enemy is distracted, try to strafe and harass without engaging
      ___atk_g_ranged_strafe( target, dist )
   end

   -- Always launch fighters for now
   ai.weapset( 5 )
end


--[[
-- Approaches the target
--]]
function __atk_g_approach( target, dist )
   dir = ai.idir(target)
   if dir < 10 and dir > -10 then
      __atk_keep_distance()
   else
      dir = ai.iface(target)
   end
   if dir < 10 then
      ai.accel()
   end
end


--[[
-- Melees the target
--]]
function __atk_g_melee( target, dist )
   local dir   = ai.aim(target) -- We aim instead of face
   local range = ai.getweaprange( 3 )
   ai.weapset( 3 ) -- Set turret/forward weaponset.

   -- Drifting away we'll want to get closer
   if dir < 10 and dist > 0.5*range and ai.relvel(target) > -10 then
      ai.accel()
   end

   -- Shoot if should be shooting.
   if dir < 10 then
      ai.shoot()
   end
   ai.shoot(true)

   -- Also try to shoot missiles
   __atk_dogfight_seekers( dist, dir )
end
