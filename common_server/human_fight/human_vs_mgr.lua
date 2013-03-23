
local reward_loader = require("config.loader.human_fight_loader")
local TIME_SPAN = 10 * 60


Human_vs_mgr = oo.class(nil,"Human_vs_mgr")

function Human_vs_mgr:__init()
	self.container_list = {}

	--����
	self.sort_list = {}

	--���ܵ�һ��  ���ƣ��ȼ���ְҵ��ս����
	self.last_winner = {"",0,0,0}

	--���һ������û����ʱ��
	self.submit_time = f_get_sunday() + 8 * 24 * 3600 + 1

	--������ʱ��
	self.gift_time = ev.time
end

function Human_vs_mgr:get_last_winner()
	return self.last_winner
end

function Human_vs_mgr:set_last_winner(char_id)
	local ret = {}
	ret[1] = g_player_mgr.all_player_l[char_id].char_nm
	ret[2] = g_player_mgr.all_player_l[char_id].level
	ret[3] = g_player_mgr.all_player_l[char_id].occ
	ret[4] = self:get_container(char_id):get_fight()

	self.last_winner = ret
end

function Human_vs_mgr:get_container(char_id)
	return self.container_list[char_id]
end

function Human_vs_mgr:create_container(char_id)
	if self.container_list[char_id] == nil then
		self.container_list[char_id] = Human_vs_container(char_id)
		self.container_list[char_id]:load()
		self:insert_char_ex(char_id)
	end
	return self.container_list[char_id]
end

function Human_vs_mgr:create_container_ex(char_id)
	if self.container_list[char_id] == nil then
		self.container_list[char_id] = Human_vs_container(char_id)
		self.container_list[char_id]:load()
	end
	return self.container_list[char_id]
end

function Human_vs_mgr:del_container(char_id)
	self.container_list[char_id] = nil

	local dbh = f_get_db()
	local query = string.format("{char_id:%d}",char_id)
	dbh:delete("human_fight",query)

	--��ˮ
	local str = string.format("insert log_char_battle set attack_id = %d,attack_name='%s',time=%d,type=%d",
				char_id, g_player_mgr.all_player_l[char_id].char_nm,ev.time,-1)
		g_web_sql:write(str)
end

--�������е�����
function Human_vs_mgr:insert_char(char_id, index)
	if table.size(self.sort_list) == 0 then
		table.insert(self.sort_list, char_id)
	else
		local point = self.container_list[char_id]:get_point()
		for k,v in pairs(self.sort_list) do
			local point_s = self.container_list[v]:get_point()
			if point_s < point then
				table.insert(self.sort_list,k,char_id)
				break
			elseif k == table.size(self.sort_list) then
				table.insert(self.sort_list, char_id)
				break
			end
		end
	end
end

function Human_vs_mgr:insert_char_ex(char_id, index)
	if index == nil then
		table.insert(self.sort_list,char_id)
	else
		table.insert(self.sort_list, index, char_id)
	end
end

function Human_vs_mgr:del_char(char_id)
	for k,v in pairs(self.sort_list or {}) do
		if v == char_id then
			table.remove(self.sort_list, k)
			break
		end
	end
end

function Human_vs_mgr:get_char_index(char_id)
	for k,v in pairs(self.sort_list) do
		if v == char_id then
			return k
		end
	end

	local container = self:get_container(char_id)
	if container then
		self:insert_char_ex(char_id)
	end

	return table.size(self.sort_list)
end

--��ȡ�б���Ϣ
function Human_vs_mgr:get_single_info(char_id)
	local container = self.container_list[char_id]
	if not container then return end
	local content = {}
	content[1] = g_player_mgr:char_id2nm(char_id)
	content[2] = g_player_mgr.all_player_l[char_id]["level"]
	content[3] = g_player_mgr.all_player_l[char_id]["occ"]
	content[4] = container:get_fight()
	content[5] = container:get_point()
	content[6] = container:get_vs_list()
	content[7] = char_id

	return content
end

function Human_vs_mgr:get_single_info_ex(char_id, rank)
	local container = self.container_list[char_id]
	if not container then return end
	local content = {}
	content[1] = g_player_mgr:char_id2nm(char_id)
	content[2] = g_player_mgr.all_player_l[char_id]["level"]
	content[3] = g_player_mgr.all_player_l[char_id]["occ"]
	content[4] = container:get_fight()
	content[5] = container:get_point()
	content[6] = container:get_vs_list()
	content[7] = char_id
	content[8] = rank

	return content
end

