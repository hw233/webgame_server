--2012-8-9
--zhengyg
--rank_charm
local data_table = "activity_rank_sum"
--local data_table = "activity_rank_sum_test"


local _rank_cfg = require("activity_rank.activity_rank_loader")

rank_charm = oo.class(rank_base,"rank_charm")

function rank_charm:__init()
	rank_base.__init(self)
	
	self.today = 0 --f_get_today(ev.time)
	self.sort_today = {['cnt']=0, ['list']={}, ['map']={}} --��������
	self.sort_pre 	= {['cnt']=0, ['list']={}, ['map']={}} --��������
	self.sort 		= {['cnt']=0, ['list']={}, ['map']={}} --������
	self.reward = {} --��¼�Ѿ����Ź��Ľ��� id,�����ظ�����
	self.data_version = {ev.time, ev.time, ev.time}-- �����������ܰ����ݰ汾
	--����
	self:unserialize()
	
	--������ڱ����������Ӧ����
	self:check_update()
end

function rank_charm:check_update() --���� ���ڱ�� �ʱ��
	local turn_on = self.turn_on
	
	rank_base.check_update(self)--���ܻ��޸� self.turn_on
	
	if not turn_on and not self.turn_on then return end --�����ĺô��� �����ʱ �ٸ���һ�Σ����㷢��ģ��(do_reward_timer)����������ȷ
	
	local a_o = _rank_cfg.get_activity(self:get_type())
	if a_o == nil then return end
	
	if a_o.id ~= self.id then --�id��ͬ�ˣ� ��������
		self.id = a_o.id
		self.today = f_get_today(ev.time)
		self.sort_today = {['cnt']=0, ['list']={}, ['map']={}} --��������
		self.sort 		= {['cnt']=0, ['list']={}, ['map']={}} --���������
		self.sort_pre 	= {['cnt']=0, ['list']={}, ['map']={}} --��������
		self.reward = {} --��¼�Ѿ����Ź��Ľ���,�����ظ�����
		--self.data_version = {ev.time, ev.time, ev.time}-- �����������ܰ����ݰ汾
		self.data_version[1] = self.data_version[1] + 1
		self.data_version[2] = self.data_version[2] + 1
		self.data_version[2] = self.data_version[3] + 1
		self:syn_map_rank_data()
	end
	
	if not self.id then return end --�޻
	
	local today = f_get_today(ev.time)
	if f_get_today(self.today) ~= today then --���������
		if f_get_today(self.today) == f_get_today(ev.time - 3600*24) then
			self.sort_pre = table.copy(self.sort_today) --�������а�
		else
			self.sort_pre = {['cnt']=0, ['list']={}, ['map']={}} --��������ͣ��һ������û�� ���ܵ�������
		end
		self.today = today
		self.sort_today = {['cnt']=0, ['list']={}, ['map']={}} --���õ�������
		self.data_version[1] = self.data_version[1] + 1
		self.data_version[2] = self.data_version[2] + 1
		self:syn_map_rank_data()
	end
end

function rank_charm:do_timer() --��ʱִ��
	rank_base.do_timer(self)
	self:check_update()	   --���¼��
	self:do_reward_timer() --�������
	--print('rank_charm:do_timer()')
end

