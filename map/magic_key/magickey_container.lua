--2011-12-02
--cqs

--����������

MagicKey_container = oo.class(nil, "MagicKey_container")

local mk_loader = require("config.loader.magickey_loader")
local _sk = require("skill.skill_process")

local add_attr = {{[17] = 0.25, [18] = 0.25},
					{[21] = 0.25, [6] = 0.25},
					{[21] = 0.25, [3] = 0.25},
					{[21] = 0.25, [6] = 0.25},
					{[21] = 0.25, [3] = 0.25}
					}

local numbertostring = {[3] = "s_defense",
						[6] = "m_defense",
						[17] = "strengh",
						[18] = "intelligence",
						[21] = "hp"
						}
local element_cnt = 1

function MagicKey_container:__init(char_id)

	self.char_id = char_id
	local player = g_obj_mgr:get_obj(char_id)
	self.occ = player and player:get_occ() or 11
	--�������е�����ף��ֵ�����
	self.base = {}

	--���е�ǰ����,����, �����
	--for i = 1, 5 do
		--self.baselimit[i] = {1, 100}
	--end

	--������Ϣ�����
	self.magic_key = {}

	--������Ϣ�������
	self.mk_info = {}

	--���л���Ԫ����������
	self.base_attr = {} 
	self.base_attr_info = {}

	--����Ԫ�ظ�������
	self.append_attr = {}
	self.append_limit = 100
	self.append_total = 0

	--������������,����point��limitpoint��attr_l
	self.mk_append_attr = {}
	self.mk_total_attr = {}

	--ӵ�еļ���
	self.all_skill = {}

	--����ļ���
	self.activity_skill = {}

	--ÿ��������ӵ�еļ��ܼ���Ӧ�ȼ�.�����Ա�
	self.own_skill = {}

	--ӵ�еķ�����
	self.owner_mk = 0

	--���ܶ���ӿ�
	self.skill_l = {}
end

------------------------------------------------���ݿ��д-------------------------------------------
--���ط���ϵͳ��Ϣ
function MagicKey_container:load(first_login)
	if first_login then
		self.base = {}
		for i =1, 5 do
			self.base[i] = {0, 0}
		end
		--��ʼ��һ�ŷ���
		self.magic_key[1] = {}
		self.magic_key[1].benediction = 0
		if self.char_id ~= 0 then
			self:save()
		end
	else
		local row = MagicKey_db:Select_magickey(self.char_id)
		if row == nil then
			self.base = {}
			for i =1, 5 do
				self.base[i] = {0, 0}
			end

			self.magic_key[1] = {}
			self.magic_key[1].benediction = 0

			self:save()
		else
			self.base = row.base
			self.magic_key = row.magic_key
		end
	end

	self:calc_toplimit()
	self:update_base_attr()

	self:update_append_attr()
	self:load_all_skill()
	
	--������������
	self:init_mk_append_attr()

	self:calc_attr_info()

	return true
end

function MagicKey_container:level_up_init()
	self:load(true)
end

--��������ϵͳ���
function MagicKey_container:save(type)
	if type == 1 then
		self:update_on_time()
	else
		local data = self:get_all_info()
		MagicKey_db:update_all(data)
	end
	return true
end

--��������Ԫ�����
function MagicKey_container:update_base()
	MagicKey_db:update_base(self.char_id, self.base)

	return true
end

--�������
function MagicKey_container:update_magickey_item()

	MagicKey_db:update_magickey_item(self.char_id, self.magic_key)

	return true
end

--�����������
function MagicKey_container:update_magickey(point)
	if not self.magic_key[point] then
		return false
	end

	MagicKey_db:update_magickey(self.char_id, point, self.magic_key[point])

	return true
end

--��ʱ���
function MagicKey_container:update_on_time()
	if self.base_update then
		self:update_base()
	end

	if self.item_update then
		self:update_magickey_item()
	end

	self.base_update = nil
	self.item_update = nil

	return true
end

----------------------------------------mysql��̨��־----------


-------------------------------------***�ڲ��ӿ�***----------
function MagicKey_container:init_mk_append_attr()
	for j = 1, 8 do
		if self.magic_key[j].benediction then
			break
		end
		self.mk_append_attr[j] = {}
		local count = 0
		for i = 1, 5 do 
			count = count + self.magic_key[j].base[i]
		end
		self.mk_append_attr[j].point = count

		self.mk_append_attr[j].limitpoint, self.mk_append_attr[j].attr = mk_loader.get_mk_append_attr(j, count, self.occ)
	end

	for k, v in pairs(self.mk_append_attr) do
		for kk, vv in pairs(v.attr) do
			self.mk_total_attr[kk] = (self.mk_total_attr[kk] or 0) + vv
		end
	end