--��ȡ��ս�б�
function Human_vs_mgr:get_char_info(char_id)
	local ret = {}
	local flag = 0
	for k, v in pairs(self.sort_list or {}) do
		local container = self.container_list[v]
		if container then
			if v ~= char_id then
				table.insert(ret,{k,v})
				if flag == 1 and table.size(ret) >= 7 then
					break
				end
			elseif v == char_id and table.size(ret) >= 7 then
				break
			elseif v == char_id and table.size(ret) < 7 then
				flag = 1
			end
		else
			self.sort_list[k] = nil
		end
	end

	local content = {}
	local size = table.size(ret)
	if size <= 7 then 
		for m, n in pairs(ret or {}) do
			local info = self:get_single_info_ex(n[2],n[1])
			if info then
				table.insert(content, info)
			end
		end
	else
		for i = size - 6 ,size do
			local info = self:get_single_info_ex(ret[i][2],ret[i][1])
			if info then
				table.insert(content, info)
			end
		end 
	end

	return content
end

--���а�
function Human_vs_mgr:get_all_info()
	local ret = {}
	local count = 1
	for k,v in pairs(self.sort_list or {}) do
		if count <= 100 then
			local content = self:get_single_info(v)
			if content then
				table.insert(ret,content)
				count = count + 1
			end
		end
	end

	return ret
end

--��ǰ����
function Human_vs_mgr:get_rank_by_id(char_id)
	for k,v in pairs(self.sort_list) do
		if v == char_id then
			return k
		end
	end

	local container = self:get_container(char_id)
	if container then
		self:insert_char_ex(char_id)
	end

	return table.size(self.sort_list)
end

function Human_vs_mgr:get_char_by_rank(rank)
	for k,v in pairs(self.sort_list) do
		if k == rank then
			return v
		end
	end
end

---------------------------------ս��----------------------------------
function Human_vs_mgr:fight(char_id_s,char_id_d)
	local container_s = self:get_container(char_id_s)
	local container_d = self:get_container(char_id_d)
	if not container_s or not container_d then return end
	
	if container_s:can_be_fight() ~= 0 then return end

	local human_obj_s = container_s:get_human_obj()
	local human_obj_d = container_d:get_human_obj()
	if not human_obj_s or not human_obj_d then return end

	local skill_con_s = human_obj_s:get_skill_con()
	local skill_con_d = human_obj_d:get_skill_con()
	if not skill_con_s or not skill_con_d then return end

	skill_con_s:sub_all_cd()
	skill_con_d:sub_all_cd()

	human_obj_s:passive_sub_attr(human_obj_d)
	human_obj_d:passive_sub_attr(human_obj_s)

	local vedio = {}
	vedio[1] ={}
	vedio[1][1] = human_obj_s:get_attr_list()
	vedio[1][2] = human_obj_d:get_attr_list()
	vedio[2] = {}
	vedio[3] = {}

	local count = 0
	local index = 0
	local flag = math.random(1,2)
	while human_obj_s:get_hp() > 0 and human_obj_d:get_hp() >0 do
		index = index + 1
		if flag == 1 then
			local skill_id, hp, tp = skill_con_s:use(human_obj_s, human_obj_d)
			flag = 2
			vedio[3][index] = {}
			vedio[3][index][1] = skill_id
			vedio[3][index][2] = hp
			vedio[3][index][3] = {human_obj_s:get_hp(),human_obj_s:get_mp(),human_obj_d:get_hp(),human_obj_d:get_mp()}
			vedio[3][index][4] = 1
			vedio[3][index][5] = tp

		else
			local skill_id, hp, tp = skill_con_d:use(human_obj_d,human_obj_s)
			flag = 1
			vedio[3][index] = {}
			vedio[3][index][1] = skill_id
			vedio[3][index][2] = hp
			vedio[3][index][3] = {human_obj_s:get_hp(),human_obj_s:get_mp(),human_obj_d:get_hp(),human_obj_d:get_mp()}
			vedio[3][index][4] = 2
			vedio[3][index][5] = tp
		end
		count = count + 1
		if count >= 50 then
			break
		end
	end

	local s_hp = human_obj_s:get_hp()
	local d_hp = human_obj_d:get_hp()

	local point = 0
	if s_hp > d_hp then
		vedio[2] = 1
		point = self:reward(char_id_s,char_id_d,1)
	elseif d_hp > s_hp then
		vedio[2] = 2
		point = self:reward(char_id_s,char_id_d,2)
	else
		local ram = math.random(1,2)
		if ram == 1 then
			vedio[2] = 1
			point = self:reward(char_id_s,char_id_d,1)
		else
			vedio[2] = 2
			point = self:reward(char_id_s,char_id_d,2)
		end
	end

	local old_count = container_s:get_count()
	container_s:set_count(old_count-1)
	container_s:set_time_span(ev.time + TIME_SPAN)

	local vedio_obj = g_human_vedio_mgr:create_vedio(1)

	vedio_obj:set_vedio_list_ex(vedio)
	vedio_obj:set_char_id_s(char_id_s)
	vedio_obj:set_char_id_d(char_id_d)
	vedio_obj:set_win_flag(vedio[2])

	local vedio_con_s = container_s:get_vedio_con()
	local vedio_con_d = container_d:get_vedio_con()

	vedio_con_s:set_vedio(vedio_obj)
	vedio_con_d:set_vedio(vedio_obj)

	local index_s = self:get_char_index(char_id_s)
	local index_d = self:get_char_index(char_id_d)

	if vedio[2] == 1 and index_s > index_d then
		
		self:del_char(char_id_s)
		--self:del_char(char_id_d)
		self:insert_char_ex(char_id_s,index_d)
		--self:insert_char(char_id_d)
	end

	if g_player_mgr:is_online_char(char_id_s) then
		local line = g_player_mgr:get_char_line(char_id_s)
		local ret = container_s:get_net_info()
		g_server_mgr:send_to_server(line,char_id_s, CMD_P2M_HUMAN_MAIN_INFO_S, ret)

		local ret = {}
		ret.result = 0
		ret.vedio = {vedio}
		ret.flag = 0  --��ɫ����ϵͳ
		g_server_mgr:send_to_server(line,char_id_s, CMD_P2M_HUMAN_FIGHT_S, ret)
	end

	if g_player_mgr:is_online_char(char_id_d) then
		local line = g_player_mgr:get_char_line(char_id_d)
		local ret = container_d:get_net_info()
		g_server_mgr:send_to_server(line,char_id_d, CMD_P2M_HUMAN_MAIN_INFO_S, ret)
	end

	container_s:update_player()
	container_d:update_player()

	self:record_now_week()

	--��ˮ
	local win_flg = vedio[2] 
	if vedio[2] == 2 then
		win_flg = 0
	end
	
	local str = string.format("insert log_char_battle set attack_id = %d, attack_name='%s', defend_id=%d, defend_name = '%s', time=%d,type=%d,result=%d, cur_score=%d, total_score=%d",
				char_id_s, g_player_mgr.all_player_l[char_id_s].char_nm, char_id_d,g_player_mgr.all_player_l[char_id_d].char_nm, ev.time,0,win_flg,point,container_s:get_point())
		g_web_sql:write(str)
