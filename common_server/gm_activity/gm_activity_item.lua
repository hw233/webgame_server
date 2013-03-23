--2012-03-05
--cqs
--���


local database = "gm_activity"

Gm_activity_item = oo.class(nil, "Gm_activity_item")

function Gm_activity_item:__init(type)
	self.type = type
	self.flags, self.update_t = self:check_update_time(type)
	if self.flags == 2 then
		self:open_common_active_interface(self.type)
	end
end

function Gm_activity_item:check_update_time(type)
	local db = f_get_db()

	local query = string.format("{type:%d}",type)

	local rows, e_code = db:select(database, nil, query)
	if 0 == e_code then
		rows = rows or {}
		table.sort(rows, function(e1,e2) 
						return e1.start_t < e2.start_t 
					end)
		for k, v in ipairs(rows) do
			if v.end_t >= ev.time then
				if v.start_t <= ev.time then		--���
					self.param = {}
					self.param.start_t = v.start_t
					self.param.end_t = v.end_t
					self.param.param = v.param
					self.param.id = v.id
					return 2, v.end_t
				else								--�����ʱ
					self.param = {}
					self.param.start_t = v.start_t
					self.param.end_t = v.end_t
					self.param.param = v.param
					self.param.id = v.id
					return 1, v.start_t
				end
			end
		end
		return 0									--û���κλ
	else
		return 0
	end
end

function Gm_activity_item:get_update_time(type)
	local db = f_get_db()

	local query = string.format("{type:%d}",type)

	local rows, e_code = db:select(database, nil, query)
	if 0 == e_code then
		rows = rows or {}
		table.sort(rows, function(e1,e2) 
						return e1.start_t < e2.start_t 
					end)
		for k, v in ipairs(rows or {}) do
			if v.end_t >= ev.time then
				if v.start_t <= ev.time then		--���
					return 2, v.end_t, v.id
				else								--�����ʱ
					return 1, v.start_t, v.id
				end
			end
		end
		return 0									--û���κλ
	else
		return 0
	end
end

function Gm_activity_item:on_timer()
	if self.flags ~= 0 and self.update_t < ev.time then
		if self.flags == 1 then					--���ʼ
			self:update_all_map_activity()
			self.flags, self.update_t = self:check_update_time(self.type)

		elseif self.flags == 2 then				--�����
			self:delete_all_map_activity()
			self.flags, self.update_t = self:check_update_time(self.type)
			if self.flags == 2 then				--������������»��ʼ	
				self:update_all_map_activity()
			end
		end
	end
end

function Gm_activity_item:accept_notice()
	local flags, update_t, activity_id = self:get_update_time(self.type)

	if self.flags == 2 then							--ԭ�����л
		if flags == 2 then							--���º��ѿ�ʼ
			if self.param.id ~= activity_id then	--��ԭ���ͬ����Ҫ�����,������		
				self:delete_all_map_activity()
				self.flags, self.update_t = self:check_update_time(self.type)
				self:update_all_map_activity()
			else									--�����κβ���
			end
		else										--���º���û��,���ԭ������³�ʼ��
			self:delete_all_map_activity()
			self.flags, self.update_t = self:check_update_time(self.type)
		end
	else											--ԭ���޻�����³�ʼ��
		self.flags, self.update_t = self:check_update_time(self.type)
		if flags == 2 then							--���º��л
			self:update_all_map_activity()
		end
	end
end

--���ƴ�ȫ���
function Gm_activity_item:update_all_map_activity()
	local pkt = {}
	pkt.type = self.type
	pkt.flags = 1		--��
	pkt.param = self:serialize_to_net()

	g_server_mgr:send_to_all_map(0, CMD_GM_ACTIVITY_NOTICE_C, pkt)

	self:open_common_active_interface(self.type)
end
--���Ƶ��ߴ�ȫ���
function Gm_activity_item:update_map_activity(server_id)
	local pkt = {}
	pkt.type = self.type
	pkt.flags = 1		--��
	pkt.param = self:serialize_to_net()
	g_server_mgr:send_to_server(server_id, 0, CMD_GM_ACTIVITY_NOTICE_C, pkt)
end


--���ƹر�ȫ���
function Gm_activity_item:delete_all_map_activity()
	local pkt = {}
	pkt.type = self.type
	pkt.flags = 2		--�ر�
	pkt.param = self:serialize_to_net()
	g_server_mgr:send_to_all_map(0, CMD_GM_ACTIVITY_NOTICE_C, pkt)

	self:close_common_active_interface(self.type)
end

--���Ƶ��߹ر�ȫ���
function Gm_activity_item:deletel_map_activity(server_id)
	local pkt = {}
	pkt.type = self.type
	pkt.flags = 2		--�ر�
	pkt.param = self:serialize_to_net()
	g_server_mgr:send_to_server(server_id, 0, CMD_GM_ACTIVITY_NOTICE_C, pkt)
end

--��������
function Gm_activity_item:serialize_to_net()
	return self.param
end

--ͬ������map
function Gm_activity_item:syn_activity_to_map(server_id)
	if self.flags == 2 then
		self:update_map_activity(server_id)
	else
		self:deletel_map_activity(server_id)
	end

	return
end

--��������������ӿ�(���������л������������)
function Gm_activity_item:open_common_active_interface(type)

	--֪ͨ�������� ����������
	if type == 3 then
		g_collection_activity_mgr:load_active_info(self.param.id, self.param.end_t, self.param.start_t, self.param.param.active_id)
	end
end

----��������������ӿ�(���������л��������ر�)
function Gm_activity_item:close_common_active_interface(type)

	--֪ͨ�������� ����������
	if type == 3 then
		g_collection_activity_mgr:close_active_info()
	end
end	