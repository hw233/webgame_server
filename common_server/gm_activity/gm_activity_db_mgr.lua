--�������Ļ���û��ֱ���յ�GM��֪ͨ��������û�취�Զ�������ʼ����
--��������������ʱ�������ѯ�Ƿ��л


local database_fun = "gm_activity"  --��¼���Ϣ
Common_active_mgr = oo.class(nil, "common_active_mgr")

function Common_active_mgr:init()
end

function Common_active_mgr:load_active_info( type )
	local active_info = {}
	local dbh = f_get_db()
	local row,e_code = dbh:select(database_fun,nil,nil)
	local now = ev.time
	if row and e_code == 0 then
		--ֻ������Ч�(ÿ�α�ֻ֤����Ψһһ����Ч�Ļ)
		for _,v in pairs(row or {}) do
			if ev.time >= v.start_t and ev.time < v.end_t and v.type == type then 			
				if type == 3 then
					active_info = {}
					active_info.start_t = v.start_t
					active_info.end_t   = v.end_t
					active_info.type    = v.type
					active_info.id      = v.param.active_id or 1
					active_info.uuid    = v.id
					return active_info
				end
			end	
		end
	end
	return nil
end