end

--A��	ʤ������60��20����1���Է�ʤ�ʣ�
--B��	ʧ�ܷ���10��10����1������ʤ�ʣ�
--��ս�����л��ּ� ����ս��û�� win_flag 1Ϊ��ս��Ӯ 2Ϊ��ս����
function Human_vs_mgr:reward(char_id_s, char_id_d, win_flag)
	
	local container_s = self:get_container(char_id_s)  --��ս��
	local container_d = self:get_container(char_id_d)  --����ս��
	if not container_s or not container_d then return end

	local percent_s = container_s:get_percent()
	local percent_d = container_d:get_percent()

	local point = 0
	if win_flag == 1 then
		point = math.floor(60 + 20 *(1+percent_d))
		container_s:set_winning(1)
		container_d:set_winning(2)
		if not container_s:is_on_table_ex(container_s:get_slave_list(), char_id_d) then
			container_s:add_defeated_member(char_id_d)
		end

		local info = {}
		info[1] = {}
		info[1][1] = 2 --�����б����
		info[1][2] = container_s:get_message_info(container_s:get_defeated_member())

		local server_id = g_player_mgr:get_map_id(char_id_s)
		g_server_mgr:send_to_server(server_id,char_id_s, CMD_P2M_SLAVE_INFO_S, info)
	else
		point = math.floor(10 + 10 * (1+percent_d))
		container_s:set_winning(2)
		container_d:set_winning(1)
		if not container_d:is_on_table_ex(container_d:get_slave_list(), char_id_s) then
			container_d:add_defeated_member(char_id_s)  --������°ܽ�
		end
	end

	container_s:set_point(container_s:get_point() + point)
	--container_lost:set_point(container_lost:get_point() + lost_point)
	--container_win:set_winning(1)
	--container_lost:set_winning(2)

	return point
end

