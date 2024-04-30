-- mods/homeassistant/init.lua
-- =======================
-- A node to turn real light en switches on and off in your room within a Minetest world
-- Version 1.1 04-16-2024
--
-- By Jeff Schilders <jeff@schilders.com>
-- 
-- Bugs:
--
-- See README.txt for more information.

homeassistant = {}
homeassistant.mod = { author = "Jeff Schilders" }

local serverurl=minetest.settings:get("homeassistant_server_url")
local hatoken=minetest.settings:get("homeassistant_token")
local entity_name=minetest.settings:get("homeassistant_default")



local http = minetest.request_http_api()
assert(http, "HTTP API unavailable. Please add `homeassistant` to secure.trusted_mods in minetest.conf!")



local S = minetest.get_translator(minetest.get_current_modname())
if (minetest.get_modpath("intllib")) then
	S = intllib.Getter()
else
  S = function ( s ) return s end
end



minetest.register_node("homeassistant:ledbutton_off", {
  description = S("HA Light switch"),
  tiles = {
           -- up, down, right, left, back, front
           "button_side.png","button_side.png",
           "button_side.png","button_side.png",
           "button_side.png","button_side.png"
          },
  groups = {
    cracky = 3,
    oddly_breakable_by_hand = 3,
    mesecon_effector_off = 1
  },
  mesecons = {effector = {
    action_on = function (pos, node)
       webhook(pos,'turn_on')
       minetest.swap_node(pos, {name = "homeassistant:ledbutton_on", param2 = node.param2})	
    end   
  }},
  sounds = default.node_sound_glass_defaults(),
  on_construct = function(pos)
  end,
  after_place_node = function(pos, player, itemstack, pointed_thing)
    local meta = minetest.get_meta(pos)
    meta:set_string("entity_name", "")
  end,

  on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)

    local meta = minetest.get_meta(pos)
    local player = clicker:get_player_name()

    if meta:get_string("entity_name") == "" or itemstack:get_name() == "default:stick" then 

      if itemstack:get_name() == "default:stick" then
        entity_name=meta:get_string("entity_name")
      end

      minetest.show_formspec(clicker:get_player_name(), "homeassistant:setup",
      "formspec_version[6]"..
      "size[5,5]"..
      "label[0.5,0.4;Home Assistant Entiteits-id]"..
      "field[0.5,1.4;4,0.8;entity;Enter entity;"..entity_name.."]"..
      "button_exit[0.5,4;4,0.8;save;Save]"
      )    

      minetest.register_on_player_receive_fields(
         
          function(clicker, formname, fields)    
            if formname ~= "homeassistant:setup" then
              return false
            end
            if fields.entity == nil or fields.entity == "" then
              return false
            end

            local meta = minetest.get_meta(pos) 
            meta:set_string("entity_name",fields.entity)
            return true
          end  
      )      
       
    else
        webhook(pos,'turn_on')
        minetest.swap_node(pos, {name = "homeassistant:ledbutton_on", param2 = node.param2})	
    end  
  
  end
})

minetest.register_node("homeassistant:ledbutton_on", {
  drawtype = "nodebox",
  description = S("HA Light switch"),
  tiles = {
           -- up, down, right, left, back, front
           "button_side.png","button_side.png",
           "button_side.png","button_side.png",
           "button_side.png","button_side.png"
          },
  groups = {
    cracky = 3,
    oddly_breakable_by_hand = 3
  },
  light_source = 10,  
  groups = {not_in_creative_inventory=1,mesecon_effector_on = 1},
  sounds = default.node_sound_glass_defaults(),
  mesecons = {effector = {
    action_off = function (pos, node)
      webhook(pos,'turn_off')
      minetest.swap_node(pos, {name = "homeassistant:ledbutton_off", param2 = node.param2})	
    end  
	}},
  on_construct = function(pos)

  end,

  on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
    webhook(pos,'turn_off')
    minetest.swap_node(pos, {name = "homeassistant:ledbutton_off", param2 = node.param2})	
  end 

})




function webhook(pos,state)
  -- light/turn_off
  -- light/turn_on
  local meta = minetest.get_meta(pos)
  local entity_name=meta:get_string("entity_name")
  
  if entity_name ~= '' then
    data=string.split(entity_name, '.')
    local action=data[1]..'/'..state
    local request = {
      url = serverurl..'/api/services/'..action,
      method = 'POST',
      timeout = 15,
      post_data = minetest.write_json({entity_id = entity_name }),
      extra_headers = {
          "Authorization: Bearer "..hatoken
      }
    }
    http.fetch(request, function (response)
      print(dump(request))
      if response.code ~= 200 then 
        return false
      else 
        return true
      end  
    end)  
  end



end


