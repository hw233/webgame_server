local hidden_scene = {
	[MAP_INFO_1] = 50,
	[MAP_INFO_355] = 50
}   --ͬ������,���Ƶĵ�ͼ�Լ�����


Scene_entity = oo.class(Scene_entry, "Scene_entity")

function Scene_entity:__init(map_id, map_obj)
	Scene_entry.__init(self, map_id)
	self.map_obj = map_obj or g_scene_config_mgr:load_map(map_id)			-- ��ͼ����
	self.door_obj_mgr = Scene_obj_container()								-- �Ź����� ���������ã�
	self.obj_mgr = Scene_obj_mgr()											-- �������������� 
	self.key = {self.id}
	self.status = SCENE_STATUS.OPEN
end

-----------------------------------------------����ʵ����---------------------------------------------

function Scene_entity:instance()
	self.obj_mgr:instance(self.map_obj:get_w(), self.map_obj:get_h())
end

-----------------------------------------------��������-----------------------------------------------

function Scene_entity:get_human_count()
	return self.obj_mgr:get_obj_con(OBJ_TYPE_HUMAN):get_obj_count() + self.door_obj_mgr:get_obj_count()
end

function Scene_entity:get_key()
	return self.key
end

function Scene_entity:get_status()
	return self.status
end

function Scene_entity:get_status_info()
	return {self.id, self:get_name()
			, self.obj_mgr:get_obj_con(OBJ_TYPE_HUMAN):get_obj_count()
			, self:get_limit()
			, self:get_status()}
end

function Scene_entity:get_map_obj()
	return self.map_obj
end

function Scene_entity:is_validate_pos(pos)
	return pos[1] >= 0 and pos[1] < self.map_obj:get_w() and
		pos[2] >= 0 and pos[2] < self.map_obj:get_h()
end

function Scene_entity:can_use(item_id)
	return true
end

function Scene_entity:get_obj(obj_id)
	return self.obj_mgr:get_obj(obj_id)
end

-- ���һ�������Ƿ������������
function Scene_entity:find_obj(obj_id)
	local obj = self.obj_mgr:get_obj(obj_id)
	return obj and true or false
end

-- �����Ƿ��ܹ�����
function Scene_entity:can_carry(obj)
	return SCENE_ERROR.E_CARRY
end

function Scene_entity:get_last_time(obj)
	return nil
end

function Scene_entity:die_event(args)
end

function Scene_entity:get_count_copy(char_id)
	local obj = g_obj_mgr:get_obj(char_id)
	return obj:get_copy_con():get_count_copy(obj:get_map_id())
end
-----------------------------------------------�������----------------------------------------------
function Scene_entity:login_scene(obj, pos)
	if not pos or not self:is_validate_pos(pos) then
		local relive_config = g_scene_config_mgr:get_relive_config(self.id)
		if relive_config[1] == self.id then
			pos[1] = relive_config[2]
			pos[2] = relive_config[3]
		end
	end
	return self:push_scene(obj, pos)
end

function Scene_entity:carry_scene(obj, pos)
	local target_config = g_scene_config_mgr:get_config(self.id)
	if not target_config then
		return SCENE_ERROR.E_SCENE_CLOSE
	end
	
	if target_config.level > obj:get_level() then
		return SCENE_ERROR.E_LEVEL_DOWN
	end
	
	return self:push_scene(obj, pos)
end

-- ��һ���������볡����posλ��
function Scene_entity:push_scene(obj, pos)
	if not obj then
		return SCENE_ERROR.E_NOT_ON_SCENE
	end

	if not pos or not self:is_validate_pos(pos) then
		return SCENE_ERROR.E_INVALID_POS
	end
	
	local obj_id = obj:get_id()
	local old_scene = obj:get_scene_obj()
	
	if old_scene then
		old_scene:leave_scene(obj_id)
	end
	
	self:push_to_door(obj_id)
	obj:set_scene(self:get_key())
	obj:modify_pos(pos)
	obj:on_push_scene()
	
	return SCENE_ERROR.E_SUCCESS
end

-- ������볡��
function Scene_entity:enter_scene(obj)
	if not obj then
		return SCENE_ERROR.E_NOT_ON_SCENE
	end
	local obj_id = obj:get_id()
	local pos = obj:get_pos()
	
	self:pop_to_door(obj_id)
	self.obj_mgr:add_obj(obj)
	self.map_obj:on_obj_enter(obj_id, pos)
	
	obj:on_enter_scene()
	self:on_obj_enter(obj)
	
	self:send_screen_obj_show_em(obj_id)
	return SCENE_ERROR.E_SUCCESS 
end

