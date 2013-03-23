

----------------------------------------*******************************�����common��������ӿڣ��㲥�ȣ�
--BUF
Sv_commands[0][CMD_COLLECTION_ACTIVITY_BUF_C] = 
	function(conn, char_id, pkt)
		if not pkt then return end
		if pkt.type == 1 then
			for k, v in pairs(pkt.param) do
				g_buffer_reward_mgr:buffer_reward_start_ex(v)
			end

			if pkt.lvl then		--��Ҫ����lvl����
				g_activity_reward_mgr:reward_level_up(pkt.lvl)

				--���µ���
				g_activity_reward_mgr:change_statue(pkt.lvl)
			end
		elseif pkt.type == 2 then
			for k, v in pairs(pkt.param) do
				g_buffer_reward_mgr:buffer_reward_stop_ex(v.type)
			end
		end
	end


--�����
Sv_commands[0][CMD_COLLECTION_ACTIVITY_SWITCH_C] = 
	function(conn, char_id, pkt)
		if not pkt or not pkt.swicth then return end

		g_activity_reward_mgr:activity_swicth(pkt.swicth)
		return
	end

--��̨�֪ͨ 1 ���ѷ��� 2 ǿ������ 3 ����� 4 ���̻ 5 ׯ԰�䷽
Sv_commands[0][CMD_GM_ACTIVITY_NOTICE_C] = 
	function(conn, char_id, pkt)
		if not pkt or not pkt.type or not pkt.flags then return end

		if pkt.type == 1 then
			if pkt.flags == 1 then
				g_gm_function_con:load_gm_function_info(pkt.param and pkt.param.id)
			elseif pkt.flags == 2 then
				g_gm_function_con:clear_function_info(pkt.param and pkt.param.id)
			end
		elseif pkt.type == 2 then
			if pkt.flags == 1 then
				g_activity_goal_mgr:start_activity(pkt.param.id, pkt.param.start_t, pkt.param.end_t, pkt.param.param)
			elseif pkt.flags == 2 then
				g_activity_goal_mgr:close_activity()
			end
		elseif pkt.type == 3 then
			if pkt.flags == 1 then
				g_gm_function_con:open_long(pkt.param and pkt.param.id)
			elseif pkt.flags == 2 then
				g_gm_function_con:close_long(pkt.param and pkt.param.id)
			end
		elseif pkt.type == 4 then
			if pkt.flags == 1 then
				g_gm_function_con:load_active(pkt.param and pkt.param.id)
			elseif pkt.flags == 2 then
				g_gm_function_con:close_zillonaire_function_info(pkt.param and pkt.param.id)
			end
		elseif pkt.type == 5 then
			if pkt.flags == 1 then
				g_gm_function_con:add_home_peifang(pkt.param and pkt.param.param.list)
			elseif pkt.flags == 2 then
				g_gm_function_con:clear_home_peifang(pkt.param and pkt.param.param.list)
			end
		elseif pkt.type == 6 then
			if pkt.flags == 1 then
				g_achi_tree_mgr:show_activity_icon(pkt.param.start_t,pkt.param.end_t)
			elseif pkt.flags ==2 then
				g_achi_tree_mgr:hide_activity_icon()
			end
		elseif pkt.type == 7 then
			if pkt.flags == 1 then
				g_activity_rank_mgr:show_icon_turn_on()
			elseif pkt.flags == 2 then
				g_activity_rank_mgr:cancel_icon_turn_on()
			end
		end
		return
	end


--Ԫ�������ۼ�
Sv_commands[0][CMD_C2M_CONSUME_INFO] = 
	function(conn, char_id, pkt)
		if not pkt or not pkt.money then return end
		local obj = g_obj_mgr:get_obj(char_id)
		if obj then
			local fun_con = obj:get_gm_function_con()
			fun_con:add_integral(pkt.type, pkt.money)
		else
			print("error CMD_C2M_CONSUME_INFO", char_id, Json.Encode(pkt))
		end
	end

--����ȼ�֪ͨ
Sv_commands[0][CMD_NOTICE_WORLD_LEVEL_C] = 
	function(conn, char_id, pkt)
		if not pkt or not pkt.lvl then return end
		
		g_world_lvl_mgr:change_level(pkt.lvl)

		return
	end