end

--��������
function MagicKey_container:calc_attr_info()
	for k, v in pairs(self.base_attr) do
		self.base_attr_info[k] = math.floor(v)
	end

	return true
end

--����������е�ǰ����������
function MagicKey_container:calc_toplimit(point, cnt)
	--���е�ǰ���������ޣ������
	self.baselimit = {}
	for i = 1, 5 do
		self.baselimit[i] = mk_loader.calc_toplimit(self.base[i][1])
	end

	return true
end

--�������������������
function MagicKey_container:update_base_attr()
	for i = 1, 5 do
		for k, v in pairs(add_attr[i]) do
			self.base_attr[k] = (self.base_attr[k] or 0) + v * self.base[i][1]
		end
	end

	return true
end

--���ӻ���������������
function MagicKey_container:add_base_attr(point, cnt)
	--���������б�
	for k, v in pairs(add_attr[point]) do
		self.base_attr[k] = (self.base_attr[k] or 0) + v * cnt
	end

	--֪ͨ�������
	if self.append_total + cnt >= self.append_limit then
		self:update_append_attr()
	else
		self.append_total = self.append_total + cnt
	end

	local player = g_obj_mgr:get_obj(self.char_id)

	self.base_update = 1

	self:calc_attr_info()

	player:on_update_attribute()

	return true
end

--���������������������
function MagicKey_container:update_append_attr()
	local cnt = 0
	for i = 1, 5 do
		cnt = cnt + self.base[i][1]
	end
	
	self.append_total = cnt
	self.append_limit, self.append_attr = mk_loader.get_append_attr(cnt)

	return true
end

--���㷨������������
function MagicKey_container:update_mk_append_attr(point)
	for k, v in pairs(self.mk_append_attr[point].attr) do
		self.mk_total_attr[k] = self.mk_total_attr[k] - v
	end

	self.mk_append_attr[point].limitpoint, self.mk_append_attr[point].attr = mk_loader.get_mk_append_attr(point, self.mk_append_attr[point].point, self.occ)

	
	for k, v in pairs(self.mk_append_attr[point].attr) do
		self.mk_total_attr[k] = (self.mk_total_attr[k] or 0) + v
	end

	return true
end

--��ʼ�����л�ü���
function MagicKey_container:load_all_skill()
	self.all_skill = {} 
	self.activity_skill = {}

	for i = 1, 8 do
		if not self.magic_key[i] or self.magic_key[i].benediction then
			self.owner_mk = i - 1
			break
		end
		self.own_skill[i] = mk_loader.get_mk_skill(self.magic_key[i].base, i, self.occ)

		local skill_id
		for k, v in pairs(self.own_skill[i]) do 
			table.insert(self.all_skill, k + v)
			skill_id = k + v
		end

		local tmp_id
		local tmp_lvl
		if not self.magic_key[i].skill then
			self.magic_key[i].skill = skill_id
			if skill_id then
				tmp_lvl = skill_id % 100
				tmp_id 	= skill_id - tmp_lvl
			end

		else
			tmp_lvl = self.magic_key[i].skill % 100
			tmp_id 	= self.magic_key[i].skill - tmp_lvl
			if not self.own_skill[i][tmp_id] then			--�����ò�������
				self.magic_key[i].skill = skill_id
				if skill_id then
					tmp_lvl = skill_id % 100
					tmp_id 	= skill_id - tmp_lvl
				else
					tmp_lvl = nil
					tmp_id 	= nil
				end
			else
				self.magic_key[i].skill = self.own_skill[i][tmp_id] + tmp_id
				tmp_lvl = self.own_skill[i][tmp_id]
			end
		end

		--�����츳����
		self.magic_key[i].innate_skill, self.magic_key[i].innate_lvl = mk_loader.get_mk_innate_skill(self.magic_key[i].base, i, self.occ)
		local innate_skill_id = self.magic_key[i].innate_skill + self.magic_key[i].innate_lvl
		table.insert(self.activity_skill, innate_skill_id)
		table.insert(self.all_skill, innate_skill_id)
		f_magic_skill_effect(self.char_id, innate_skill_id)
		--self.own_skill[i][self.magic_key[i].innate_skill] = self.magic_key[i].innate_lvl

		self.skill_l[self.magic_key[i].innate_skill] = {}
		self.skill_l[self.magic_key[i].innate_skill].skill_id = innate_skill_id
		self.skill_l[self.magic_key[i].innate_skill].cd		  = g_skill_mgr:create_cd(innate_skill_id, self.char_id)


		--�������
		if tmp_id then
			self.skill_l[tmp_id] = {}
			self.skill_l[tmp_id].skill_id = tmp_id + tmp_lvl
			self.skill_l[tmp_id].cd		  = g_skill_mgr:create_cd(tmp_id + tmp_lvl, self.char_id)

			self.magic_key[i].skill = tmp_id + tmp_lvl
			table.insert(self.activity_skill, tmp_id + tmp_lvl)
			f_magic_skill_effect(self.char_id, self.magic_key[i].skill)
		end
	end
	--for k, v in pairs(self.skill_l) do
		--print("300 =", k, j_e(v))
	--end

	return true
