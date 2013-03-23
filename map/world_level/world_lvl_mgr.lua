
--2012-03-13
--cqs
--����ȼ�������

----------------------------------------------------------------


World_lvl_mgr = oo.class(nil, "World_lvl_mgr")

local exp_loader = require("config.loader.world_gift_loader")

function World_lvl_mgr:__init()
	self.average_lvl = nil
end


--����ȼ�,-1δ��ʼ����; >=0����ȼ�
function World_lvl_mgr:get_average_level()
	return self.average_lvl or -1
end

function World_lvl_mgr:change_level(lvl)
	self.average_lvl = lvl
end

function World_lvl_mgr:get_exp_addition(vip, level)
	if not self.average_lvl or level < 40 then
		return 0
	else
		local lvl = self.average_lvl - level
		if lvl < 5 then return 0 end

		return exp_loader.get_exp1_addition(vip, lvl)
	end
end