function Scene_entity:leave_scene(obj_id)
	if self:is_door(obj_id) then		--������ֱ���뿪
		self:pop_to_door(obj_id)
		return SCENE_ERROR.E_SUCCESS
	end
	
	local obj = self:get_obj(obj_id)	--���ڳ�����
	if not obj then
		return SCENE_ERROR.E_NOT_ON_SCENE
	end
	
	obj:on_leave_scene()
	
	--�����㲥
	local new_pkt = {}
	new_pkt.obj_id = obj_id
	self:send_screen(obj_id, CMD_MAP_OBJ_LEAVE_SCREEN_SYN_S, new_pkt, 1)

	self.obj_mgr:del_obj(obj)
	self.map_obj:on_obj_leave(obj_id, obj:get_pos())
	self:on_obj_leave(obj)
	return SCENE_ERROR.E_SUCCESS
end

--��������ͨ��
function Scene_entity:push_to_door(obj_id)
	self.door_obj_mgr:push_obj(obj_id)
end

function Scene_entity:pop_to_door(obj_id)
	self.door_obj_mgr:pop_obj(obj_id)
end

function Scene_entity:is_door(obj_id)
	return self.door_obj_mgr:is_member(obj_id)
end

function Scene_entity:on_obj_enter(obj)
end

function Scene_entity:on_obj_leave(obj)
end

function Scene_entity:transport(obj, pos)
	local obj_id = obj:get_id()
	local old_pos = obj:get_pos()
	obj:modify_pos(pos)
	self:send_move_soon_syn(obj_id, obj, old_pos, pos, 1)
end

---------------------------------------------------�㲥ͬ��-------------------------------------------------

function Scene_entity:send_human(obj_id, cmd, pkt, is_encoded)
	g_cltsock_mgr:send_client(obj_id, cmd, pkt, is_encoded)
end

--��ȡ���󳡾���Ұ��Ϣ
function Scene_entity:get_scene_view(obj)
	local obj_id = obj:get_id()
	local pos = obj:get_pos()
	local obj_mgr = g_obj_mgr
	local map_o = self.map_obj
	local hidden_count = hidden_scene[self.id]
	
	local pkt = {}
	pkt.char_l = {}
	pkt.obj_l = {}
	
	local h_l = map_o:scan_screen_human(pos)
	if hidden_count then
		local count = 0
		for k, _ in pairs(h_l) do
			local o = obj_mgr:get_obj(k)
			if k ~= obj_id and o then     --------question
				table.insert(pkt.char_l, o:net_get_info())
				count = count + 1
				if hidden_count < count then
					break
				end
			end
		end
	else
		for k, _ in pairs(h_l) do
			local o = obj_mgr:get_obj(k)
			if k ~= obj_id and o then     --------question
				table.insert(pkt.char_l, o:net_get_info())
			end
		end
	end

	local m_l = map_o:scan_screen_monster(pos)
	for k, _ in pairs(m_l) do
		local o = obj_mgr:get_obj(k)
		if o then
			table.insert(pkt.obj_l, o:net_get_info())
		end
	end
	
	local box_l = map_o:scan_screen_box(pos)
	for k,v in pairs(box_l) do
		local o = obj_mgr:get_obj(k)
		if o then
			table.insert(pkt.obj_l, o:net_get_info())
		end
	end
	
	local npc_l = map_o:scan_screen_npc(pos)
	for k,v in pairs(npc_l) do
		local o = obj_mgr:get_obj(k)
		if o then
			table.insert(pkt.obj_l, o:net_get_info())
		end
	end
	
	local pet_l = map_o:scan_screen_pet(pos)
	for k,v in pairs(pet_l) do
		local o = obj_mgr:get_obj(k)
		if o then
			table.insert(pkt.obj_l, o:net_get_info())
		end
	end
	
	return pkt	
end

--˲��,�����ƶ���flagΪnil��1 ˲���ƶ���2 �����ƶ�; 3������
function Scene_entity:send_move_soon_syn(obj_id, obj, pos, des_pos, flag)
	self:on_obj_move(obj_id, obj, pos, des_pos)

	--��ҹ㲥��������
	local new_pkt = {}
	new_pkt.obj_id = obj_id
	new_pkt.x_end = des_pos[1]
	new_pkt.y_end = des_pos[2]
	if flag == nil or flag == 1 then
		self:send_screen(obj_id, CMD_MAP_PLAYER_MOVE_SOON_SYN_S, new_pkt, 1)
	elseif flag == 2 then
		self:send_screen(obj_id, CMD_MAP_OBJ_MOVE_RECEDE_SYN_S, new_pkt, 1)
	elseif flag == 3 then
		self:send_screen(obj_id, CMD_MAP_PET_LEAP_SYN, new_pkt, 1)
	end
	
	--������û�ı�zone������Ҫ�㲥
	local z_id_s = self.map_obj:pos_zone(pos)
	local z_id_d = self.map_obj:pos_zone(des_pos)
	if z_id_s ~= z_id_d then
		--�㲥human���������뿪��������
		self:send_screen_leave(obj_id, pos, des_pos)	
		--��������������㲥��human
		self:send_screen_obj_show(obj_id, pos, des_pos)
	end
