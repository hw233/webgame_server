

Human_vedio = oo.class(nil, "Human_vedio")

function Human_vedio:__init(type)
	self.vedio_id = crypto.uuid()

	self.start_time = ev.time

	--1 Ϊ������
	self.type = type

	self.char_id_s = nil
	self.char_id_d = nil

	--�ֱ��ķ�Ӯ�� 1Ϊ ��ս��Ӯ��2Ϊ����ս��Ӯ
	self.win_flag = 1

	self.vedio_list = {}

end

function Human_vedio:set_vedio_list(index,value)
	table.insert(self.vedio_list[index], value)
end

function Human_vedio:get_vedio_list()
	return self.vedio_list
end

function Human_vedio:set_vedio_list_ex(list)
	self.vedio_list = list
end

function Human_vedio:get_id()
	return self.vedio_id
end

function Human_vedio:get_type()
	return self.type
end

function Vedio:get_start_time()
	return self.start_time
end

function Human_vedio:get_win_flag()
	return self.win_flag
end

function Human_vedio:set_win_flag(flag)
	self.win_flag = flag
end

function Human_vedio:set_char_id_s(winner)
	self.char_id_s = winner
end

function Human_vedio:get_char_id_s()
	return self.char_id_s
end

function Human_vedio:set_char_id_d(loser)
	self.char_id_d = loser
end

function Human_vedio:get_char_id_d()
	return self.char_id_d
end

function Human_vedio:get_net_info()
	local ret = {}
	ret[1] = self.start_time
	ret[2] = g_player_mgr.all_player_l[self.char_id_s].char_nm
	ret[3] = g_player_mgr.all_player_l[self.char_id_d].char_nm
	ret[4] = self.win_flag
	ret[5] = self.vedio_id

	return ret
end

function Human_vedio:seralize_to_db()
	local ret = {}
	ret.type = self.type
	ret.start_time = self.start_time
	ret.char_id_s = self.char_id_s
	ret.char_id_d = self.char_id_d
	ret.win_flag = self.win_flag
	ret.vedio_id = self.vedio_id
	ret.vedio_list = self.vedio_list

	return ret
end