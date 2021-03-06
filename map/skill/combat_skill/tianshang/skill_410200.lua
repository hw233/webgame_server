
--local debug_print = print
local debug_print = function() end
local _expr = require("config.expr")
local _sk_config = require("config.skill_combat_config")

--斗转星移
Skill_410200 = oo.class(Skill_combat, "Skill_410200")

function Skill_410200:__init(cmd_id, lv)
	Skill_combat.__init(self, cmd_id, SKILL_GOOD, SKILL_OBJ_410200, lv)
	self.va_dis = _sk_config._skill_p[SKILL_OBJ_410200][lv][2]        --有效距离
end
--param.des_id
function Skill_410200:effect(sour_id, param)
	local obj_s = g_obj_mgr:get_obj(sour_id)
	if obj_s == nil or param.pos == nil then 
		return 21101 
	end
	
	local scene_o = obj_s:get_scene_obj()
	local map_obj = scene_o:get_map_obj()
	local ret = obj_s:on_beskill(self.id, obj_s)
	if ret == 2 then
		local pos = obj_s:get_pos()
		local des_pos = param.pos
		if map_obj:distance(pos, des_pos) > self.va_dis + 3 then
			return 21131
		end

		--解除定身效果
		local impact_con = obj_s:get_impact_con()
		impact_con:blow_impact(IMPACT_OBJ_1211)
		impact_con:blow_impact(IMPACT_OBJ_1212)

		--移动坐标
		obj_s:modify_pos(des_pos)
		scene_o:send_move_soon_syn(sour_id, obj_s, pos, des_pos, 1)
		obj_s:on_useskill(self.id, obj_s, 0)
		self:send_syn(obj_s, nil, nil, ret)
		return 0
	elseif ret == 1 then
		scene_o:send_move_soon_syn(sour_id, obj_s, pos, des_pos, 1)
		self:send_syn(obj_s, nil, nil, ret)
		return 0
	end
	return 21002
end


f_create_skill_class("SKILL_OBJ_4102%02d", "Skill_4102%02d")