end

--���µ�����������������
function MagicKey_container:update_item_skill(point)
	--�Ƿ�ı�
	local flags = false
	--�Ƿ��������
	local tmp_flag = false

	local item_skill_l = mk_loader.get_mk_skill(self.magic_key[point].base, point, self.occ)

	local activity_skill
	if self.magic_key[point].skill then
		activity_skill = self.magic_key[point].skill - (self.magic_key[point].skill % 100)
	end

	for k, v in pairs(item_skill_l) do
		--�¼��ܣ�ֱ�Ӳ���
		if not self.own_skill[point][k] then
			flags = true
			table.insert(self.all_skill, k + v)
			self.own_skill[point][k] = v
			--��һ�����ܣ�Ĭ�ϼ���
			if not activity_skill then
				self.magic_key[point].skill = k + v
				table.insert(self.activity_skill, self.magic_key[point].skill)

				if f_magic_skill_effect(self.char_id, self.magic_key[point].skill) then
					local player = g_obj_mgr:get_obj(self.char_id)
					player:on_update_attribute()
				end

				self.skill_l[k] = {}
				self.skill_l[k].skill_id = self.magic_key[point].skill
				self.skill_l[k].cd		 = g_skill_mgr:create_cd(self.magic_key[point].skill, self.char_id)
			end
		else
			--�ɼ��ܣ�������
			if self.own_skill[point][k] ~= v then
				flags = true
				--����self.all_skill
				local old_skill_id = self.own_skill[point][k] + k
				local add_lvl = v - self.own_skill[point][k]

				for kk, skill_id in ipairs(self.all_skill) do
					if skill_id == old_skill_id then
						skill_id = skill_id + add_lvl
						break
					end
				end

				--����self.activity_skill
				if activity_skill and activity_skill == k then
					if f_magic_skill_ineffectiveness(self.char_id, self.magic_key[point].skill) then
						tmp_flag = true
					end

					self.magic_key[point].skill = self.magic_key[point].skill + add_lvl
					if f_magic_skill_effect(self.char_id, self.magic_key[point].skill) then
						tmp_flag = true
					end

					for kk, skill_id in ipairs(self.activity_skill) do
						if skill_id == old_skill_id then
							skill_id = skill_id + add_lvl
						end
					end

					self.skill_l[k].skill_id = self.magic_key[point].skill + add_lvl

				end
			end
		end
	end

	if flags then
		self.own_skill[point] = item_skill_l
	end

	--�����츳����
	local innate_skill, innate_lvl = mk_loader.get_mk_innate_skill(self.magic_key[point].base, point, self.occ)
	if self.magic_key[point].innate_lvl < innate_lvl then
		local innate_skill_id = innate_skill + innate_lvl
		local old_innate_skill = self.magic_key[point].innate_lvl + self.magic_key[point].innate_skill
		
		flags = true

		f_magic_skill_effect(self.char_id, innate_skill_id)
		if f_magic_skill_ineffectiveness(self.char_id, old_innate_skill) or tmp_flag then
			local player = g_obj_mgr:get_obj(self.char_id)
			player:on_update_attribute()
		end

		for i = 1, table.getn(self.activity_skill) do
			if self.activity_skill[i] == old_innate_skill then
				self.activity_skill[i] = innate_skill_id
				break
			end
		end
		for k, v in ipairs(self.all_skill) do
			if v == old_innate_skill then
				v = innate_skill
				break
			end
		end

		self.skill_l[innate_skill].skill_id = innate_skill_id
		self.magic_key[point].innate_lvl = innate_lvl
		--self.own_skill[point][innate_skill] = innate_lvl
	end

	return flags
end

--����ת��Ϊ�ַ�
function MagicKey_container:base_attr_to_net(attr_l)
	local changed_l = {}
	for k, v in pairs(attr_l) do
		if numbertostring[k] then
			changed_l[numbertostring[k]] = v
		end
	end

	return changed_l