function rank_charm:do_reward_timer() --����,������������ʼ��ʱ�����˲���
	local a_cfg = _rank_cfg._activity_rank_cfg[self:get_type()]
	
	if not self.id or a_cfg and a_cfg.id ~= self.id then return end

	if not self.turn_on and self:get_end_t() < (ev.time - 3600*24) then return end --����ں�һ�죬��Ȼ���ֽ�����������
		
	local timestamp_set = a_cfg and a_cfg.timestamp_set
	if timestamp_set == nil then return end
	
	for t_id, t_stamp in pairs(timestamp_set) do --�������з���ʱ���
		if self.reward[tostring(t_stamp.t_id)] == nil then --��������δ����
			if f_get_today(t_stamp.start_t) < self.today then
				self.reward[tostring(t_stamp.t_id)] = 1 --����֮ǰû�з��Ľ���������
			elseif ev.time > t_stamp.start_t and f_get_today(t_stamp.start_t) == self.today then --��������ʱ�䵽 ���ҵ�ǰʱ���ڽ�����
				self.reward[tostring(t_stamp.t_id)] = 1 --��־Ӧ��ʱ��� �������Ѿ�����
				
				for order, gift in pairs(t_stamp.gift_set) do --�����ν���
					local recevier = nil
					local title = nil
					local content = nil
					local box_title = ""
					local money_list = ""
					
					if t_stamp.reward_type == 1 then --�հ�,�ڶ��췢ǰһ��Ľ�Ʒ�����Դ����հ�ȥȡ����
						recevier = self.sort_pre.list[order] and self.sort_pre.list[order][1]
						title = string.format(f_get_string(2945),order)
						content = string.format(f_get_string(2946),order)
						box_title = string.format(f_get_string(2949),order)
					elseif t_stamp.reward_type == 2 then--�ܰ�
						recevier = self.sort.list[order] and self.sort.list[order][1]
						title = string.format(f_get_string(2947),order)
						content = string.format(f_get_string(2948),order)
						box_title = string.format(f_get_string(2950),order)
					end
					
					if recevier then
						local email = {}
						email.sender = -1
						email.recevier = recevier
						email.title = title
						email.content = content
						email.box_title = box_title
						email.money_list = {}
						
						email.item_list = {}
						if gift.item_id then
							local item = {}
							item.id = gift.item_id
							item.name = gift.name or ""
							item.count = gift.num
							table.insert(email.item_list, item)
						end
						g_email_mgr:send_email_interface(email)
						--print("CHARM_RANK_GIFT:",j_e(email))
					end
				end
			end
		end
	end
end

function rank_charm:get_type()
	return ACTIVITY_RANK_TYPE.RANK_CHARM
end

function rank_charm:update_rank_info(pkt)
	rank_base.update_rank_info(self,pkt)
	
	--print(j_e(pkt))
	
	local change_flag = nil
	
	if not self.turn_on then return end --�δ����
	
	if 1 == self:update_rank_info_utility(self.sort,pkt.info) then --�����ܰ�
		self.data_version[3] = self.data_version[3] + 1
		change_flag = true
	end
	
	if pkt.info_today[4] == self.today then --�����հ�
		if 1== self:update_rank_info_utility(self.sort_today,pkt.info_today) then
			self.data_version[1] = self.data_version[1] + 1
			change_flag = true
		end
	end
	
	if change_flag then--�иĶ� ��֪ͨmap,��Ƶ����Ӧ�ò�������������
		self:syn_map_rank_data()
	end
	
	--self:print() --����
end

function rank_charm:update_rank_info_utility(sort_list,info)
	if info[2] <= 0 then --��ֵС�ڵ���0 ��ȫû�ʸ�
		return 
	end
	
	local min_cnt = 1		 --�ϰ���Сֵ
	if sort_list.cnt >= self:get_rank_limit() then
		min_cnt = sort_list.list[self:get_rank_limit()][2]
	end
	
	if info[2] < min_cnt then --����û��Χ
		return
	end
	
	local index =  sort_list.map[info[1]] --��һ���Ƿ��Ѿ��ڰ�����
	
	if index == nil then --֮ǰ���ڰ���
		index = self:locate_index_dasc(sort_list, info, 2, 3)
		if index <= self:get_rank_limit() then	--�ڰ�Χ��
			self:table_insert(sort_list,index,info) --�ϰ�
			if sort_list.list[self:get_rank_limit()+1] then --�������������
				self:table_remove(sort_list,self:get_rank_limit()+1)
			end
			return 1
		end
	else
		local old_index = index
		local old_charm = sort_list.list[index][2]
		
		self:table_remove(sort_list, index) --�Ƚ�֮ǰ�������Ƴ�
		index = self:locate_index_dasc(sort_list, info, 2, 3)
		if index <= self:get_rank_limit() then --�ڰ�Χ��
			self:table_insert(sort_list,index,info) --�ϰ�
			if sort_list.list[self:get_rank_limit()+1] then
				self:table_remove(sort_list,self:get_rank_limit()+1)
			end
		end
		
		local new_charm = sort_list.list[index][2]
		if old_index~=index or new_charm~=old_charm then
			return 1
		end
	end
