
local faction_update_loader = require("item.faction_update_loader")
local HOUR = 60*60
Faction = oo.class(nil,"Faction")

function Faction:__init(faction_id)
	self.level = 1
	self.faction_id = faction_id

	self.faction_badge=1  --����
	self.faction_name="faction_name"    --������
	self.territory_level=0            --��صȼ�
	self.money=0
	self.rank=1                       --����
	self.announcement=nil             --������

	self.post_name = {}                 --ְλ��

	self.post_num={}            ---�������ְ�������

	self.create_time = 0       --����ʱ��
	self.faction_player_list = {}	  --��Ա�б�

	self.factioner_id = nil

	self.member_count = 1             --��Ա����

	self.join_l = {}                  --��������б�

	--������
	self.action_level 		= 1 				--�������ȼ� 
	self.action_practice 	= {0,0,0,0,0,0,0,0,0,0,0,0}   	--{���������ȼ������Եȼ������Եȼ��������ȼ�, 5�﹥��6������7������8����Ч����9���У�10���ܣ�11�����ֿ���12����Ч���ֿ�}
	self.action_end_time 	= 0					--��������������ʱ��
	
	--���Ǹ�
	self.book_level 		= 1					--���Ǹ�ȼ�  
	self.book_practice 		= {1,1,1,1}			--{�����ӳɵȼ��������ӳɵȼ�������ӳɵȼ�,��ܼӳɵȼ�}
	self.book_end_time		= 0					--���Ǹ���������ʱ��

	--���
	self.gold_level			= 1					--���ȼ�
	self.gold_end_time		= 0					--�����������ʱ��
	
	--���ɲֿ�
	self.warehouse_level    = 1
	self.warehouse_end_time = 0

	--�����
	self.construct_point 	= 0

	--�Ƽ���
	self.technology_point	= 0

	self.faction_update_end_time = 0 			--������������ʱ��

	--Ȩ��
	self.permission_list    = {
								{1,1,1,0},        --��Ա����
								{1,1,1,0},		  --���ɽ���
								{0,0,0,0},		  --�ֿ�Ȩ��
								{1,1,0,0},		  --�⽻Ȩ��
								{1,1,1,0},		  --������ϰ
								{1,1,0,0},		  --������ʼ
							  }

	--ҡǮ��
	self.money_tree_level = 1					  --ҡǮ���ȼ�
	self.irrigation = 0							  --���ֵ

	--������ɢ
	self.dissolve_flag = 0						--0Ϊδ������ɢ 1Ϊ�ѱ�����ɢ

	--����������ʱ��
	self.fb_info = {}

	--Լս
	self.battle_info = {}

	--�����ȼ�
	self.fb_level = 0
	-- ���ѡ�еİ��ɸ����ȼ�
	self.choose_fb_level = 0

end

--ÿ���ά���ʽ�
function Faction:get_maintenance()
	-- ά�����=�������ɵȼ�*10+�������ȼ�*3+���Ǹ�ȼ�*3+С���ȼ�*4��+18��*150+��ǰ�����ʽ�*0.0004
	--local money_l = math.ceil(( self.level * 10 + self.action_level * 3 + self.book_level * 3 + self.gold_level * 4 + 18 ) * 150 + self.money * 0.0004)

	local ret = {}
	ret[1] = math.ceil(((self.level * 10 + 4.5) * 150 + self.money * 0.0001) * 12) --����
	ret[2] = math.ceil(((self.book_level * 3 + 4.5)* 150 + self.money * 0.0001) * 12) --���Ǹ�
	ret[3] = math.ceil(((self.action_level * 3 + 4.5) * 150 + self.money * 0.0001) * 12) --������
	ret[4] = math.ceil(((self.gold_level * 4 + 4.5) * 150 + self.money * 0.0001) * 12)    --���

	return ret

end
 
function Faction:get_dissolve_flag()
	return self.dissolve_flag
end


function Faction:set_fb(fb)
	self.fb_info = fb
end

function Faction:get_fb_count(scene_id)
	local scene_id = tostring(scene_id)
	if self.fb_info[scene_id] ~= nil then
		local time_l = self.fb_info[scene_id][2]
		local n_time = ev.time
		local str_time = os.date("%x",time_l)
		local str_now = os.date("%x",n_time)
		if str_time ~= str_now then
			self.fb_info[scene_id][2] = n_time
			self.fb_info[scene_id][1] = 0
		end
		return self.fb_info[scene_id][1]
	end
	return 0
end

function Faction:get_choose_fb_level()
	return self.choose_fb_level
end

function Faction:set_choose_fb_level(level)
	self.choose_fb_level = level
end

function Faction:get_fb_level()
	return self.fb_level
end

function Faction:set_fb_level(level)
	self.fb_level = level
end


function Faction:is_other_day(time_l)
	local n_time = ev.time
	local str_time = os.date("%x",time_l)
	local str_now = os.date("%x",n_time)
	if str_time ~= str_now then
		return true
	end

	return false
end


function Faction:get_action_practice()
	return self.action_practice
end