end

--����Ԫ������
function MagicKey_container:levelup_base(number, info, add_rate, add_benediction)
	local flags = false

	if self.base[number][2] >= info.benediction_limit then
		flags = true
	else
		local value = crypto.random(1, 1001)
		if value - add_rate <= info.success_percent then
			flags = true
		end
	end

	if flags then
		self.base[number][1] = self.base[number][1] + 1
		self.baselimit[number] = mk_loader.calc_toplimit(self.base[number][1])

		self:add_base_attr(number, 1)

		self:base_element_tonet(1)

		--���׳ɹ����¼�֪ͨ
		local args = {}
		args.type = number
		args.level = self.baselimit[number][1]
		g_event_mgr:notify_event(EVENT_SET.EVENT_MAGICKEY_ITEM_LVL, self.char_id, args)
	else
		self.base[number][2] = self.base[number][2] + info.benediction + add_benediction

		self:base_element_tonet(2)
	end

	self.base_update = 1

	return
end

--�����
function MagicKey_container:activity_item(point, info)
	local flags = false
	if self.magic_key[point].benediction >= info.benediction_limit then
		flags = true
	else
		local value = crypto.random(1, 1001)
		if value <= info.success_percent then
			flags = true
		end
	end

	if flags then		--�����ɹ�
		self.magic_key[point].base = {}
		for i = 1, 5 do 
			self.magic_key[point].base[i] = 0
		end
		self.magic_key[point].benediction = nil

		if point ~= 8 then
			self.magic_key[point + 1] = {}
			self.magic_key[point + 1].benediction = 0
		end

		self.owner_mk = self.owner_mk + 1
		self.own_skill[point] = {}

		self.mk_append_attr[point] = {}
		self.mk_append_attr[point].point = 0
		self.mk_append_attr[point].limitpoint, self.mk_append_attr[point].attr = mk_loader.get_mk_append_attr(point, 0, self.occ)
		for k, v in pairs(self.mk_append_attr[point].attr) do
			self.mk_total_attr[k] = (self.mk_total_attr[k] or 0) + v
		end

		self.magic_key[point].innate_skill, self.magic_key[point].innate_lvl = mk_loader.get_mk_innate_skill(self.magic_key[point].base, point, self.occ)
		local innate_skill_id = self.magic_key[point].innate_skill + self.magic_key[point].innate_lvl
		table.insert(self.activity_skill, innate_skill_id)
		table.insert(self.all_skill, innate_skill_id)
		f_magic_skill_effect(self.char_id, innate_skill_id)
		--self.own_skill[point][self.magic_key[point].innate_skill] = self.magic_key[point].innate_lvl

		self.skill_l[self.magic_key[point].innate_skill] = {}
		self.skill_l[self.magic_key[point].innate_skill].skill_id = innate_skill_id
		self.skill_l[self.magic_key[point].innate_skill].cd		  = g_skill_mgr:create_cd(innate_skill_id, self.char_id)

		self:opened_item_base_tonet(point, 1)

		_sk.get_list(self.char_id, self.char_id)
	else
		self.magic_key[point].benediction = self.magic_key[point].benediction + info.benediction

		self:closed_item_tonet(point, 2)
	end

	self.item_update = 1

	return
end

--����ע��Ԫ��
function MagicKey_container:inject_item(point, element, count)
	local limit = 50 - (self.magic_key[point].base[element] % 50)
	local add = element_cnt * count
	self.magic_key[point].base[element] = self.magic_key[point].base[element] + add
	self.mk_append_attr[point].point = self.mk_append_attr[point].point + add
	--��50��ˢ�¼���
	if add >= limit then
		if self:update_item_skill(point) then		--�����и���
			self:opened_item_tonet(point)
			self:all_base_tonet()

			_sk.get_list(self.char_id, self.char_id)
		else
			self:opened_item_base_tonet(point, 2)
		end
	else
		self:opened_item_base_tonet(point, 2)
	end

	self.item_update = 1

	--���������������ޣ�ˢ����
	if self.mk_append_attr[point].point >= self.mk_append_attr[point].limitpoint then
		self:update_mk_append_attr(point)
		local player = g_obj_mgr:get_obj(self.char_id)
		player:on_update_attribute()
	end

	--����ע��Ԫ���¼�֪ͨ
	local args = {}
	args.type = self.mk_append_attr[point].point
	args.count = self.baselimit[element][1]
	g_event_mgr:notify_event(EVENT_SET.EVENT_MAGICKEY_INJECT, self.char_id, args)

	return true
