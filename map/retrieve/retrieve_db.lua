

Retrieve_db = oo.class(nil, "Retrieve_db")

local database = "retrieve"

--��������
function Retrieve_db:Select_retrieve(char_id)
	local db = f_get_db()

	local query = string.format("{char_id:%d}",char_id)

	local rows, e_code = db:select_one(database, nil, query)

	if 0 == e_code then
		return rows
	else
		print("Select_retrieve Error: ", e_code)
	end
	return nil
end

--��������
function Retrieve_db:update_all(record)
	local db = f_get_db()

	local data = {} 
	data.char_id = record.char_id
	data.update	 = record.update
	data.items	 = record.items

	local query = string.format("{char_id:%d}", record.char_id)

	db:update(database, query, Json.Encode(data), true, false)
end


--������Ŀ
function Retrieve_db:update_items(char_id, info)
	local m_db = f_get_db()
	local query = string.format("{char_id:%d}", char_id)
	local items = {["items"] = info}
	items = Json.Encode(items)

	m_db:update(database, query, items, true, false)
end

--����ʱ��
function Retrieve_db:update_time(char_id, update)
	local m_db = f_get_db()
	local query = string.format("{char_id:%d}", char_id)
	local time = {["update"] = update}
	time = Json.Encode(time)

	m_db:update(database, query, time, true, false)
end