--pkt Ϊ��ս�ߵ�ͬ������
function Human_vs_mgr:update_container_and_fight(char_id_s,char_id_d,pkt)
	local container_s = self:get_container(char_id_s)
	local container_d = self:get_container(char_id_d)
	if not container_s or not container_d then return end

	local hour = tonumber(os.date("%H",ev.time))
	if hour < 20 then --���ϰ˵�ǰ����ͬ��װ������
		container_s:update_list(pkt)

		if g_player_mgr:is_online_char(char_id_d) then
			local node = {}
			node.char_id_s = char_id_s
			node.char_id_d = char_id_d
			local line = g_player_mgr:get_char_line(char_id_d)
			g_sock_event_mgr:add_event_count(char_id_d, CMD_M2P_HUMAN_FIGHT_SYN_S, self, self.syn_info, nil, node, 3, node)
			g_server_mgr:send_to_server(line, char_id_d, CMD_P2M_HUMAN_FIGHT_SYN_C, node)
		else
			container_d:load_human_obj()
			self:fight(char_id_s,char_id_d)
		end
	else
		container_d:load_human_obj()
		container_s:load_human_obj()
		self:fight(char_id_s, char_id_d)
	end
end

function Human_vs_mgr:syn_info(node,pkt)
	local char_id_d = node.char_id_d
	local container_d = self:get_container(char_id_d)
	if not container_d then return end

	container_d:update_list(pkt.syn_info)
	local char_id_s = node.char_id_s
	self:fight(char_id_s,char_id_d)
end


-----------------------------------����-------------------------------
--����� ���ν��� chendong 120928
--[[
--��һ����֪ͨ
function Human_vs_mgr:insert_reward_email(char_id, reward_item)
	local title = f_get_string(2652)
	local content = f_get_string(2653)
	for k,v in pairs(reward_item or {}) do
		local e_code ,item_l = Item_factory.create(v[1])
		if e_code ~= 0 then
			return
		end

		local list = {}
		list[1] = {}
		list[1]["item_id"] = item_l:get_item_id()
		list[1]["item_obj"] = item_l:serialize_to_db()
		list[1]["number"] = v[2]

		g_email_mgr:create_email(-1,char_id,title,content,0,Email_type.type_gold,Email_sys_type.type_sys,list)
	end
end
--]]

--�˶�֪ͨ
function Human_vs_mgr:insert_quit_email(char_id)
	local title = f_get_string(2651)
	local content = f_get_string(2650)
	g_email_mgr:create_email(-1,char_id,title,content,0,Email_type.type_common,Email_sys_type.type_normal,nil)
end

--ÿ��һ���� ���� �ж���ҵĻ��� ���Ƿ��޳����ֵ���0 �����
function Human_vs_mgr:reward_gift()
	local char_id = self.sort_list[1]
	if char_id then
		self:set_last_winner(char_id)
	end

	for k,v in pairs(self.sort_list) do
		for m, n in pairs(reward_loader.reward_index_list or {}) do
			if k <= n then
				local container = self:get_container(v)
				if container then
					--self:insert_reward_email(v,reward_loader.reward_list[n].reward_item or {})
					if container:get_point() <= 0 then
						self.sort_list[k] = nil
						self:del_container(v)
						self:insert_quit_email(v)
					else
						container:reset()
						container:update_player()
					end
				else
					self.sort_list[k] = nil
				end
				break
			end
		end
	end
end
--����� ���ν��� chendong 120928
--[[
--ÿ��12�㽱��
function Human_vs_mgr:reward_gift_ex()
	for k,v in pairs(self.sort_list) do
		for m, n in pairs(reward_loader.reward_index_list or {}) do
			if k <= n then
				local container = self:get_container(v)
				if container then
					self:insert_reward_email(v,reward_loader.reward_list[n].reward_item or {})
				else
					self.sort_list[k] = nil
				end
				break
			end
		end
	end
end
--]]

--ÿ��һ ��¼��һ�ܵ�����������
function Human_vs_mgr:record_last_week()
	local data = {}
	for k,v in pairs(self.sort_list) do
		local container = self:get_container(v)
		if container then
			local info = {}
			info[1] = v
			info[2] = g_player_mgr.all_player_l[v].char_nm
			info[3] = g_player_mgr.all_player_l[v].level
			info[4] = g_player_mgr.all_player_l[v].occ
			info[5] = self:get_container(v):get_fight()
			table.insert(data,info)
		end
	end

	local ret = {}
	ret.data = data
	ret.gift_time = self.gift_time
	local db = f_get_db()
	local t_time = self.submit_time - 7 * 24 * 3600 + 1
	local query = string.format("{time:%d}",tonumber(os.date("%y%m%d",t_time,t_time,t_time)))
	local e_code = db:update("human_fight_winner", query, Json.Encode(ret), true)
