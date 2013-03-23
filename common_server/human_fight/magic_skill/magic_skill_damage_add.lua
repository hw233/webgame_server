require("human_fight.magic_skill.magic_base_skill")
local _config = require("config.obj_config")

local _random = crypto.random

--����һ 2�˺�Ϊ�ȼ�*ϵ���ı����˺� {���ʣ�ϵ��}
Skill_882000 = oo.class(Magic_skill_damage_add, "Skill_882000")

function Skill_882000:on_effect(param)
	local obj_s = param.obj_s
	local obj_d = param.obj_d
	local factor = param.factor
	--self:send_syn(obj_s, obj_d:get_id(), nil, 2)
	local damage_add = math.max(0, math.floor(obj_s:get_level() * factor - obj_d:get_ice_de_t()))
	return {0, damage_add}
end
f_skill_magic_damage_add_builder(SKILL_OBJ_882000)


--����һ 3�˺�Ϊ�ȼ�*ϵ���Ķ����˺� {���ʣ�ϵ��}
Skill_882100 = oo.class(Magic_skill_damage_add, "Skill_882100")

function Skill_882100:on_effect(param)
	local obj_s = param.obj_s
	local obj_d = param.obj_d
	local factor = param.factor
	--self:send_syn(obj_s, obj_d:get_id(), nil, 2)
	local damage_add = math.max(0, math.floor(obj_s:get_level() * factor - obj_d:get_poison_de_t()))
	return {0, damage_add}
end
f_skill_magic_damage_add_builder(SKILL_OBJ_882100)

--����һ 4�˺�Ϊ�ȼ�*ϵ���Ķ����˺� {���ʣ�ϵ��}
Skill_882200 = oo.class(Magic_skill_damage_add, "Skill_882200")

function Skill_882200:on_effect(param)
	local obj_s = param.obj_s
	local obj_d = param.obj_d
	local factor = param.factor
	--self:send_syn(obj_s, obj_d:get_id(), nil, 2)
	local damage_add = math.max(0, math.floor(obj_s:get_level() * factor - obj_d:get_fire_de_t()))
	return {0, damage_add}
end
f_skill_magic_damage_add_builder(SKILL_OBJ_882200)

--������ 2ʩ����Ϯʱ���Ӹ��ǵ���*ϵ���ı����˺�,�����ͷŵ��峰��(�������Ч) {���ʣ�ϵ��}
Skill_882300 = oo.class(Magic_skill_damage_add, "Skill_882300")

function Skill_882300:on_effect(param)
	local obj_s = param.obj_s
	local obj_d = param.obj_d
	local factor = param.factor
	local damage_add = math.max(0, math.floor(obj_s:get_strengh_t() * factor - obj_d:get_ice_de_t()))
	return {0, damage_add}
end
f_skill_magic_damage_add_builder(SKILL_OBJ_882300)

--������ 3ʩ�ŷ�ѩ���裬���Ը��Ӹ��ǵ���*ϵ���ı����˺� {���ʣ�ϵ��}
Skill_882400 = oo.class(Magic_skill_damage_add, "Skill_882400")

function Skill_882400:on_effect(param)
	local obj_s = param.obj_s
	local obj_d = param.obj_d
	local factor = param.factor
	local damage_add = math.max(0, math.floor(obj_s:get_strengh_t() * factor - obj_d:get_ice_de_t()))
	return {0, damage_add}
end
f_skill_magic_damage_add_builder(SKILL_OBJ_882400)

--������ 5��ͨ�����ḽ�Ӷ���������﹥*ϵ�����﹥�˺� {���ʣ�ϵ��}
Skill_882500 = oo.class(Magic_skill_damage_add, "Skill_882500")

function Skill_882500:on_effect(param)
	local obj_s = param.obj_s
	local obj_d = param.obj_d
	local factor = param.factor
	local attack_min, attack_max = obj_s:get_s_attack_t()
	local attack = _random(attack_min, attack_max)
	local attack_p = _config._attack_param[obj_s:get_occ()][obj_s:get_level()]
	local damage_add = math.max(0, math.floor(attack * factor * (3-2*obj_s:get_hp()/obj_s:get_max_hp()) * attack_p / obj_d:get_s_defense_t()))
	return {0, damage_add}
end
f_skill_magic_damage_add_builder(SKILL_OBJ_882500)