function Faction:set_action_practice(index)
	self.action_practice[index] = self.action_practice[index] + 1
end

function Faction:get_book_practice()
	return self.book_practice
end

function Faction:get_book_practice_bonus(index)
	local level = self.book_practice[index]
	if index == 1 then
		return faction_update_loader.attack_list[level][5],faction_update_loader.attack_list[level][6]
	elseif index == 2 then
		return faction_update_loader.defense_list[level][5],faction_update_loader.defense_list[level][6]
	elseif index == 3 then
		return faction_update_loader.expr_list[level][5],faction_update_loader.expr_list[level][6]
	elseif index == 4 then
		return faction_update_loader.inspire_list[level][5],faction_update_loader.inspire_list[level][6]
	end
end

--��ʼ��buf
function Faction:init_set_book_practice_bonus()
	for k, v in ipairs(self.book_practice or {}) do
		local result1 = 0
		local result2 = 0
		if v ~= 0 and k ~= 4 then
			if k == 1 then
				result1 = faction_update_loader.attack_list[v][5]
				result2 = faction_update_loader.attack_list[v][6]
			elseif k == 2 then
				result1 = faction_update_loader.defense_list[v][5]
				result2 = faction_update_loader.defense_list[v][6]
				--return faction_update_loader.defense_list[level][5],faction_update_loader.defense_list[level][6]
			elseif k == 3 then
				for i = v, 1, -1 do
					if faction_update_loader.expr_list[i] ~= nil then
						v = i
						break
					end
				end
				result1 = faction_update_loader.expr_list[v][5]
				result2 = faction_update_loader.expr_list[v][6]
				--return faction_update_loader.expr_list[level][5],faction_update_loader.expr_list[level][6]
			end

			g_faction_impact_mgr:add_attribute_impact(self.faction_id, k + 5000, v, result2 or 0, result1 or 0)
		end
	end
end

function Faction:set_book_practice(index)
	self.book_practice[index] = self.book_practice[index] + 1
end

function Faction:get_action_level()
	return self.action_level
end

function Faction:set_action_level()
	self.action_level = self.action_level + 1
end

function Faction:get_book_level()
	return self.book_level
end

function Faction:set_book_level()
	self.book_level = self.book_level + 1
end

-- ���ɲֿ�
function Faction:get_warehouse_level()
	return self.warehouse_level
end

function Faction:set_warehouse_level()
	self.warehouse_level = self.warehouse_level + 1
end

function Faction:get_construct_point()
	return self.construct_point
end

function Faction:set_construct_point(c_point)
	self.construct_point = self.construct_point + c_point
end

function Faction:get_technology_point()
	return self.technology_point
end

function Faction:set_technology_point(t_point)
	self.technology_point = self.technology_point + t_point
end

function Faction:get_contribution(obj_id)
	if self.faction_player_list[obj_id] ~= nil then
		return self.faction_player_list[obj_id]["contribution"]
	end
end

function Faction:set_contribution(obj_id,contribution)
	if self.faction_player_list[obj_id] ~= nil then
		self.faction_player_list[obj_id]["constribution"] = contribution
	end
end


function Faction:get_level()
	return self.level
end

function Faction:set_level(level)
	self.level = level
end

function Faction:get_faction_id()
	return self.faction_id
end

function Faction:set_faction_id(faction_id)
	self.faction_id = faction_id
end

function Faction:get_faction_badge()
	return self.faction_badge
end

function Faction:set_faction_badge(faction_badge)
	self.faction_badge = faction_badge
end

function Faction:get_faction_name()
	return self.faction_name
end

function Faction:set_faction_name(faction_name)
	self.faction_name = faction_name

	local obj_mgr = g_obj_mgr
	for k,v in pairs(self.faction_player_list or {}) do
		local obj = obj_mgr:get_obj(k)
		if obj ~= nil and obj:get_type() == OBJ_TYPE_HUMAN then
			local ret = self:get_head_info(k)
			obj:set_faction(ret)
		end
	end

end

function Faction:get_territory_level()
	return self.territory_level
end

function Faction:set_territory_level(territory_level)
	self.territory_level = territory_level
end

function Faction:get_money()
	return self.money
end

function Faction:set_money(money)
	self.money = money
end

function Faction:get_rank()
	return self.rank
end

function Faction:set_rank(rank)
	self.rank = rank
end

function Faction:get_announcement()
	return self.announcement
end

function Faction:set_announcement(announcement)
	self.announcement = announcement
end

function Faction:get_post_name(index)
	if self.post_name[index] ~= nil then
		return self.post_name[index]
	end
end

function Faction:get_post_name_ex()
	return self.post_name
end

function Faction:set_post_name(post_name)
	self.post_name = post_name
end

function Faction:get_post_num()
	return self.post_num
end

function Faction:set_post_num(post_num)
	self.post_num = post_num
end

function Faction:get_create_time()
	return self.create_time
end

function Faction:set_create_time(create_time)
	self.create_time = create_time
end

function Faction:get_faction_player_list()
	return self.faction_player_list
end