end

--��¼��ǰ���ܵ�����
function Human_vs_mgr:record_now_week()
	local ret_t = {}
	local sort_l = {}
	for m,n in pairs(self.sort_list) do
		if ret_t[n] == nil then
			ret_t[n] = 1
			table.insert(sort_l, n)
		else
			self.sort_list[m] = nil
		end
	end

	self.sort_list = sort_l
	local data = {}
	for k,v in pairs(self.sort_list) do
		local container = self:get_container(v)
		if container then
			local info = {}
			info[1] = v
			info[2] = g_player_mgr.all_player_l[v].char_nm
			info[3] = g_player_mgr.all_player_l[v].level
			info[4] = g_player_mgr.all_player_l[v].occ
			info[5] = container:get_fight()
			table.insert(data,info)
		end
	end

	local ret = {}
	ret.data = data
	ret.gift_time = self.gift_time
	local db = f_get_db()
	local t_time = self.submit_time -- - 7 * 24 * 3600 + 1
	local query = string.format("{time:%d}",tonumber(os.date("%y%m%d",t_time,t_time,t_time)))
	local e_code = db:update("human_fight_winner", query, Json.Encode(ret), true)
end


--��ʱ��
function Human_vs_mgr:on_timer()
	if self:is_other_day(self.gift_time) then
		self.gift_time = ev.time
		--self:reward_gift_ex()  -- ����� ���ν��� chendong 120928
		self:record_last_week()
	end

	if ev.time >= self.submit_time then
		self.submit_time = f_get_sunday() + 8 * 24 * 3600 + 1
		self:record_last_week()
		self:reward_gift()
		self:record_now_week()
	end
end


function Human_vs_mgr:get_day_time(l_time)
	local time_today ={}
	time_today.year = os.date("%Y",l_time)
	time_today.month = os.date("%m",l_time)
	time_today.day = os.date("%d",l_time)
	time_today.hour = 0
	time_today.minute = 0
	time_today.second = 0
	local t_time = os.time(time_today)
	return t_time
end

function Human_vs_mgr:is_other_day(time_l, num)     --����ʱ�ж�
	if num == nil then num = 1 end
	if ev.time >= self:get_day_time(time_l) + num * 86400 then
		return true
	end
	return false
end

function Human_vs_mgr:get_click_param()
	return self, self.on_timer,10,nil
end

function Human_vs_mgr:serialize_to_db()
	self:record_last_week()
	--self:record_now_week()
end

-----------------------------------------ū��ϵͳ����ս------------------------------------------
function Human_vs_mgr:slave_fight(char_id_s,char_id_d)
	local container_s = self:get_container(char_id_s)
	local container_d = self:get_container(char_id_d)
	if not container_s or not container_d then return end

	local human_obj_s = container_s:get_human_obj()
	local human_obj_d = container_d:get_human_obj()
	if not human_obj_s or not human_obj_d then return end

	local skill_con_s = human_obj_s:get_skill_con()
	local skill_con_d = human_obj_d:get_skill_con()
	if not skill_con_s or not skill_con_d then return end

	skill_con_s:sub_all_cd()
	skill_con_d:sub_all_cd()

	human_obj_s:passive_sub_attr(human_obj_d)
	human_obj_d:passive_sub_attr(human_obj_s)

	local vedio = {}
	vedio[1] ={}
	vedio[1][1] = human_obj_s:get_attr_list()
	vedio[1][2] = human_obj_d:get_attr_list()
	vedio[2] = {}
	vedio[3] = {}

	local count = 0
	local index = 0
	local flag = math.random(1,2)
	while human_obj_s:get_hp() > 0 and human_obj_d:get_hp() >0 do
		index = index + 1
		if flag == 1 then
			local skill_id, hp, tp = skill_con_s:use(human_obj_s, human_obj_d)
			flag = 2
			vedio[3][index] = {}
			vedio[3][index][1] = skill_id
			vedio[3][index][2] = hp
			vedio[3][index][3] = {human_obj_s:get_hp(),human_obj_s:get_mp(),human_obj_d:get_hp(),human_obj_d:get_mp()}
			vedio[3][index][4] = 1
			vedio[3][index][5] = tp

		else
			local skill_id, hp, tp = skill_con_d:use(human_obj_d,human_obj_s)
			flag = 1
			vedio[3][index] = {}
			vedio[3][index][1] = skill_id
			vedio[3][index][2] = hp
			vedio[3][index][3] = {human_obj_s:get_hp(),human_obj_s:get_mp(),human_obj_d:get_hp(),human_obj_d:get_mp()}
			vedio[3][index][4] = 2
			vedio[3][index][5] = tp
		end
		count = count + 1
		if count >= 50 then
			break
		end
	end

	local s_hp = human_obj_s:get_hp()
	local d_hp = human_obj_d:get_hp()

	if s_hp > d_hp then
		vedio[2] = 1
	elseif d_hp > s_hp then
		vedio[2] = 2
	else
		local ram = math.random(1,2)
		if ram == 1 then
			vedio[2] = 1
		else
			vedio[2] = 2
		end
	end

	local vedio_obj = g_human_vedio_mgr:create_vedio(1)

	vedio_obj:set_vedio_list_ex(vedio)
	vedio_obj:set_char_id_s(char_id_s)
	vedio_obj:set_char_id_d(char_id_d)
	vedio_obj:set_win_flag(vedio[2])

	local vedio_con_s = container_s:get_vedio_con()
	local vedio_con_d = container_d:get_vedio_con()

	vedio_con_s:set_vedio(vedio_obj)
	vedio_con_d:set_vedio(vedio_obj)

	if g_player_mgr:is_online_char(char_id_s) then
		local line = g_player_mgr:get_char_line(char_id_s)
		local ret = {}
		ret.result = 0
		ret.vedio = {vedio}
		ret.flag = 1  --ū��ϵͳ
		g_server_mgr:send_to_server(line,char_id_s, CMD_P2M_HUMAN_FIGHT_S, ret)
	end

	if vedio[2] == 1 then
		return true   --ʤ��
	elseif vedio[2] == 2 then
		return false  --ʧ��
	end