end

--�л�����
function MagicKey_container:change_item_skill(point, skill)
	local skill_id = self.own_skill[point][skill] + skill

	local old_id = self.magic_key[point].skill

	local flags = false
	if f_magic_skill_ineffectiveness(self.char_id, self.magic_key[point].skill) then
		flags = true
	end
	if f_magic_skill_effect(self.char_id, skill_id) then
		flags = true
	end

	self.skill_l[self.magic_key[point].skill - (self.magic_key[point].skill % 100)] = nil

	for i = 1, table.getn(self.activity_skill) do
		if self.activity_skill[i] == self.magic_key[point].skill then
			self.activity_skill[i] = skill_id
			break
		end
	end

	self.magic_key[point].skill = skill_id

	self.skill_l[skill] = {}
	self.skill_l[skill].skill_id = skill_id
	self.skill_l[skill].cd		 = g_skill_mgr:create_cd(skill_id, self.char_id) 

	self.mk_info[point] = ev.time + 60
	--����
	if flags then
		local player = g_obj_mgr:get_obj(self.char_id)
		player:on_update_attribute()
	end
	self:opened_item_tonet(point)
	self:all_base_tonet()

	local skill_o = g_skill_mgr:get_skill(old_id)
	if skill_o ~= nil and skill_o:get_type() == SKILL_MAGIC_USE then
		local player = g_obj_mgr:get_obj(self.char_id)
		if not player then return end

		local action_con = player:get_action_con()
		action_con:delete_skill_shortcut(skill_o.cmd_id)
	end

	_sk.get_list(self.char_id, self.char_id)
	return true
end

-------------------------------------***�ⲿ�ӿ�***----------
--ע�뷨����������
function MagicKey_container:add_base_element(element, cnt)
	if element > 5 or element < 1 then
		return 22671
	end

	--�ж������ܷ�ӣ����ܷ��ش�����
	if self.base[element][1] + cnt > self.baselimit[element][2] then
		return 22672
	else
		self.base[element][1] = self.base[element][1] + cnt

		self:add_base_attr(element, cnt)

		self:base_element_tonet(3)
		return 0
	end
end

--��ȡ����ϵͳ���ӵ�����ֵ
function MagicKey_container:get_magickey_attr()
	return self.base_attr_info, self.append_attr, self.mk_total_attr
end

--��ȡ���н���
function MagicKey_container:get_base_lvl_by_index(index)
	return self.baselimit[index] and self.baselimit[index][1]
end

--��ȡ������ע����
function MagicKey_container:get_injectivity_by_index(index)
	local tmp_total = 0
	if self.magic_key[index] and self.magic_key[index].base then
		for i = 1, 5 do 
			tmp_total = tmp_total + self.magic_key[index].base[i]
		end
	end
	return tmp_total
end

--�ⲿ��ȡ����
function MagicKey_container:get_skill_l()
	return self.skill_l
end

--תְ
function MagicKey_container:change_occ(occ)
	local old_occ = self.occ
	self.occ = occ

	for i = 1, 8 do
		if not self.magic_key[i] or self.magic_key[i].benediction then
			break
		end

		if i == 3 or i == 8 then
			local old_no = mk_loader.get_no_element(i, old_occ)
			local new_no = mk_loader.get_no_element(i, self.occ)

			self.magic_key[i].base[old_no] = self.magic_key[i].base[new_no]
			self.magic_key[i].base[new_no] = 0
		end
	end
end

--�������
function MagicKey_container:get_all_info()
	local data = {} 
	data.char_id = self.char_id
	data.base 	= self.base
	data.magic_key = self.magic_key

	return data
end

--���ﾺ������
function MagicKey_container:get_initiative_skill()
	local data = {} 
	for i = 1, 8 do
		if not self.magic_key[i] or self.magic_key[i].benediction then
			break
		else
			local skill_o = g_skill_mgr:get_skill(self.magic_key[i].skill)
			if skill_o and skill_o:get_type() ~= SKILL_MAGIC_ATTRIBUTE then
				table.insert(data, self.magic_key[i].skill)
			end
		end
	end

	return data
end

----------------------------------------��ͻ��˽���-------
function MagicKey_container:send_error(cmd, err)
	local new_pkt = {}
	new_pkt.result = err
	g_cltsock_mgr:send_client(self.char_id, cmd, new_pkt)
end