function Faction:update_faction_player_list(pkt)
	self.faction_player_list = {}
	for k,v in pairs(pkt.faction_player_list or {})do
		local obj_id = v[1]
		self.faction_player_list[obj_id] = v[2]
	end
end

function Faction:set_faction_player_list(faction_player_list)
	self.faction_player_list = faction_player_list
end

function Faction:get_factioner_id()
	return self.factioner_id
end

function Faction:set_factioner_id(factioner_id)
	self.factioner_id = factioner_id
end

function Faction:get_factioner_name()
	local factioner_id = self:get_factioner_id()
	return self.faction_player_list[factioner_id].name
end

function Faction:get_member_count()
	return self.member_count
end

function Faction:set_member_count(member_count)
	self.member_count = member_count
end

function Faction:update_join_list(pkt)
	self.join_l = {}
	for k, v in pairs(pkt.join_l or {}) do
		local obj_id = v[1]
		self.join_l[obj_id] = v[2]
	end
end

function Faction:get_join_l()
	return self.join_l
end

function Faction:set_join_l(join_l)
	self.join_l = join_l
end

function Faction:get_post(char_id)
	if self.faction_player_list[char_id] ~= nil then
		return self.faction_player_list[char_id]["post_index"]
	end
end

function Faction:get_gold_level()
	return self.gold_level
end

function Faction:get_action_end_time()
	return self.action_end_time
end

function Faction:get_book_end_time()
	return self.book_end_time
end

function Faction:get_gold_end_time()
	return self.gold_end_time
end

-- ���ɲֿ�
function Faction:get_warehouse_end_time()
	return self.warehouse_end_time
end

function Faction:get_faction_update_end_time()
	return self.faction_update_end_time
end

--������ Ȩ������
function Faction:is_fb_permission_ok(char_id)
	local char_index = self:get_post(char_id)
	if char_index == 1 then
		return 0
	end

	if self.permission_list[6][char_index-1] == 0 or self.permission_list[6][char_index-1] == nil then
		return 26036
	end

	if self.dissolve_flag == 1 then
		return 26047
	end

	return 0

end

--ԼսȨ��
function Faction:is_battle_permission_ok(char_id)

	local char_index = self:get_post(char_id)
	if char_index == 1 or char_index == 2 then
		return 0
	end

	return 21091
end

function Faction:get_faction_list_info()
	local ret ={}
	ret[1] = self.faction_name
	ret[2] = self.level
	ret[3] = self.faction_player_list[self.factioner_id]["name"]
	ret[4] = self.member_count
	ret[5] = self.money
	ret[6] = (g_faction_manor_mgr:had_manor(self.faction_id) == true) and 1 or 0
	ret[7] = self.faction_id
	ret[8] = g_faction_manor_mgr:get_level(self.faction_id)
	return ret or {}
end

--����ս �����ȡ��Ϣ
function Faction:get_faction_info_for_battle()
	local ret ={}
	ret[1] = self.faction_id
	ret[2] = self.faction_name
	ret[3] = self.level
	ret[4] = self.faction_player_list[self.factioner_id]["name"]
	ret[5] = self.member_count
	return ret or {}
end
-----------------------------------------------------��������-----------------------------------------------------------
function Faction:get_irrigation_jade_gift()
	local irrigation_list = faction_update_loader.irrigation_list[self.money_tree_level]
	return irrigation_list[4]
end

function Faction:is_gold_full()
	local t_level = self.gold_level
	local gold_list_loader = faction_update_loader.gold_list[t_level]
	if self.money < gold_list_loader[5] then
		return 0
	end
	return 1
end

function Faction:is_technology_full()
	local t_level = self.book_level
	local book_list_loader = faction_update_loader.book_list[t_level]
	if self.technology_point < book_list_loader[5] then
		return 0
	end
	return 1
end

function Faction:is_money_full()
	local gold_list_loader = faction_update_loader.gold_list[self.level]
	if self.money < gold_list_loader[5] then
		return 0
	end
	return 1
end


--��������������
function Faction:condition_action()
	local t_level = self.action_level
	local action_list_loader = faction_update_loader.action_list[t_level + 1]
	if not action_list_loader then return 26021 end
	return self:is_update_ok(action_list_loader)
end

--���Ǹ���������
function Faction:condition_book()
	local t_level = self.book_level
	local book_list_loader = faction_update_loader.book_list[t_level + 1]
	if not book_list_loader then return 26022 end
	return self:is_update_ok(book_list_loader)
end

-- ���ɲֿ�
function Faction:condition_warehouse()
	local t_level = self.warehouse_level
	local warehouse_list_loader = faction_update_loader.warehouse_list[t_level + 1]
	if not warehouse_list_loader then return end
	return self:is_update_ok(warehouse_list_loader)
end

--���
function Faction:condition_gold()
	local t_level = self.gold_level
	local gold_list_loader = faction_update_loader.gold_list[t_level + 1]
	if not gold_list_loader then return 26023 end
	return self:is_update_ok(gold_list_loader)
end