end

--slave ��սʤ��
function Human_vs_mgr:slave_success(char_id_s, char_id_d, node)
	local container_s = self:get_container(char_id_s)
	local container_d = self:get_container(char_id_d)
	if not container_s or not container_d then return end

	local type = node.type
	local ret = {}
	ret.result = 0
	local info = {}
	if type == 1 then --���°ܽ� (��ս����)
		local container = self:get_container(node.char_id)
		if container then
			if container_s:get_slave_owner() == node.char_id then
				container:del_slave(char_id_s)
				container_s:set_slave_owner()
				if not container_s:is_on_table_ex(container_s:get_slave_list(), char_id_d) then
					container_s:add_defeated_member(char_id_d)  --������°ܽ�
				end
				container_s:update_player()
				container:update_player()
			else
				container:set_slave_owner()      --ū�����˱�����Լ�
				container:add_old_owner(char_id_d)        --ū����Ӿ���
				--container_s:add_slave(node.char_id)      --�Լ����ū��
				--container_s:del_defeated_member(node.char_id) --ū�������°ܽ�����

				if not container_s:is_on_table_ex(container_s:get_slave_list(), char_id_d) then
					container_s:add_defeated_member(char_id_d)  --������°ܽ�
				end
				container_d:del_slave(node.char_id) --����ū��
				container_d:add_slave_enemy(char_id_s) --��ǰ������Ӷ���֮��

				container_d:update_player()
				container_s:update_player()
				container:update_player()

				self:insert_slave_email(char_id_s, node.char_id)
			end
		end

		ret.type = 2
		
		info[1] = {}
		info[1][1] = 1 --ū���б�
		info[1][2], info[1][3] = container_s:get_slave_info() 
				
	elseif type == 2 then --���°ܽ���ץȡū����
		if container_s:get_slave_owner() == char_id_d then
			container_d:del_slave(char_id_s)
			container_s:set_slave_owner()
		else
			container_s:add_slave(char_id_d)			--���ū��
			container_d:set_slave_owner(char_id_s)      --���°ܽ����ū������
			container_s:del_defeated_member(char_id_d)  --�����°ܽ��б��޳�
			self:insert_slave_email(char_id_s, char_id_d)
		end
		container_d:update_player()
		container_s:update_player()

		ret.type = 2

		info[1] = {}
		info[1][1] = 1 --ū���б�
		info[1][2], info[1][3] = container_s:get_slave_info() 
	elseif type == 3 then --����֮��
		if not container_s:is_on_table_ex(container_s:get_slave_list(), char_id_d) then
			container_s:add_defeated_member(char_id_d) --������°ܽ�
		end
		container_s:del_slave_enemy(char_id_d)     --�Ƴ�����֮��
		container_s:update_player()
		
		ret.type = 3

		info[1] = {}
		info[1][1] = 3 --����֮���б�
		info[1][2] = container_s:get_message_info(container_s:get_slave_enemy()) 
	elseif type == 4 then --�ҵľ���
		if not container_s:is_on_table_ex(container_s:get_slave_list(), char_id_d) then
			container_s:add_defeated_member(char_id_d) --������°ܽ�
		end
		container_s:del_old_owner(char_id_d)       --�Ƴ��ҵľ���
		container_s:update_player()

		ret.type = 4

		info[1] = {}
		info[1][1] = 4 --�ҵľ����б�
		info[1][2] = container_s:get_message_info(container_s:get_old_owner())
		g_server_mgr:send_to_server(server_id,char_id_s, CMD_P2M_SLAVE_INFO_S, info)
	elseif type == 5 then --���ū��
		local container = self:get_container(node.char_id)
		if container then
			container:set_slave_owner()		--ū���������˱�������
			container:add_old_owner(char_id_d) --ū����Ӿ���

			if not container_s:is_on_table_ex(container_s:get_slave_list(), char_id_d) then
				container_s:add_defeated_member(char_id_d)  --������°ܽ�
			end
			container_d:del_slave(node.char_id) --����ū��

			container_d:update_player()
			container_s:update_player()
			container:update_player()
		end

		ret.type = 5

		info[1] = {}
		info[1][1] = 5 --���ū���б�
		info[1][2] = container_s:get_liberation_info()
	elseif type == 6 then  --��ս�Լ�����
		container_s:add_defeated_member(char_id_d)  --������°ܽ�
		container_d:del_slave(node.char_id_s) --����ū��
		container_s:set_slave_owner() --��������Ϊ��
		container_s:add_old_owner(char_id_d) --��Ӿ���
		container_d:update_player()
		container_s:update_player()

		ret.type = 1

		info[1] = {}
		info[1][1] = 4 --�ҵľ����б�
		info[1][2] = container_s:get_message_info(container_s:get_old_owner())
	end

	info[2] = {}
	info[2][1] = 2 --�����б����
	info[2][2] = container_s:get_message_info(container_s:get_defeated_member())

	local server_id = g_player_mgr:get_map_id(char_id_s)
	g_server_mgr:send_to_server(server_id,char_id_s, CMD_P2M_SLAVE_INFO_S, info)
	g_server_mgr:send_to_server(server_id,char_id_s, CMD_P2M_SLAVE_CHALLENGE_S, ret)