--���ͻ�����Ϣ
function MagicKey_container:all_base_tonet(flags)
	local pkt = {}
	pkt.magickey = self.owner_mk

	pkt.element_l = {}
	for i = 1, 5 do
		pkt.element_l[i] = {}
		pkt.element_l[i][1] = self.base[i][1]
		pkt.element_l[i][2] = self.baselimit[i][1]
		pkt.element_l[i][3] = self.base[i][2]
	end

	pkt.attr_l = self:base_attr_to_net(self.base_attr_info)

	pkt.activity_skill = self.activity_skill

	pkt.all_skill = self.all_skill

	if flags then
		return pkt
	else
		g_cltsock_mgr:send_client(self.char_id, CMD_MAGICKEY_OPEN_BASE_S, pkt)
		return
	end
end

--���ͻ���Ԫ����Ϣ
function MagicKey_container:base_element_tonet(type, flags)
	local pkt = {}
	pkt.result = 0
	pkt.type = type

	pkt.element_l = {}
	for i = 1, 5 do
		pkt.element_l[i] = {}
		pkt.element_l[i][1] = self.base[i][1]
		pkt.element_l[i][2] = self.baselimit[i][1]
		pkt.element_l[i][3] = self.base[i][2]
	end

	pkt.attr_l = self:base_attr_to_net(self.base_attr_info)

	if flags then
		return pkt
	else
		g_cltsock_mgr:send_client(self.char_id, CMD_MAGICKEY_LVLUP_BASE_S, pkt)
		return
	end
end

--����Ԫ������
function MagicKey_container:levelup_base_tonet(number, add_cnt)
	local pkt = {}
	pkt.result = 0
	pkt.type = type

	if self.base[number][1] < self.baselimit[number][2] then
		self:send_error(CMD_MAGICKEY_LVLUP_BASE_S, 22674)
		return
	end

	if 8 <= self.baselimit[number][1] then
		self:send_error(CMD_MAGICKEY_LVLUP_BASE_S, 22675)
		return
	end

	local req_info = mk_loader.get_base_lvlup_info(self.baselimit[number][1])

	local player = g_obj_mgr:get_obj(self.char_id)
	if not player then return end
	local pack_con = player:get_pack_con()

	--�ȼ�
	if player:get_level() < req_info.req_lvl then
		self:send_error(CMD_MAGICKEY_LVLUP_BASE_S, 22676)
		return
	end

	--��Ʒ
	local item_id = req_info.req_item + (number - 1) * 100
	if pack_con:check_item_lock_by_item_id(item_id) then
		return
	end
	if pack_con:get_all_item_count(item_id) < req_info.req_item_cnt then
		self:send_error(CMD_MAGICKEY_LVLUP_BASE_S, 22677)
		return
	end

	local add_item_id = 0
	local add_rate = 0
	local add_benediction = 0
	if add_cnt > 0 then
		if 5 > self.baselimit[number][1] then
			self:send_error(CMD_MAGICKEY_LVLUP_BASE_S, 22693)
			return
		end

		add_item_id = req_info.add_Item
		if pack_con:get_all_item_count(add_item_id) < add_cnt then
			self:send_error(CMD_MAGICKEY_LVLUP_BASE_S, 22692)
			return
		end

		add_rate = (req_info.add_rate or 0) * add_cnt

		if add_cnt >= 4 then
			add_rate = add_rate + 10
			add_benediction = add_benediction + req_info.add_benediction
		end
	end

	--����
	local money_list = {}
	money_list[MoneyType.GIFT_GOLD] = req_info.gold
	pkt.result = pack_con:dec_money_l_inter_face(money_list, {['type']=MONEY_SOURCE.MK_LEVELUP_BASE}, 1)
	if pkt.result ~= 0 then
		self:send_error(CMD_MAGICKEY_LVLUP_BASE_S, pkt.result)
		return
	end

	pack_con:del_item_by_item_id_bind_first(item_id, req_info.req_item_cnt, {['type']=ITEM_SOURCE.MK_LEVELUP_BASE})
	if add_cnt > 0 then
		pack_con:del_item_by_item_id_bind_first(add_item_id, add_cnt, {['type']=ITEM_SOURCE.MK_ADD_RATE})
	end

	--��������
	self:levelup_base(number, req_info, add_rate, add_benediction)

	--if flags then
		--return pkt
	--else
		--g_cltsock_mgr:send_client(self.char_id, CMD_MAGICKEY_LVLUP_BASE_S, pkt)
		--return
	--end
end

--����δ�򿪷�����Ϣ
function MagicKey_container:closed_item_tonet(point, type)
	local pkt = {}
	pkt.result = 0
	pkt.point = point
	pkt.type = type
	pkt.benediction = self.magic_key[point].benediction

	g_cltsock_mgr:send_client(self.char_id, CMD_MAGICKEY_OPEN_ITEM_S, pkt)