--������������
function Faction:condition_faction()
	local faction_list_loader = faction_update_loader.faction_list[self.level + 1]
	
	if not faction_list_loader then return 26024 end
	if self.money < faction_list_loader[2] then return 26025 end
	if self.action_level < faction_list_loader[3] then return 26026 end
	if self.book_level < faction_list_loader[4] then return 26027 end
	if self.gold_level < faction_list_loader[5] then return 26028 end
	if self.faction_update_end_time >= ev.time then return 26029 end
	if self.construct_point < faction_list_loader[9] then return 26030 end

	return 0
end


function Faction:is_update_ok(t_table)
	if self.money < t_table[2] then return 26025 end
	if self.construct_point < t_table[3] then return 26030 end
	if self.level < t_table[4] then return 26031 end

	return 0
end

function Faction:is_action_practice_ok(t_table)
	if self.technology_point < t_table[2] then return 26032 end
	if self.money < t_table[3] then return 26025 end
	if self.action_level < t_table[4] then return 26033 end

	return 0
end

function Faction:is_book_practice_ok(t_table)
	if self.technology_point < t_table[4] then return 26032 end
	if self.money < t_table[2] then return 26025 end
	if self.book_level < t_table[3] then return 26034 end

	return 0
end

--����
function Faction:condition_action_practice(index)
	if self.action_practice[index] ~= nil then
		local loader = {}
		local t_level = self.action_practice[index] + 1

		--if t_level > self.action_level then return 26033 end

		if index == 1 then --ACTION_PRACTICE.strengh
			loader = faction_update_loader.strengh_list[t_level]
		elseif index == 2 then--ACTION_PRACTICE.intelligence
			loader = faction_update_loader.intelligence_list[t_level]
		elseif index == 3 then--ACTION_PRACTICE.defense
			loader = faction_update_loader.pro_defence_list[t_level]
		elseif index == 4 then--ACTION_PRACTICE.attack
			loader = faction_update_loader.pro_attack_list[t_level]
		elseif index == 5 then -- ACTION_PRACTICE.s_attack -- ����֧�䣬�﹥
			loader = faction_update_loader.s_attack_list[t_level]
		elseif index == 6 then -- ACTION_PRACTICE.m_attack -- ����֧�䣬����
			loader = faction_update_loader.m_attack_list[t_level]
		elseif index == 7 then -- ACTION_PRACTICE.critical -- ����һ��������
			loader = faction_update_loader.critical_list[t_level]
		elseif index == 8 then -- ACTION_PRACTICE.critical_ef -- �����˺�������Ч��
			loader = faction_update_loader.critical_ef_list[t_level]
		elseif index == 9 then -- ACTION_PRACTICE.point -- רע������
			loader = faction_update_loader.point_list[t_level]
		elseif index == 10 then -- ACTION_PRACTICE.dodge -- ��ң��������
			loader = faction_update_loader.dodge_list[t_level]
		elseif index == 11 then -- ACTION_PRACTICE.critical_df -- ���ɶ��죬�����ֿ�
			loader = faction_update_loader.critical_df_list[t_level]
		elseif index == 12 then -- ACTION_PRACTICE.d_critical_ef -- ���ͣ�����Ч���ֿ�
			loader = faction_update_loader.d_critical_ef_list[t_level]
		end

		if not loader then return 26035 end

		local result = self:is_action_practice_ok(loader)
		return result
	end
end

--�ӳ�
function Faction:condition_book_practice(index)
	if self.book_practice[index] ~= nil then
		local loader = {}
		local t_level = self.book_practice[index] + 1
	--	if t_level > self.book_level then return 26034 end
		if index == 1 then--BOOK_PRACTICE.attack
			loader = faction_update_loader.attack_list[t_level]
		elseif index == 2 then--BOOK_PRACTICE.defense
			loader = faction_update_loader.defense_list[t_level]
		elseif index == 3 then--BOOK_PRACTICE.expr
			loader = faction_update_loader.expr_list[t_level]
		elseif index == 4 then
			loader = faction_update_loader.inspire_list[t_level]
		end

		if not loader then return 26035 end

		local result = self:is_book_practice_ok(loader)
		return result
	end
end







---------------------------------------------------------------------------------------------------------------------