end

function Human_vs_mgr:slave_fail(type,char_id_s)
	local ret = {}
	ret.result = 22654
	if type == 1 then
		ret.type = 2
	elseif type == 2 then
		ret.type = 2
	elseif type == 3 then
		ret.type = 3
	elseif type == 4 then
		ret.type = 4
	elseif type == 5 then
		ret.type = 5
	elseif type == 6 then
		ret.type = 1
	end

	local server_id = g_player_mgr:get_map_id(char_id_s)
	--g_server_mgr:send_to_server(server_id,char_id_s, CMD_P2M_SLAVE_CHALLENGE_S, ret)
end

--�ʼ�֪ͨ
function Human_vs_mgr:insert_slave_email(char_id_s, char_id_d)
	local count = 0
	for k,v in pairs(self.sort_list) do
		count = count + 1
		if count > 10 then return end
		if v == char_id_d then
			local title = f_get_string(2651)
			local content = string.format(f_get_string(2654),g_player_mgr.all_player_l[char_id_d].char_nm,g_player_mgr.all_player_l[char_id_s].char_nm)
			g_email_mgr:create_email(-1,char_id_d,title,content,0,Email_type.type_common,Email_sys_type.type_normal,nil)
		end
	end
end
--
function Human_vs_mgr:update_container_and_slave_fight(char_id_s,char_id_d,pkt, param)
	local container_s = self:get_container(char_id_s)
	local container_d = self:get_container(char_id_d)
	if not container_s or not container_d then return end

	local hour = tonumber(os.date("%H",ev.time))
	if hour < 20 then --���ϰ˵�ǰ����ͬ��װ������
		container_s:update_list(pkt)

		if g_player_mgr:is_online_char(char_id_d) then
			local node = {}
			node.char_id_s = char_id_s
			node.char_id_d = char_id_d
			node.char_id = param.char_id
			node.type = param.type
			local line = g_player_mgr:get_char_line(char_id_d)
			g_sock_event_mgr:add_event_count(char_id_d, CMD_M2P_HUMAN_FIGHT_SYN_S, self, self.slave_syn_info, nil, node, 3, node)
			g_server_mgr:send_to_server(line, char_id_d, CMD_P2M_HUMAN_FIGHT_SYN_C, node)
		else
			container_d:load_human_obj()
			local result = self:slave_fight(char_id_s,char_id_d) 
			if result == true then
				self:slave_success(char_id_s, char_id_d, param)
			else
				container_d:add_defeated_member(char_id_s)  --��սʧ�ܣ��Լ���ɱ��˵����°ܽ�
				self:slave_fail(param.type, char_id_s)
			end
		end
	else
		container_d:load_human_obj()
		container_s:load_human_obj()
		local result = self:slave_fight(char_id_s,char_id_d) 
		if result == true then
			self:slave_success(char_id_s, char_id_d, param)
		else
			container_d:add_defeated_member(char_id_s)  --��սʧ�ܣ��Լ���ɱ��˵����°ܽ�
			self:slave_fail(param.type, char_id_s)
		end
	end
