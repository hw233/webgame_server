
require("gm_activity/gm_activity_mgr")
require("gm_activity/gm_activity_process")
--g_activity_mgr = Gm_activity_mgr()

ACTIVITY_TYPE = {
	CONSUME				= 1, --���ѷ��ػ
	ACHIEVE_GOAL		= 2, --���Ŀ��
	ACHIEVE_LONG        = 3, --����
	ACHIEVE_ZILL        = 4, --����
	ACHIEVE_SEED        = 5, --�����䷽
	ACHIEVE_ACHI_TREE   = 6, --�ɾ����
	ACHIEVE_RANK		= 7, --���а�
	MAX					= 7,
}

require("gm_activity/gm_activity_item_achi_tree")
