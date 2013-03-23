--ͷ�ļ�
RETRIEVE_TYPE_DAILY			= 1			--�ճ�����
RETRIEVE_TYPE_SCENE			= 2			--ÿ�ո���
RETRIEVE_TYPE_SCENE_TYPE	= 3			--ÿ�����ͳ���


require("config.loader.retrieve_loader")
require("retrieve.retrieve_db")
require("retrieve.retrieve_mgr")
require("retrieve.retrieve_container")
require("retrieve.retrieve_process")

require("retrieve.retrieve.retrieve_base_include")
g_retrieve_mgr = Retrieve_mgr()

local function get_retrieve_info(char_id)
	local player = char_id and g_obj_mgr:get_obj(char_id)
	return player and player:get_retrieve_con()
end

--�������븱��
g_event_mgr:register_event(EVENT_SET.EVENT_ENTER_SCENE, get_retrieve_info, Retrieve_container.notify_enter_scene_event)

--������������¼�
g_event_mgr:register_event(EVENT_SET.EVENT_COMPLETE_QUEST, get_retrieve_info, Retrieve_container.notify_complete_quest_event)