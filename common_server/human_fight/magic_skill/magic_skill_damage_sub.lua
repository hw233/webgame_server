
require("human_fight.magic_skill.magic_base_skill")

--������ 5�ܵ��������˺�����5%~15% {���ʣ������˺��ٷݱ�}
Skill_883500 = oo.class(Magic_skill_damage_sub, "Skill_883500")

function Skill_883500:on_effect(param)
	--local obj_s = param.obj_s
	--local obj_d = param.obj_d
	local factor = param.factor
	return {factor, 0}
end
f_skill_magic_damage_sub_builder(SKILL_OBJ_883500)

--������ 3����ֵ����20%ʱ�������������˺�����50% {���ʣ������˺��ٷݱ�}
Skill_883600 = oo.class(Magic_skill_damage_sub, "Skill_883600")

function Skill_883600:on_effect(param)
	local obj_s = param.obj_s
	local obj_d = param.obj_d
	if obj_d:get_mp() / obj_d:get_max_mp() > 0.2 then
		return {0, 0}
	end
	local factor = param.factor
	return {factor, 0}
end
f_skill_magic_damage_sub_builder(SKILL_OBJ_883600)

--������ 5����100~1000����˺���ÿ���˺���x�㷨��ֵ������ħ������20%ʱ��Ч {���ʣ����˺�����, 1���˺��ּ��㷨��}
Skill_883700 = oo.class(Magic_skill_damage_sub, "Skill_883700")

function Skill_883700:on_effect(param)
	local obj_s = param.obj_s
	local obj_d = param.obj_d
	if obj_d:get_mp() / obj_d:get_max_mp() < 0.2 then
		return {0, 0}
	end
	local factor = param.factor
	local trouble = param.trouble
	local sub_mp = math.floor(factor * trouble)
	obj_d:del_mp(sub_mp)
	return {0, factor}
end
f_skill_magic_damage_sub_builder(SKILL_OBJ_883700)

