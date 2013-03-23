--2012-8-8
--zhengyg
--activity_rank_mgr in common_server

local _rank_cfg = require("activity_rank.activity_rank_loader")
local _builder_list = create_local("activity_rank._builder_list", {})

ACTIVITY_RANK_TYPE = { --����ͬһ������ ͬһʱ��ֻ�ܴ���һ��
	RANK_CHARM = 1, --��������
	RANK_MAX = 1
}


function register_activity_rank_builder(type,cls)
	_builder_list[type] = cls
end

function get_activity_rank_builder(type)
	return _builder_list[type]
end

activity_rank_mgr = oo.class(nil,"activity_rank_mgr")

function activity_rank_mgr:__init()
	self.activity_list = {}
	--build rank obj
	for type = 1 ,  ACTIVITY_RANK_TYPE.RANK_MAX do
		self.activity_list[type] = get_activity_rank_builder(type)()
	end
end

function activity_rank_mgr:syn_map_config(server_id) --�㲥�����(��������)
	for type, activity_o in pairs(self.activity_list) do
		activity_o:syn_map_config(server_id)
	end
end

function activity_rank_mgr:get_click_param()
	return self, self.on_timer, 21, nil
end

function activity_rank_mgr:on_timer()
	self:do_timer()
end

function activity_rank_mgr:do_timer()
	for type, activity in pairs(self.activity_list) do
		activity:do_timer()
	end
	self:syn_map_config()
end

function activity_rank_mgr:get_click_serialized_param()
	return self, self.on_timer_serialize, 17*60, nil --��ʱ���汾Ҫ�ٵ�һ��ʱ��,����һ�� 
end

function activity_rank_mgr:on_timer_serialize()
	self:do_timer_serialize()
end

function activity_rank_mgr:do_timer_serialize()
	for type, activity in pairs(self.activity_list) do --�������͵Ļ���ݴ���
		activity:serialize()
	end
end

function activity_rank_mgr:on_app_exit()
	self:do_timer_serialize()
end

function activity_rank_mgr:syn_map_rank_data(server_id)
	for type, activity in pairs(self.activity_list) do
		if activity.turn_on then
			activity:syn_map_rank_data(server_id)
		end
	end
end

function activity_rank_mgr:update_rank_info(pkt)
	if self.activity_list[pkt.type].turn_on and self.activity_list[pkt.type].id == pkt.id then
		self.activity_list[pkt.type]:update_rank_info(pkt)
	else
		self:syn_map_config()
	end
end

--[[
���л���ݱ�ṹ

��һ��
activity_rank ���л�����Ϣ��
����: char_id:1
�ֶ� 
	char_id:
	activity_list:����ݱ��Ի����Ϊ��(������Ϊ1),
	ֵ:
		tm,��һ������ֵ�����ı��ʱ�� 
		charm����ڼ����ۼƵ�����ֵ
		today,�����һ���˳���Ϸ����Ŀ�ʼʱ�����f_get_today(ev.time)��
		today_charm,����������ۻ�ֵ
		id,�id
�Ϸ����ӷ�����ת��char_id��ֱ�ӿ�����������

���:
activity_rank_sum ���лͳ���ܱ�
���� type:1
�ֶ�:
	type:�������ͣ�1��ʾ�������л 2����
	id:	�id��
	reward:�����Ѿ������Ľ���id
	sort:���飬�ܰ�Ԫ�ؽṹ{char_id, cnt, timestamp}
	sort_pre:���飬���հ�ṹ{char_id, cnt, timestamp, day_begin_timestamp}
	sort_today:���飬���հ� �ṹ�����հ�һ��
	today:ʱ��� ����������ʱ�ж����ֵ���������հ�����հ������
�Ϸ������� type id reward today

--]]