--���°���
function Faction:update_faction(pkt)
	self:set_level(pkt['1'])
	self:set_faction_id(pkt['2'])
	self:set_faction_badge(pkt['3'])
	--self:set_faction_name(pkt['4'])
	self.faction_name = pkt['4']
	self:set_territory_level(pkt['5'])
	self:set_money(pkt['6'])
	self:set_rank(pkt['7'])
	self:set_announcement(pkt['8'])
	self.post_name = {}
	for k,v in pairs(pkt['9'] or {}) do
		self.post_name[k] = v
	end
	self:set_create_time(pkt['10'])
	self.post_num = {}
	for k,v in pairs(pkt['11'] or {}) do
		self.post_num[k] = v
	end
	self.action_level = pkt['12']
	self.book_level = pkt['13']
	self.gold_level = pkt['14']
	self.action_practice ={}
	for k,v in pairs(pkt['15'] or {}) do
		self.action_practice[k] = v
	end
	self.book_practice ={}
	for k,v in pairs(pkt['16'] or {}) do
		self.book_practice[k] = v
	end
	self.technology_point = pkt['17']
	self.construct_point = pkt['18']
	self.faction_player_list = {}
	for k,v in pairs(pkt['19'] or {})do
		local obj_id = v[1]
		self.faction_player_list[obj_id] = v[2]
	end
	self:set_factioner_id(pkt['20'])
	self:set_member_count(pkt['21'])
	self.action_end_time = pkt['22']
	self.book_end_time = pkt['23']
	self.faction_update_end_time = pkt['24']
	self.join_l = {}
	for k, v in pairs(pkt['25'] or {}) do
		local obj_id = v[1]
		self.join_l[obj_id] = v[2]
	end
	self.permission_list = pkt['26']
	self.money_tree_level = pkt['27']
	self.irrigation = pkt['28']
	self.gold_end_time = pkt['29']
	self.dissolve_flag = pkt['30']
	self.fb_info = pkt['31']
	self.battle_info = pkt['32']
	self.warehouse_level = pkt['33'] -- ���ɲֿ�
	self.warehouse_end_time = pkt['34']
	self.fb_level = pkt['35']
	self.choose_fb_level = pkt['36'] -- ���ѡ�еİ��ɸ����ȼ�
end

function Faction:update_other_info(pkt)
	self:set_factioner_id(pkt.factioner_id)
	self:set_member_count(pkt.member_count)
	self:set_level(pkt.level)
	self:set_faction_id(pkt.faction_id)
	self:set_faction_badge(pkt.faction_badge)
	self:set_faction_name(pkt.faction_name)
	self:set_territory_level(pkt.territory_level)
	self:set_money(pkt.money)
	self:set_rank(pkt.rank)
	self:set_announcement(pkt.announcement)
	self:set_post_name(pkt.post_name)
	self:set_post_num(pkt.post_num)
	self:set_create_time(pkt.create_time)
	self.construct_point = pkt.construct_point
	self.technology_point = pkt.technology_point
	self.action_level = pkt.action_level
	self.book_level = pkt.book_level
	self.gold_level = pkt.gold_level
	self.action_practice = pkt.action_practice
	self.action_end_time = pkt.action_end_time
	self.book_practice = pkt.book_practice
	self.book_end_time = pkt.book_end_time
	self.faction_update_end_time = pkt.faction_update_end_time
	self.warehouse_level = pkt.warehouse_level -- ���ɲֿ�
	self.warehouse_end_time = pkt.warehouse_end_time
end

function Faction:on_line(obj_id)    --����
	self:online_syn(obj_id)
end

--���������
function Faction:out_line(obj_id)   --����
	if self.faction_player_list[obj_id] ~= nil then
		local time_l = ev.time
		self.faction_player_list[obj_id]["status"] = os.date("%Y.%m.%d %H:%M:%S", time_l, time_l)
	end
end

--����ʱ֪ͨ�ͻ�����Ϣ
function Faction:online_syn(obj_id)
	--���ͷ����ʾ���ɵ���Ϣ
	--local ret = self:get_head_info(obj_id)
	--g_svsock_mgr:send_server_ex(WORLD_ID,obj_id, CMD_C2M_FACTION_UPDATE_REQ, ret)

	--���ɵ�һЩ��Ϣ
	local ret_l = self:get_online_info(obj_id)
	g_cltsock_mgr:send_client(obj_id, CMD_M2B_FACTION_PLAYER_INFO_S, ret_l)
	--g_svsock_mgr:send_server_ex(WORLD_ID,obj_id,CMD_M2B_FACTION_PLAYER_INFO_S,ret_l)
end

--��Ա�б�
function Faction:get_player_info()
	local ret = {}
	for k,v in pairs(self.faction_player_list or {}) do
		local list = self:get_single_info_ex(k)
		table.insert(ret,list)
	end
	return ret
end

--������Ա������Ϣ
function Faction:get_single_info_ex(obj_id)
	local ret = self.faction_player_list[obj_id]
	if ret ~= nil then
		local list = {}--self:get_single_info(k)
		list[1] = obj_id
		list[2] = ret.name
		list[3] = ret.level
		list[4] = self.post_name[ret["post_index"]]
		list[5] = ret.contribution
		list[6] = ret.status
		list[7] = ret.post
		list[8] = ret.gender
		list[9] = ret.post_index
		list[10] = ret.online_flag
		list[11] = ret.history_contribution
		-- �����ֶΣ����ɳ�Աvip���
		list[12] = ret.vip_level

		return list
	end
end

--������Ա����Ϣ
function Faction:get_single_info(obj_id)
	local ret = self.faction_player_list[obj_id]
	if ret ~= nil then
		ret["post_name"] = self.post_name[ret["post_index"]]
	end
	return ret
end