end

--�����Ѵ򿪷�����Ϣ
function MagicKey_container:opened_item_tonet(point)
	local pkt = {}
	pkt.result = 0
	pkt.point = point
	
	pkt.element_l = {}
	for i = 1, 5 do 
		pkt.element_l[i] = { self.magic_key[point].base[i], 0}
	end

	pkt.skill_l = {}
	pkt.skill_l[1] = self.magic_key[point].innate_lvl + self.magic_key[point].innate_skill
	if self.magic_key[point].skill then
		table.insert(pkt.skill_l, self.magic_key[point].skill)
		local skill_id = self.magic_key[point].skill - (self.magic_key[point].skill % 100)
		for k, v in pairs(self.own_skill[point]) do
			if k ~= skill_id then
				table.insert(pkt.skill_l, k + v)
			end
		end
	end

	g_cltsock_mgr:send_client(self.char_id, CMD_MAGICKEY_OPEN_ITEM_S, pkt)

end

--�����Ѵ򿪷���������Ϣ,�޼���
function MagicKey_container:opened_item_base_tonet(point, type)
	local pkt = {}
	pkt.result = 0
	pkt.point = point
	pkt.type = type

	pkt.element_l = {}
	for i = 1, 5 do 
		pkt.element_l[i] = { self.magic_key[point].base[i], 0}
	end

	pkt.skill_l = {}
	pkt.skill_l[1] = self.magic_key[point].innate_lvl + self.magic_key[point].innate_skill
	if self.magic_key[point].skill then
		table.insert(pkt.skill_l, self.magic_key[point].skill)
		local skill_id = self.magic_key[point].skill - (self.magic_key[point].skill % 100)
		for k, v in pairs(self.own_skill[point]) do
			if k ~= skill_id then
				table.insert(pkt.skill_l, k + v)
			end
		end
	end

	g_cltsock_mgr:send_client(self.char_id, CMD_MAGICKEY_ITEM_ACTIVITY_S, pkt)

	self:all_base_tonet()
end

--�鿴����
function MagicKey_container:open_item_base_tonet(point)
	local pkt = {}
	pkt.result = 0
	pkt.type = type

	if not self.magic_key[point] then
		self:send_error(CMD_MAGICKEY_OPEN_ITEM_S, 22681)
		return
	end

	--�Ѽ���ķ���
	if not self.magic_key[point].benediction then
		self:opened_item_tonet(point)
		return
	else						--δ����ķ���
		self:closed_item_tonet(point, 1)
		return
	end
end

--�����
function MagicKey_container:activity_item_tonet(point)
	local pkt = {}
	pkt.result = 0
	pkt.type = type

	if not self.magic_key[point] then
		self:send_error(CMD_MAGICKEY_ITEM_ACTIVITY_S, 22681)
		return
	end

	--�Ѽ���ķ���
	if not self.magic_key[point].benediction then
		self:send_error(CMD_MAGICKEY_ITEM_ACTIVITY_S, 22682)
		return
	end						
		
	local req_info = mk_loader.get_item_lvlup_info(point)

	local player = g_obj_mgr:get_obj(self.char_id)
	if not player then return end
	local pack_con = player:get_pack_con()

	--�ȼ�
	if player:get_level() < req_info.level then
		self:send_error(CMD_MAGICKEY_ITEM_ACTIVITY_S, 22680)
		return
	end

	--��Ԫ���Ƿ���
	if (req_info.element_g and req_info.element_g > self.base[1][1]) or
		(req_info.element_m and req_info.element_m > self.base[2][1]) or
		(req_info.element_w and req_info.element_w > self.base[3][1]) or
		(req_info.element_f and req_info.element_f > self.base[4][1]) or
		(req_info.element_e and req_info.element_e > self.base[5][1]) then

		self:send_error(CMD_MAGICKEY_ITEM_ACTIVITY_S, 22683)
		return
	end

	--��Ʒ
	local item_id = req_info.req_item
	if pack_con:check_item_lock_by_item_id(item_id) then
		return
	end
	if pack_con:get_all_item_count(item_id) < req_info.req_item_cnt then
		self:send_error(CMD_MAGICKEY_ITEM_ACTIVITY_S, 22677)
		return
	end
	pack_con:del_item_by_item_id_bind_first(item_id, req_info.req_item_cnt, {['type']=ITEM_SOURCE.MK_ACTIVITY_ITEM})

	--���м���
	self:activity_item(point, req_info)

	return
