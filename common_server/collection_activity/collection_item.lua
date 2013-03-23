
----------------------------------��Ҫ�ռ�����Ʒ
local collection_activity_loader = require("config.loader.collection_activity_loader")

Collection_activity_item = oo.class(nil, "Collection_activity_item")


function Collection_activity_item:__init(id, data,start_t,end_t)
	self.id = id
	self.start_t = start_t 
	self.end_t   = end_t 
	if data then
		self:load(id, data)
	else
		self:init_id(id)
	end

	--self:update_all_map_buf()
end


-------------------------------------------------�ڲ��ӿ�
--�ռ������ռ���������
function Collection_activity_item:load(id, data)
	local activity_info = collection_activity_loader.get_recently_info(id)

	--ÿ���ȼ���Ӧ���ռ�����
	self.lvl_cnt = {}
	for k, v in ipairs(activity_info.lvl_info) do
		self.lvl_cnt[k] = v.count
	end

	self.maxlv = table.getn(self.lvl_cnt)
	--���ռ�����Ʒ
	self.items = data
	--�ռ���ȼ�
	self.item_lvl = {}
	for k, v in ipairs(self.items) do
		self.item_lvl[k] = 1
		for i = table.getn(self.lvl_cnt), 1, -1 do
			if v > self.lvl_cnt[i] then
				if i + 1 >= self.maxlv then
					i = self.maxlv
				else
					i = i+1
				end
				self.item_lvl[k] = i
				break
			end
		end
	end
	
	--����ȼ�,���ռ��������
	self.lvl = 100
	for k, v in ipairs(self.item_lvl) do
		if self.lvl > v then
			self.lvl = v
		end
	end	
end


function Collection_activity_item:init_id(id)
	local activity_info = collection_activity_loader.get_recently_info(id)
--	print("60 =", j_e(activity_info.item_info))
	--����ȼ�
	self.lvl = 1

	--ÿ���ȼ���Ӧ���ռ�����
	self.lvl_cnt = {}
	for k, v in ipairs(activity_info.lvl_info) do
		self.lvl_cnt[k] = v.count
	end
	self.maxlv = table.getn(self.lvl_cnt)
	--���ռ�����Ʒ
	self.items = {}
	--�ռ���ȼ�
	self.item_lvl = {}
	for k, v in ipairs(activity_info.item_info) do
		self.items[k] = 0
		self.item_lvl[k] = 1
	end
end

--��������
function Collection_activity_item:level_up(tmp_lvl)
	--buf��
	self:delete_all_map_buf()

	self.lvl = tmp_lvl

	--buf��
	self:update_all_map_buf(flags)

	--�㲥
	local pkt = {}
	pkt.lvl = self.lvl
	pkt = Json.Encode(pkt)
	for k , v in pairs(g_player_mgr.online_player_l) do
		g_svsock_mgr:send_server_ex(WORLD_ID, k, CMD_C2W_COLLECTION_ACTIVITY_LVLUP_S, pkt, true)
	end
end
-------------------------------------------------------�ⲿ�ӿ�
--��ID�����ռ���
function Collection_activity_item:add_item_id(id, cnt)
	if not self.items[id] then
		return 1
	end

	self.items[id] = self.items[id] + cnt
	if self.items[id] > self.lvl_cnt[self.item_lvl[id]] then	--�ռ�������
		--�ռ�������
		local tmp_lvl = self.item_lvl[id] + 1
		if tmp_lvl+1 > self.maxlv then
			tmp_lvl = self.maxlv
		end
		for i = tmp_lvl, table.getn(self.lvl_cnt) do
			if self.items[id] < self.lvl_cnt[i] then
				self.item_lvl[id] = i
				break
			end
		end
		--�ж��Ƿ��������
		tmp_lvl = 100 
		local lvlup_flags = true
		for k, v in ipairs(self.item_lvl) do
			if v < self.item_lvl[id] then
				lvlup_flags = false
				break
			end
		end

		if lvlup_flags and self.item_lvl[id] > self.lvl then
			self:level_up(self.item_lvl[id])
		end
	end

end

--��ȡ�ռ���������Ϣ
function Collection_activity_item:get_items_info()
	local pkt = {}
	for k, v in pairs(self.items) do
		pkt[k] = {}
		pkt[k][1] = v
		pkt[k][2] = self.lvl_cnt[self.lvl]
	end

	return pkt
end


--���ƴ�ȫ��buf
function Collection_activity_item:update_all_map_buf(flags)
	local pkt = {}
	pkt.type = 1		--����buf

	--if flags then		--������Ҫ֪ͨÿ����lvl���ݸ���
		pkt.lvl = self.lvl
	--end

	local tmp_t = collection_activity_loader.get_all_reward_buf(self.id, self.lvl)
	pkt.param = {}
	local p_time = self.end_t - ev.time --collection_activity_loader.get_over_t(self.id)
	for k, v in pairs(tmp_t) do
		pkt.param[k] = {}
		pkt.param[k].type = k
		pkt.param[k].time = p_time
		pkt.param[k].p_time = v
	end 

	g_server_mgr:send_to_all_map(0, CMD_COLLECTION_ACTIVITY_BUF_C, pkt)
end

--���Ƶ��ߴ�ȫ��buf
function Collection_activity_item:update_map_buf(server_id, flags)
	local pkt = {}
	pkt.type = 1		--����buf

	if flags then		--������Ҫ֪ͨÿ����lvl���ݸ���
		pkt.lvl = self.lvl
	end

	local tmp_t = collection_activity_loader.get_all_reward_buf(self.id, self.lvl)
	pkt.param = {}
	local p_time = self.end_t - ev.time --collection_activity_loader.get_over_t(self.id)
	for k, v in pairs(tmp_t) do
		pkt.param[k] = {}
		pkt.param[k].type = k
		pkt.param[k].time = p_time
		pkt.param[k].p_time = v
	end 
	g_server_mgr:send_to_server(server_id, 0, CMD_COLLECTION_ACTIVITY_BUF_C, pkt)
end


--���ƹر�ȫ��buf
function Collection_activity_item:delete_all_map_buf()
	local pkt = {}
	pkt.type = 2		--ȡ��buf
	local tmp_t = collection_activity_loader.get_all_reward_buf(self.id, self.lvl)
	pkt.param = {}
	for k, v in pairs(tmp_t) do
		pkt.param[k] = {}
		pkt.param[k].type = k

	end 
	g_server_mgr:send_to_all_map(0, CMD_COLLECTION_ACTIVITY_BUF_C, pkt)
end
--���Ƶ��߹ر�ȫ��buf
function Collection_activity_item:deletel_map_buf(server_id)
	local pkt = {}
	pkt.type = 2		--ȡ��buf
	local tmp_t = collection_activity_loader.get_all_reward_buf(self.id, self.lvl)
	pkt.param = {}
	for k, v in pairs(tmp_t) do
		pkt.param[k] = {}
		pkt.param[k].type = k
	end 
	g_server_mgr:send_to_server(server_id, 0, CMD_COLLECTION_ACTIVITY_BUF_C, pkt)
end


-------------------------------------------------���̽ӿ�
function Collection_activity_item:spec_serialize_to_db()
	return self.items
end

