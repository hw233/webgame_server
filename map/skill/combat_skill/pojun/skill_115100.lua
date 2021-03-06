
local _expr = require("config.expr")
local _sk_config = require("config.skill_combat_config")

--破魂
Skill_115100 = oo.class(Skill_combat, "Skill_115100")

function Skill_115100:__init(cmd_id, lv)
	Skill_combat.__init(self, cmd_id, SKILL_BAD, SKILL_OBJ_115100, lv)
	self.ak = _sk_config._skill_p[SKILL_OBJ_115100][lv][2]
	self.silence_add = _sk_config._skill_p[SKILL_OBJ_115100][lv][3]
	self.boss_add = _sk_config._skill_p[SKILL_OBJ_115100][lv][4]
end
--param.des_id
function Skill_115100:effect(sour_id, param)
	--print("Skill_115100:effect", sour_id)
	local obj_s = g_obj_mgr:get_obj(sour_id)
	local obj_d = g_obj_mgr:get_obj(param.des_id)
	if obj_s == nil or obj_d == nil then 
		return 21101 
	end
	if not self:is_validate_dis(obj_s, obj_d) then
		return 21131
	end
	
	local scene_o = obj_s:get_scene_obj()
	local md_ret = scene_o:is_attack(sour_id, param.des_id)
	if md_ret ~= 0 then
		return md_ret
	end
	local ret = obj_d:on_beskill(self.id, obj_s)
	if ret == 2 then
		--套装附加攻击
		local set_l = obj_s:get_set_effect(SKILL_ADD_ATTACK, SKILL_OBJ_115100)
		local ak = self.ak + set_l[1] + self.ak*set_l[2]

		local new_pkt = self:make_hp_pkt(obj_s, obj_d, ak)
		if obj_d:get_type() == OBJ_TYPE_HUMAN then
			if obj_d:is_silence()  then
				new_pkt[3] = new_pkt[3] * self.silence_add
				new_pkt.hp = new_pkt[3]
			end
		elseif obj_d:get_type() == OBJ_TYPE_MONSTER then
			if obj_d:is_boss()  then
				new_pkt[3] = new_pkt[3] * self.boss_add
				new_pkt.hp = new_pkt[3]
			end
		end
		obj_s:on_useskill(self.id, obj_d, new_pkt.hp)
		if obj_d:on_damage(new_pkt.hp, obj_s, self.id) then
			self:send_syn(obj_s, param.des_id, new_pkt, ret)
		end
		
		--print("Skill_115100:effect", sour_id, param.des_id, ak)
		return 0
	elseif ret == 1 then
		self:send_syn(obj_s, param.des_id, nil, ret)
		return 0
	end
	return 21002
end



f_create_skill_class("SKILL_OBJ_1151%02d", "Skill_1151%02d")

