--[[
<?xml version='1.0' encoding='utf8'?>
<event name="Strafer's Ceremony">
 <trigger>enter</trigger>
 <chance>50</chance>
 <cond>
  system.cur():faction() == faction.get("Dvaered") and
  player.misnDone("Dvaered Meeting") and
  var.peek("invasion_time") and
  not (player.misnDone("Dvaered Ballet") or player.misnActive("Dvaered Ballet")) and
  not (system.cur() == system.get("Dvaer"))
 </cond>
 <notes>
  <done_misn name="Dvaered Meeting"/>
  <campaign>Frontier Invasion</campaign>
 </notes>
</event>
--]]
--[[
-- Player recieve an invitation for Strafer's ceremony
--]]

function create ()
   local invasion_time = var.peek("invasion_time")
   if time.get() < time.fromnumber(invasion_time) + time.create(0, 10, 0) then
      evt.finish()
   end

   timer      = hook.timer(20.0, "msgme")
   landhook   = hook.land("finish")
   jumpouthook= hook.jumpout("finish")
end

-- Player recieves the message
function msgme()
   naev.missionStart("Dvaered Ballet")
   evt.finish()
end

function finish()
   hook.rm(timer)
   evt.finish()
end