end

function Human_vs_mgr:slave_syn_info(node,pkt)
	local char_id_d = node.char_id_d
	local char_id_s = node.char_id_s
	local container_d = self:get_container(char_id_d)
	local container_s = self:get_container(char_id_s)
	if not container_d or not container_s then return end

	container_d:update_list(pkt.syn_info)
	local result = self:slave_fight(char_id_s,char_id_d)

	if result == true then
		self:slave_success(char_id_s, char_id_d, node)
	else
		if not container_d:is_on_table_ex(container_d:get_slave_list(), char_id_s) then
			container_d:add_defeated_member(char_id_s)  --��սʧ�ܣ��Լ���ɱ��˵����°ܽ�
		end
		self:slave_fail(node.type, char_id_s)
	end
end

-----------------------------��ʼ��------------------------------
function Human_vs_mgr:load()
	local db = f_get_db()
	local rows, e_code = db:select("human_fight")
	if 0 == e_code and rows then
		for k, v in pairs(rows) do
			local char_id = v.char_id
			local con = self:create_container_ex(char_id)
			con:set_count(v.count)
			con:set_time_span(v.time_span)
			con:set_vs_list(v.vs_list)
			con:set_point(v.point)
			con:set_challenge_time(v.challenge_time)
			con:set_s_count(v.s_count)
			con:set_slave_owner(v.slave_owner)
			con:set_slave_info(v.slave_info or {})
			con:set_s_time(v.s_time or 0)
			con:set_be_s_count(v.be_s_count)
			con:is_other_day()
			self:insert_char(char_id)
			--con:load()
		end
	end

	local db = f_get_db()
	local time_t = ev.time
	local data = "{data:1,gift_time:1}" --char_id,char_name,level,occ,fight
	local monday = f_get_sunday() + 24 * 3600 + 1
	local t_time = tonumber(os.date("%y%m%d",monday,monday,monday))
	local condition = string.format("{time:%d}",t_time)
	local row, e_code = db:select_one("human_fight_winner",data,condition)
	if 0 == e_code and row then
		local data = row.data
		self.gift_time = row.gift_time or ev.time
		if tonumber(os.date("%w",ev.time)) == 0 then
			self.submit_time = f_get_today(ev.time) + 24 * 3600 + 1
		else
			self.submit_time = f_get_sunday() + 8 * 24 * 3600 + 1
		end
		if table.size(data) == 0 then
			self.last_winner = {"",0,0,0}
		else
			self.last_winner = {data[1][2],data[1][3],data[1][4],data[1][5]}
		end
	else
		self.last_winner = {"",0,0,0}
		self.gift_time = ev.time
		local ret = {}
		ret.time = t_time
		ret.data = {}
		ret.gift_time = ev.time
		if tonumber(os.date("%w",ev.time)) == 0 then
			self.submit_time = f_get_today(ev.time) + 24 * 3600 + 1
		else
			self.submit_time = f_get_sunday() + 8 * 24 * 3600 + 1
		end

		db:insert("human_fight_winner",Json.Encode(ret))
	end

	local monday = self.submit_time
	local t_time = tonumber(os.date("%y%m%d",monday,monday,monday))
	local condition = string.format("{time:%d}",t_time)
	local row, e_code = db:select_one("human_fight_winner",data,condition)
	if 0 == e_code and row then
		local data = row.data
		if table.size(data) > 0 then
			self.sort_list = {}
			for k,v in pairs(data) do
				local container = self:get_container(v[1])
				if container then
					table.insert(self.sort_list,v[1])
				end
			end
		end
	end

end