--���ͷ����ʾ�İ�����Ϣ
function Faction:get_head_info(obj_id)
	local player_info = self:get_single_info(obj_id)
	local ret ={}
	if player_info ~= nil then
		ret.faction_id = self.faction_id
		ret.faction_nm = self.faction_name
		ret.post_nm = player_info.post_name
		ret.post_id = player_info.post_index
	end
	return ret
end

--���һ����ͨ����Ϣ
function Faction:get_online_info(obj_id)
		local ret={}
		ret[1] = self.faction_name
		ret[2] = self.rank
		ret[3] = self.level
		ret[4] = self.faction_player_list[self.factioner_id]["name"]--territory_level
		ret[5] = self.member_count
		ret[6] = self.construct_point
		ret[7] = self.technology_point
		ret[8] = self.money
		ret[9] = 0       ---�ػ��ȼ�
		ret[10] =  self:is_territory()
		ret[11] = self.action_level
		ret[12] = self.book_level
		ret[13] = self.gold_level
		ret[14] = self.faction_id
		ret[15] = self.announcement or ""
		local index = self.faction_player_list[obj_id]["post_index"]
		ret[16] = self:get_post_name(index)
		ret[17] = index  --self:get_post_name(index)
		ret[18] = self.permission_list
		ret[19] = self.action_practice

		local t_ret = {}
		t_ret[4] = 0
		t_ret[5] = 0
		t_ret[6] = 0
		local time_l = ev.time
		t_ret[7] = self.faction_update_end_time - time_l
		if self.faction_update_end_time == 0 or t_ret[7] < 0 then 
			t_ret[7] = 0
		end
		t_ret[1] = self.action_end_time - time_l
		if self.action_end_time == 0 or t_ret[1]< 0  then 
			t_ret[1] = 0
		end
		t_ret[2] = self.book_end_time - time_l
		if self.book_end_time == 0 or t_ret[2]< 0 then 
			t_ret[2] = 0
		end

		t_ret[3] = self.gold_end_time - time_l
		if self.gold_end_time == 0 or t_ret[3] < 0 then 
			t_ret[3] = 0
		end

		-- ���ɲֿ�
		t_ret[8] = 0
		t_ret[9] = 0
		t_ret[10] = self.warehouse_end_time - time_l
		if self.warehouse_end_time == 0 or t_ret[10]< 0 then
			t_ret[10] = 0
		end

		ret[20] = t_ret
		print(ret[20][10])

		ret[21] = self.book_practice
		ret[22] = self.faction_player_list[obj_id]["contribution"]
		ret[23] = self.money_tree_level
		ret[24] = self.irrigation
		ret[25] = self.faction_player_list[obj_id]["money_tree_flag"]

		ret[26] = 0
		local time_span = ev.time - self.faction_player_list[obj_id]["money_tree_time"]
		if time_span < HOUR and time_span >= 0 then--60*60*2
			ret[26] = HOUR - time_span
		end

		ret[27] = self.dissolve_flag
		ret[28] = {}
		ret[28][1] = self.fb_info["switch_flag"]
		ret[28][2] = self.fb_info["cur_scene_id"]

		local money_tree_time = self.faction_player_list[obj_id]["money_tree_time"]
		if self:is_other_day(money_tree_time or 0) then
			ret[29] = 0
		else
			ret[29] = self.faction_player_list[obj_id]["money_tree_count"]
		end
		ret[30] = self.battle_info or {0,""}

		-- ���ɲֿ�
		ret[31] = self.warehouse_level

		ret[32] = self.fb_level
		--ret[33] = self.choose_fb_level -- ���ѡ�еİ��ɸ����ȼ�
	--end
	return ret
end

----------------------------------------------ͬ������----------------------------------------------------------------
--ͬ����Ϣ   
--[[
obj_id:Ҫ���µ����id     flag : 1 update, 2 add, 3 delete 
(1)flag = 1ʱ��flag_type = 1 Ϊ���棬2Ϊ��Ա�б�
   flag = 2ʱ��flag_type = 1 Ϊ��Ա�б�2Ϊ��ļ�б�
   flag = 3ʱ��flag_type = 1 Ϊ��Ա�б�2Ϊ��ļ�б� 

]]

