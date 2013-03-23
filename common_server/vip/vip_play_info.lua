
local vip_config=require("vip.vip_info_load")
Vip_Play_Info = oo.class(nil, "Vip_Play_Info")

VIPATTR = {
["KILLMONSTER"] = "kill_mon",     			    --ɱ�ּӳ�
["SPRINT"] = "spring",          			    --����Ȫ
["OFFLINE"] = "off_exp",        				--����
["ESCORT"] = "escort",         				    --Ѻ��
["TRANSFER"] = "transfer",       			    --�����ƴ���
["CONSIGNMENT"] = "consignment",   			    --����
["SILVERBOX"] = "silver_box",        			--��������
["ULTIMATEXP"] = "ultima_exp",      		 	--����ǿ���������վ��齱��
["ULTIMATCON"] = "ultima_cont",    				--����ǿ���������հﹱ���� 
["INTENSIFY"] = "intensify",       				--ǿ��
["WARREWARD"] = "war_reward",                   --ս������	
["SPIRITPOLYMER"] = "spirit",                   --������
["FACTIONREWARD"] = "faction_reward",           --���ɽ���
["EXCADD"] = "exc_addition",					--ȫ�������Ŵ�
["DOUADD"] = "integral_addtition",				--ȫ��������ּӱ�
["JUMP"] = "jumplayer",							--��������
["JUMPADD"] = "jump_addition",    				--����ӳ�
["CHEST_ONE"] = "chest_one",					--VIP������
["CHEST_TWO"] = "chest_two",
["CHEST_THREE"] = "chest_three",
["PET_CULT"] = "pet_cult",						--���������ӳ�
["COPY_TIME"] = "copy_time",					--�����һ�ʱ��
["COPY_EXP"] = "copy_exp",						--��������ӳ�
["COLLECTIONS"] = "collections",				--VIP�ɼ�����
["FAIRIES_IMOLEST"] = "fairies_imolest",		--���� ��Ϸ����
["FAIRIES_PMOLEST"] = "fairies_pmolest",		--���� ����Ϸ����
["CHEST_FOUR"]  = "chest_four"
}    

function Vip_Play_Info:__init()
	self.vip_list = {}
	self:load_db()
end

function Vip_Play_Info:load_db()
	local db = f_get_db()
	local rows, e_code = db:select("vip_card")
	if 0 ~= e_code then
		return 
	end	
	for i,v in pairs(rows or {}) do
		for c,d in pairs(v) do
			if c == "char_id" then
				self.vip_list[d] = {}
				self.vip_list[d]["end_time"] = v["end_time"]
				self.vip_list[d]["card_type"] = v["card_type"]
			end	
		end
	end
end

function Vip_Play_Info:update_vip_list(char_id,endtime,cardtype)
	self.vip_list[char_id] = self.vip_list[char_id] or {}
	self.vip_list[char_id]["end_time"] = endtime
	self.vip_list[char_id]["card_type"] = cardtype
	self:send_inform(char_id, cardtype)
end

function Vip_Play_Info:get_vip_type(char_id)
	if self.vip_list[char_id] then
		if ev.time > self.vip_list[char_id]["end_time"] then
			self.vip_list[char_id]["card_type"] = 0
			return 0
		end
		return self.vip_list[char_id]["card_type"]	
	end
	return 0
end

function Vip_Play_Info:get_vip_field(char_id,fieldname)
	return vip_config.VipTable[self:get_vip_type(char_id)][fieldname]
end

function Vip_Play_Info:send_inform(char_id, cardtype)
		g_faction_mgr:vip_state_change(char_id, cardtype)  -- �������� ����
end