end

function rank_charm:serialize()
	local dbh = f_get_db()
	--���汾����������
	local rec = {}
	rec.type = self:get_type()
	rec.id = self.id
	rec.today = self.today
	
	rec.sort = {}
	for i = 1,self:get_rank_limit() do
		if self.sort.list[i] == nil then break end
		rec.sort[i] = self.sort.list[i]
	end
	
	rec.sort_today = {}
	for i = 1,self:get_rank_limit() do
		if self.sort_today.list[i] == nil then break end
		rec.sort_today[i] = self.sort_today.list[i]
	end
	
	rec.sort_pre = {}
	for i = 1,self:get_rank_limit() do
		if self.sort_pre.list[i] == nil then break end
		rec.sort_pre[i] = self.sort_pre.list[i]
	end
	
	rec.sort_today = {}
	for i = 1,self:get_rank_limit() do
		if self.sort_today.list[i] == nil then break end
		rec.sort_today[i] = self.sort_today.list[i]
	end
	
	rec.reward = self.reward
	rec.data_version = self.data_version
	--print(j_e(rec))
	if 0 == dbh:update(data_table,"{type:1}", Json.Encode(rec), true) then
		--db update suc
	end
end

function rank_charm:unserialize()
	local today = f_get_today(ev.time)
	local yesterday = f_get_today(ev.time - 3600*24)

	local dbh = f_get_db()
	local condition = string.format("{type:%d}",self:get_type())
	local rows, e_code = dbh:select_one(data_table, nil, condition)

	assert(e_code == 0,'rank_charm:unserialize() error1')

	if rows then
		self.id = rows.id
		self.reward = rows.reward or {}
		self.today = rows.today
		
		--���ؽ��հ�
		for index,info in pairs(rows.sort_today or {}) do
			self:update_rank_info_utility(self.sort_today, info)
		end		
		--�������հ�
		for index, info in pairs(rows.sort_pre or {}) do
			self:update_rank_info_utility(self.sort_pre, info)
		end
		--�����ܰ�
		for index, info in pairs(rows.sort or {}) do
			self:update_rank_info_utility(self.sort, info)
		end
		
		self.data_version = rows.data_version or {ev.time, ev.time, ev.time}
	end
	--self:print()
end

function rank_charm:serialize_to_net()
	local to_net = {}
	
	to_net.sort = {}
	for i = 1, self:get_rank_limit() do
		local it = self.sort.list[i]
		if it == nil then break end
		
		local char = g_player_mgr.all_player_l[it[1]]
		to_net.sort[i] = {it[1], it[2], char.char_nm or "", char.occ or 0, char.gender or 0}
	end
	
	to_net.sort_today = {}
	for i = 1, self:get_rank_limit() do
		local it = self.sort_today.list[i]
		if it == nil then break end
		
		local char = g_player_mgr.all_player_l[it[1]]
		to_net.sort_today[i] = {it[1], it[2], char.char_nm or "", char.occ or 0, char.gender or 0}
	end
	
	to_net.sort_pre = {}
	for i = 1, self:get_rank_limit() do
		local it = self.sort_pre.list[i]
		if it == nil then break end
		
		local char = g_player_mgr.all_player_l[it[1]]
		to_net.sort_pre[i] = {it[1], it[2], char.char_nm or "", char.occ or 0, char.gender or 0}
	end

	to_net.data_version = self.data_version
	
	return to_net
end

function rank_charm:print()
	for i = 1, 50 do
		if self.sort.list[i] == nil then break end
		print('sort_'..i, j_e(self.sort.list[i]))
	end
	for i = 1, 50 do
		if self.sort_today.list[i] == nil then break end
		print('sort_today_'..i, j_e(self.sort_today.list[i]))
	end
	for i = 1, 50 do
		if self.sort_pre.list[i] == nil then break end
		print('sort_pre_'..i, j_e(self.sort_pre.list[i]))
	end
end

register_activity_rank_builder(rank_charm.get_type(),rank_charm)