function Faction:syn_info(flag,flag_type,pkt)
	if flag == 1 then   --update
		if flag_type ==1 then
			self.announcement=pkt.announcement
		elseif flag_type ==2 then
			local obj_id = pkt.faction_member[1]
			local post_index = self.faction_player_list[obj_id].post_index
			self.post_num[post_index] = self.post_num[post_index] - 1

			self.faction_player_list[obj_id]= {}
			self.faction_player_list[obj_id].obj_id = obj_id
			self.faction_player_list[obj_id].name = pkt.faction_member[2]
			self.faction_player_list[obj_id].level = pkt.faction_member[3]
			self.faction_player_list[obj_id].contribution = pkt.faction_member[5]
			self.faction_player_list[obj_id].status = pkt.faction_member[6]
			self.faction_player_list[obj_id].post = pkt.faction_member[7]
			self.faction_player_list[obj_id].gender = pkt.faction_member[8]
			self.faction_player_list[obj_id].post_index = pkt.faction_member[9]
			self.faction_player_list[obj_id].online_flag = pkt.faction_member[10]
			self.faction_player_list[obj_id].history_contribution = pkt.faction_member[11]
			self.faction_player_list[obj_id].salary_flag = pkt.faction_member[12]
			self.faction_player_list[obj_id].money_tree_flag = pkt.faction_member[13]
			self.faction_player_list[obj_id].money_tree_time =pkt.faction_member[14]
			self.faction_player_list[obj_id].money_tree_count = pkt.faction_member[15]
			-- �����ֶΣ����ɳ�Աvip���
			self.faction_player_list[obj_id].vip_level = pkt.faction_member[16]
			if pkt.faction_member[9] == 1 then
				self.factioner_id = obj_id
			end
			self.post_num[pkt.faction_member[9]] = self.post_num[pkt.faction_member[9]] + 1
			
		elseif flag_type==3 then	--���ɵж��Ѻù�ϵ
			local relate_list = pkt.relate_list
			local other_faction_id = relate_list[1][7]
			local flag_t = relate_list[2]
			if flag_t == 3 then
				g_faction_mgr:del_relation(self.faction_id,other_faction_id)
			else
				g_faction_mgr:add_relation(self.faction_id,other_faction_id,flag_t)
			end
			
		elseif flag_type==4 then   --buf����
			self.book_practice = pkt.book_practice
			self.technology_point= pkt.technology_point
			self.money = pkt.faction_money

			--֪ͨbuf�ӳ�
			for k,v in ipairs(self.book_practice or {}) do
				if v ~= 0 and k < 4 then
					local result1,result2 = self:get_book_practice_bonus(k)
					g_faction_impact_mgr:add_attribute_impact(self.faction_id, 5000 + k, v, result2 or 0, result1 or 0)
				end
			end
		
		elseif flag_type==5 then   --��������
			self.action_practice = pkt.action_practice
			self.technology_point= pkt.technology_point
			self.money = pkt.faction_money
		elseif flag_type==6 then   --���������ͽ����
			local faction_update = pkt.faction_update
			local t_time = ev.time
			self.level = faction_update[7][1]
			self.faction_update_end_time = faction_update[7][2]
			if faction_update[7][2] ~= 0 then
				self.faction_update_end_time = t_time + faction_update[7][2]
			end
			self.action_level = faction_update[1][1]
			self.action_end_time = faction_update[1][2]
			if faction_update[1][2] ~= 0 then
				self.action_end_time = t_time + faction_update[1][2]
			end
			self.book_level = faction_update[2][1]
			self.book_end_time = faction_update[2][2]
			if faction_update[2][2] ~= 0 then
				self.book_end_time = t_time + faction_update[2][2]
			end

			-- ���ɲֿ�
			self.warehouse_level = faction_update[10][1]
			self.warehouse_end_time = faction_update[10][2]
			if faction_update[10][2] ~= 0 then
				self.warehouse_end_time = t_time + faction_update[10][2]
			end

			self.gold_level = faction_update[3][1]
			self.gold_end_time = faction_update[3][2]
			if faction_update[3][2] ~= 0 then
				self.gold_end_time = t_time + faction_update[3][2]
			end
			self.construct_point = pkt.construct_point
			self.money = pkt.faction_money
		elseif flag_type==7 then	--�Ƽ��㣬����ȣ������ʽ�
			self.construct_point= pkt.construct_point
			self.technology_point= pkt.technology_point
			self.money = pkt.faction_money
		elseif flag_type==8 then	--Ȩ��
			self.permission_list= pkt.permission_list
		elseif flag_type== 9 then    --ҡǮ��
			self.money_tree_level = pkt.money_tree_level
			self.irrigation = pkt.irrigation
		elseif flag_type == 10 then
		elseif flag_type == 11 then
			self.dissolve_flag = pkt.dissolve_flag
			g_faction_impact_mgr:set_dissolve(self.faction_id, self.dissolve_flag)
		elseif flag_type == 12 then
			self.fb_info["switch_flag"] = pkt.fb_info[1]
			self.fb_info["cur_scene_id"] = pkt.fb_info[2]
		elseif flag_type == 13 then
		elseif flag_type == 14 then
			self:set_faction_name(pkt.faction_name)
		elseif flag_type == 15 then
			self.battle_info = pkt.battle_info
		elseif flag_type == 16 then
			self.fb_level = pkt.fb_level
			self.choose_fb_level = pkt.choose_fb_level
		end
	elseif flag ==2 then  --add 
		if flag_type==1 then
			local obj_id = pkt.faction_member[1]
			self.faction_player_list[obj_id]= {}
			self.faction_player_list[obj_id].obj_id = obj_id
			self.faction_player_list[obj_id].name = pkt.faction_member[2]
			self.faction_player_list[obj_id].level = pkt.faction_member[3]
			self.faction_player_list[obj_id].contribution = pkt.faction_member[5]
			self.faction_player_list[obj_id].status = pkt.faction_member[6]
			self.faction_player_list[obj_id].post = pkt.faction_member[7]
			self.faction_player_list[obj_id].gender = pkt.faction_member[8]
			self.faction_player_list[obj_id].post_index = pkt.faction_member[9]
			self.faction_player_list[obj_id].online_flag = pkt.faction_member[10]
			self.faction_player_list[obj_id].history_contribution = pkt.faction_member[11]
			self.faction_player_list[obj_id].salary_flag = pkt.faction_member[12]
			self.faction_player_list[obj_id].money_tree_flag = pkt.faction_member[13]
			self.faction_player_list[obj_id].money_tree_time =pkt.faction_member[14]
			self.faction_player_list[obj_id].money_tree_count = pkt.faction_member[15]
			-- �����ֶΣ����ɳ�Աvip���
			self.faction_player_list[obj_id].vip_level = pkt.faction_member[16]
			self.member_count = self.member_count + 1
			g_faction_mgr:add_member2faction(obj_id,self.faction_id)
			--g_faction_mgr:syn_info_chat(self.faction_id,obj_id,1)
		elseif flag_type == 2 then
			local obj_id = pkt.join_info[1]
			self.join_l[obj_id] = {}
			self.join_l[obj_id]["char_id"] = obj_id
			self.join_l[obj_id]["time"] = pkt.join_info[5]
			self.join_l[obj_id]["post"] = pkt.join_info[4]
			self.join_l[obj_id]["level"] = pkt.join_info[3]
			self.join_l[obj_id]["name"] = pkt.join_info[2]
		elseif flag_type == 3 then
			--pkt.faction_list=self
		end
	elseif flag == 3 then  --delete
		if flag_type==1 then
			local index = self.faction_player_list[pkt.player_id]["post_index"]
			self.faction_player_list[pkt.player_id] = nil
			self.member_count = self.member_count - 1
			local count = self.post_num[index] - 1
			self.post_num[index] = count < 0 and 0 or count
			g_faction_mgr:del_member2faction(pkt.player_id)
			--g_faction_mgr:syn_info_chat(0,pkt.player_id,2)
			g_event_mgr:notify_event(EVENT_SET.EVENT_OUT_FACTION, pkt.player_id, nil)
		elseif flag_type ==2 then
			self.join_l[pkt.recruit_player_id] = nil
		end
	end