end

--ע�뷨��Ԫ��
function MagicKey_container:inject_item_tonet(point, element, count)
	local cnt = count 
	--δ����
	if not self.magic_key[point] or self.magic_key[point].benediction then
		self:send_error(CMD_MAGICKEY_ITEM_INJECT_S, 22684)
		return
	end					
	
	--û�и�Ԫ��
	if not mk_loader.check_item_element(self.occ, point, element) then
		self:send_error(CMD_MAGICKEY_ITEM_INJECT_S, 22686)
		return
	end

	--�Ѵ����ֵ
	
	if self.magic_key[point].base[element] + element_cnt * cnt > self.baselimit[element][2] then
		self:send_error(CMD_MAGICKEY_ITEM_INJECT_S, 22685)
		return
	end
	--if self.magic_key[point].base[element] >= self.baselimit[element][2] then
		--self:send_error(CMD_MAGICKEY_ITEM_INJECT_S, 22685)
		--return
	--end

	local player = g_obj_mgr:get_obj(self.char_id)
	if not player then return end
	local pack_con = player:get_pack_con()
	
	--��Ʒ
	local item_id = 157000000021 + (element - 1) * 100
	if pack_con:check_item_lock_by_item_id(item_id) then
		return
	end
	if pack_con:get_all_item_count(item_id) < cnt then
		self:send_error(CMD_MAGICKEY_ITEM_INJECT_S, 22677)
		return
	end
	pack_con:del_item_by_item_id_bind_first(item_id, cnt, {['type']=ITEM_SOURCE.MK_INJECT_ELEMENT})

	--����ע��
	self:inject_item(point, element, cnt)

	return
end

--�����
function MagicKey_container:activity_skill_net(point, skill_id)
	--δ�����
	if not self.magic_key[point] or self.magic_key[point].benediction then
		self:send_error(CMD_MAGICKEY_ACTIVITY_SKILL_S, 22687)
		return
	end					
	
	--�����Ѽ���
	if self.magic_key[point].skill == skill_id then
		self:send_error(CMD_MAGICKEY_ACTIVITY_SKILL_S, 22688)
		return
	end

	--û�иü���
	local skill_lvl = skill_id % 100
	local skill = skill_id - skill_lvl
	if not self.own_skill[point][skill] then
		self:send_error(CMD_MAGICKEY_ACTIVITY_SKILL_S, 22687)
		return
	end

	--�л�CD��
	if self.mk_info[point] and self.mk_info[point] > ev.time then
		self:send_error(CMD_MAGICKEY_ACTIVITY_SKILL_S, 22689)
		return
	end

	--�����л�
	self:change_item_skill(point, skill)

	return
end


--ע������Ԫ��
function MagicKey_container:inject_base_tonet(element, count)
	local cnt = count

	if self.base[element][1] + cnt > self.baselimit[element][2] then
		self:send_error(CMD_MAGICKEY_INJECT_S, 22672)
		return
	end

	local player = g_obj_mgr:get_obj(self.char_id)
	if not player then return end
	local pack_con = player:get_pack_con()
	
	--��Ʒ
	local item_id = 157000000021 + (element - 1) * 100
	if pack_con:check_item_lock_by_item_id(item_id) then
		return
	end
	if pack_con:get_all_item_count(item_id) < cnt then
		self:send_error(CMD_MAGICKEY_ITEM_INJECT_S, 22691)
		return
	end
	pack_con:del_item_by_item_id_bind_first(item_id, cnt, {['type']=ITEM_SOURCE.MK_INJECT_BASE})

	--����ע��
	self:add_base_element(element, cnt)

	return
end



--
--function test_activity_item(point, count)
	--print("activity_item times =", count)
	--local info = mk_loader.get_item_lvlup_info(point)
	--local i = 0
	--for k = 1, count do
		--local value = crypto.random(1, 1001)
		--if value <= info.success_percent then
			--i = i + 1
		--end
	--end
--
	--print("success time =", i)
	--return
--end

--function test_levelup_base(number, count)
	--print("levelup_base times =", count)
	--local info = mk_loader.get_base_lvlup_info(number)
	--local i = 0
	--for k = 1, count do
		--local value = crypto.random(1, 1001)
		--if value <= info.success_percent then
			--i = i + 1
		--end
	--end
--
	--print("success time =", i)
--
	--return
--end
--
----��������� ���ŷ���	 	���Դ���
--test_activity_item(3, 10000)
----���ײ���		������		���Դ���
--test_levelup_base(2, 10000)