--������ 2�����ƿտ��Ը������Ե���*ϵ�����׹��˺� {���ʣ�ϵ��}
Skill_882600 = oo.class(Magic_skill_damage_add, "Skill_882600")

function Skill_882600:on_effect(param)
	local obj_s = param.obj_s
	local obj_d = param.obj_d
	local factor = param.factor
	local damage_add = math.max(0, math.floor(obj_s:get_intelligence_t() * factor - obj_d:get_fire_de_t()))
	return {0, damage_add}
end
f_skill_magic_damage_add_builder(SKILL_OBJ_882600)

--������ 4�ͷ����ľ��ḽ��������ֵ*ϵ�����׹��˺� {���ʣ�ϵ��}
Skill_882700 = oo.class(Magic_skill_damage_add, "Skill_882700")

function Skill_882700:on_effect(param)
	local obj_s = param.obj_s
	local obj_d = param.obj_d
	local factor = param.factor
	local damage_add = math.max(0, math.floor(obj_s:get_mp() * factor - obj_d:get_fire_de_t()))
	return {0, damage_add}
end
f_skill_magic_damage_add_builder(SKILL_OBJ_882700)

--������ 2����ӳ�¿��Ը������Ե���*ϵ���Ķ����˺� {���ʣ�ϵ��}
Skill_882800 = oo.class(Magic_skill_damage_add, "Skill_882800")

function Skill_882800:on_effect(param)
	local obj_s = param.obj_s
	local obj_d = param.obj_d
	local factor = param.factor
	local damage_add = math.max(0, math.floor(obj_s:get_intelligence_t() * factor - obj_d:get_poison_de_t()))
	return {0, damage_add}
end
f_skill_magic_damage_add_builder(SKILL_OBJ_882800)

--������ 3��ˮ������������ֵ����50%��Ŀ��ʱ�����⸽�ӷ���*ϵ���ķ����˺� {���ʣ�ϵ��}
Skill_882900 = oo.class(Magic_skill_damage_add, "Skill_882900")

function Skill_882900:on_effect(param)
	local obj_s = param.obj_s
	local obj_d = param.obj_d
	local factor = param.factor
	if obj_d:get_hp() / obj_d:get_max_hp() < 0.5 then
		return {0, 0}
	end
	local attack_min, attack_max = obj_s:get_m_attack_t()
	local attack = _random(attack_min, attack_max)
	local attack_p = _config._attack_param[obj_s:get_occ()][obj_s:get_level()]
	local damage_add = math.max(0, math.floor(attack * factor * attack_p / obj_d:get_m_defense_t()))
	return {0, damage_add}
end
f_skill_magic_damage_add_builder(SKILL_OBJ_882900)

--������ 2ʹ����Ϯ��ʱ�����x%���������������������*ϵ�����˺���Ѫ������30%ʱ��Ч {���ʣ����������ٷֱȣ�ϵ��}
Skill_883000 = oo.class(Magic_skill_damage_add, "Skill_883000")

function Skill_883000:on_effect(param)
	local obj_s = param.obj_s
	local obj_d = param.obj_d
	if obj_d == nil or obj_s:get_hp() / obj_s:get_max_hp() < 0.3 then
		return {0, 0}
	end
	local factor = math.floor(param.factor * obj_s:get_hp())
	local damage_add = math.floor(param.trouble * factor)
	obj_s:del_hp(factor)
	return {0, damage_add}
end
f_skill_magic_damage_add_builder(SKILL_OBJ_883000)

--������ 4ħ����깥������������50%��Ŀ��ʱ�����⸽�ӷ���*ϵ�����˺� {���ʣ�ϵ��}
Skill_883100 = oo.class(Magic_skill_damage_add, "Skill_883100")

function Skill_883100:on_effect(param)
	local obj_s = param.obj_s
	local obj_d = param.obj_d
	if obj_d:get_hp() / obj_d:get_max_hp() > 0.5 then
		return {0, 0}
	end
	local factor = param.factor
	local attack_min, attack_max = obj_s:get_m_attack_t()
	local attack = _random(attack_min, attack_max)
	local attack_p = _config._attack_param[obj_s:get_occ()][obj_s:get_level()]
	local damage_add = math.max(0, math.floor(attack * factor * attack_p / obj_d:get_m_defense_t()))
	return {0, damage_add}
end
f_skill_magic_damage_add_builder(SKILL_OBJ_883100)