end

--�����е�ͼʱ�����������
function Scene_entity:send_screen_obj_show_em(obj_id)
	local obj = self:get_obj(obj_id)
	if obj then
		local new_pkt = obj:net_get_info()
		self:send_screen(obj_id, CMD_MAP_OBJ_ENTER_SCREEN_SYN_S, new_pkt, nil, 1)
	end
end

--�㲥obj_id��Ϣ����������human, flag:nil ���㲥�Լ�
function Scene_entity:send_screen(obj_id, cmd, pkt, flag, type, isencode)
	local obj = g_obj_mgr:get_obj(obj_id)
	if not obj then
		return
	end
	
	local pos = obj:get_pos()
	if not pos then
		return
	end
	
	local owner_id = obj_id
	if OBJ_TYPE_PET == obj:get_type() and not type then
		owner_id = obj:get_owner_id()
	end
	
	local pkt_t = pkt
	if not isencode then
		pkt_t = Json.Encode(pkt or {})
	end
	
	local hidden_count = hidden_scene[self.id]
	if hidden then
		local z_id = obj:get_zone()		--�ȹ㲥zone�ڵ�
		local human_l = self.map_obj:scan_human_l(z_id)
		local c = 0
		if human_l then
			for o_id, _ in pairs(human_l) do
				if flag or o_id ~= owner_id then
					c = c + 1
					g_cltsock_mgr:send_client(o_id, cmd, pkt_t, true)
				end
			end
		end
	
		--�ܱ�8��zone
		local z_l = self.map_obj:scan_screen_zone(pos)
		for k,v in pairs(z_l) do
			if k ~= z_id then
				local human_l = self.map_obj:scan_human_l(k) or {}
				for o_id,_ in pairs(human_l) do
					if c >= hidden_count then
						return
					else
						if flag or o_id ~= owner_id then
							c = c + 1
							g_cltsock_mgr:send_client(o_id, cmd, pkt_t, true)
						end
					end
				end
			end
		end
	else
		local z_l = self.map_obj:scan_screen_zone(pos)
		for k,v in pairs(z_l) do
			local human_l = self.map_obj:scan_human_l(k)
			if human_l then
				for o_id,_ in pairs(human_l) do
					if flag or o_id ~= owner_id then
						g_cltsock_mgr:send_client(o_id, cmd, pkt_t, true)
					end
				end
			end
		end
	end
end

--��������ͬ��
function Scene_entity:send_move_syn(obj_id, obj, pos, des_pos, pkt, isencode)
	self:on_obj_move(obj_id, obj, pos, des_pos)
	--����㲥����������
	self:send_screen(obj_id, CMD_MAP_PLAYER_MOVE_SYN_S, pkt, nil, nil, isencode)
	--�������û�ı�zone������Ҫ�㲥
	local z_id_s = self.map_obj:pos_zone(pos)
	local z_id_d = self.map_obj:pos_zone(des_pos)

	if z_id_s ~= z_id_d then
		--�㲥human���������뿪��������
		self:send_screen_leave(obj_id, pos, des_pos)
		--��������������㲥��human
		self:send_screen_obj_show(obj_id, pos, des_pos)
	end
end

function Scene_entity:on_obj_move(obj_id, obj, pos, des_pos)
	self.map_obj:on_obj_move(obj_id, obj, pos, des_pos)
	self.obj_mgr:on_obj_move(obj_id, obj, pos, des_pos)  
end