end

function Faction:syn_send_all(pkt,cmd)--,flag_o
	if pkt == nil then return end
	pkt = Json.Encode(pkt or {})
	for k,v in pairs(self.faction_player_list or {}) do
		if v["status"]=="0" then
			if g_obj_mgr:get_obj(k) then
				g_cltsock_mgr:send_client(k, cmd, pkt,true)
			end
		end
	end
end


------------------------------------------����ͨ����Ϣ----------------------------------------------------
--������Ϣ
function Faction:get_faction_info()
	local ret={}
	ret[1]=self.faction_name
	ret[2]=self.level
	ret[3]=self.faction_player_list[self.factioner_id]["name"]--self.money
	ret[4]=self.member_count
	ret[5]=self.construct_point
	ret[6]=self.technology_point
	ret[7]=self.money
	ret[8]=0
	ret[9]=""
	ret[10]=self.action_level
	ret[11]=self.book_level
	ret[12]=self.gold_level
	ret[13]=self.announcement or ""
	ret[14]=self.action_practice
	ret[15]=self.faction_id
	ret[16] = self.warehouse_level -- ���ɲֿ�
	return ret
end

--��ļ�б���Ϣ
function Faction:get_recruit_info()
	local ret={}
	for k,v in pairs(self.join_l or {}) do
		local list = self:get_single_join_list(k)
		table.insert(ret,list)
	end
	return ret
end

function Faction:get_single_join_list(obj_id)
	local obj=self.join_l[obj_id]
	local t_ret = {}
	if obj then
		t_ret[1] = obj["char_id"]
		t_ret[2] = obj["name"]
		t_ret[3] = obj["level"]
		t_ret[4] = obj["post"]
		t_ret[5] = obj["time"]
	end
	return t_ret
end

--��ȡ����
function Faction:is_fetch_salary_ok(obj_id)
	local time_l = self:get_salary_flag(obj_id)
	local str_time = os.date("%x",time_l)
	local str_now = os.date("%x",ev.time)
	if str_time ~= str_now then
		return 1
	end
	return 0
end

function Faction:get_salary_flag(obj_id)
	return self.faction_player_list[obj_id].salary_flag
end

--�жϰ����Ƿ�վ�����
function Faction:is_territory()
	if self.faction_id == App_filter:get_faction_id() then
		return 1
	end
	return 0
end


--������������
function Faction:get_online_member_count()
	local count = 0
	for k,v in pairs(self.faction_player_list or {}) do
		if v.online_flag == 1 then
			count = count + 1
		end
	end

	return count
end


-- ���ɲֿ�Ȩ��
function Faction:is_warehouse_permission_ok(char_id)
	local char_index = self:get_post(char_id)

	if char_index == 1 then
		return 0
	end
	if self.permission_list[3][char_index-1]==nil or self.permission_list[3][char_index-1]==0 then
		return 26036
	end
	return 0
end