--֪ͨhuman�������뿪��������
function Scene_entity:send_screen_leave(obj_id, cur_pos, des_pos)
	local z_l = self:get_map_obj():scan_far_zone(cur_pos, des_pos)
	local flag = Obj_mgr.obj_type(obj_id) == OBJ_TYPE_HUMAN and true or false

	local owner_id = obj_id
	local new_pkt = {}
	new_pkt.obj_id = obj_id
	new_pkt = Json.Encode(new_pkt or {})
	for k,v in pairs(z_l) do
		local pkt_l = {}

		local obj_l = self:get_map_obj():scan_obj_l(k)
		for o_id,_ in pairs(obj_l) do
			--�໥֪ͨ
			if Obj_mgr.obj_type(o_id) == OBJ_TYPE_HUMAN and o_id ~= owner_id then
				self:send_human(o_id, CMD_MAP_OBJ_LEAVE_SCREEN_SYN_S, new_pkt, true)
			end

			if flag and o_id ~= owner_id then
				local pkt = {["obj_id"]=o_id}
				g_cltsock_mgr:send_client(obj_id, CMD_MAP_OBJ_LEAVE_SCREEN_SYN_S, pkt)
			end
		end

		--�����,npc
		if flag then
			local obj_l = self:get_map_obj():scan_box_l(k)
			for o_id,_ in pairs(obj_l) do
				local pkt = {["obj_id"]=o_id}
				g_cltsock_mgr:send_client(obj_id, CMD_MAP_OBJ_LEAVE_SCREEN_SYN_S, pkt)
			end

			local obj_l = self:get_map_obj():scan_npc_l(k)
			for o_id,_ in pairs(obj_l) do
				local pkt = {["obj_id"]=o_id}
				g_cltsock_mgr:send_client(obj_id, CMD_MAP_OBJ_LEAVE_SCREEN_SYN_S, pkt)
			end
		end
	end
end

--�����ƶ��������˿�������
function Scene_entity:send_screen_obj_show(obj_id, cur_pos, des_pos)
	local obj_s = self:get_obj(obj_id)
	if not obj_s then
		local debug = Debug(g_debug_log)
		debug:trace("Scene_entity:send_screen_obj_show")
		return
	end
	local flag = Obj_mgr.obj_type(obj_id) == OBJ_TYPE_HUMAN and true or false

	local owner_id = obj_id
	local z_l = self:get_map_obj():scan_far_zone(des_pos, cur_pos)
	local new_pkt = obj_s:net_get_info()
	new_pkt = Json.Encode(new_pkt or {})
	for k,v in pairs(z_l) do
		local pkt_l = {}
		local count = 1

		local obj_l = self:get_map_obj():scan_obj_l(k)
		for o_id,_ in pairs(obj_l) do
			--�໥֪ͨ
			if Obj_mgr.obj_type(o_id) == OBJ_TYPE_HUMAN and o_id ~= owner_id then
				self:send_human(o_id, CMD_MAP_OBJ_ENTER_SCREEN_SYN_S, new_pkt, true)
			end

			local obj = self:get_obj(o_id)
			if obj and flag then
				--if Obj_mgr.obj_type(o_id) == OBJ_TYPE_MONSTER then
					local pkt = obj:net_get_info_str()
					g_cltsock_mgr:send_client(obj_id, CMD_MAP_OBJ_ENTER_SCREEN_SYN_S, pkt, true)
				--else
					--local pkt = obj:net_get_info()
					--g_cltsock_mgr:send_client(obj_id, CMD_MAP_OBJ_ENTER_SCREEN_SYN_S, pkt)
				--end
			end
		end

		if flag then
			--box
			local _l = self:get_map_obj():scan_box_l(k)
			for o_id,_ in pairs(_l) do
				local obj = self:get_obj(o_id)
				if obj then
					local pkt = obj:net_get_info_str()
					g_cltsock_mgr:send_client(obj_id, CMD_MAP_OBJ_ENTER_SCREEN_SYN_S, pkt, true)
				end
			end

			--npc
			local _l = self:get_map_obj():scan_npc_l(k)
			for o_id,_ in pairs(_l) do
				local obj = self:get_obj(o_id)
				if obj then
					local pkt = obj:net_get_info_str()
					g_cltsock_mgr:send_client(obj_id, CMD_MAP_OBJ_ENTER_SCREEN_SYN_S, pkt, true)
				end
			end
		end
	end
end

----------------------------------------------------------------------------------------------------
-- attcckter �Ƿ��ܹ��� defender
function Scene_entity:is_attack(attacker_id, defender_id)
	local scene_mode = g_scene_config_mgr:get_mode(self:get_mode())
	if not scene_mode then
		return SCENE_ERROR.E_INVALID_ID
	end
	
	local attacker = self:get_obj(attacker_id)
	if not attacker then
		return SCENE_ERROR.E_NOT_ON_SCENE
	end
	
	local defender = self:get_obj(defender_id)
	if not defender then
		return SCENE_ERROR.E_NOT_ON_SCENE
	end
	
	return scene_mode:can_attack(attacker, defender)
end

----------------------------------------------------------------------------------------------------

function Scene_entity:on_timer(tm)
	self.obj_mgr:on_timer(tm)
end

function Scene_entity:on_slow_timer(tm)
	self.obj_mgr:on_slow_timer(tm)
end

function Scene_entity:on_serialize_timer(tm)
	self.obj_mgr:on_serialize_timer(tm)
end
