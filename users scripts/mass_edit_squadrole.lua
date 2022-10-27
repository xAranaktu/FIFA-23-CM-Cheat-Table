--- HOW TO USE:
--- https://i.imgur.com/xZMqzTc.gifv
--- 1. Open Cheat table as usuall and enter your career.
--- 2. In Cheat Engine click on "Memory View" button.
--- 3. Press "CTRL + L" to open lua engine
--- 4. Then press "CTRL + O" and open this script
--- 5. Click on 'Execute' button to execute script and wait for 'done' message box.

--- AUTHOR: ARANAKTU

--- It may take a few mins. Cheat Engine will stop responding and it's normal behaviour. Wait until you get 'Done' message.

-- This script will change squadrole for all players that are in your club
-- 1: Crucial
-- 2: Important
-- 3: Rotation
-- 4: Sporadic
-- 5: Prospect

local squadrole = 3 -- Rotation

-- Don't touch anything below

gCTManager:init_ptrs()
local game_db_manager = gCTManager.game_db_manager
local memory_manager = gCTManager.memory_manager

local first_record = game_db_manager.tables["career_playercontract"]["first_record"]
local record_size = game_db_manager.tables["career_playercontract"]["record_size"]
local written_records = game_db_manager.tables["career_playercontract"]["written_records"]

local row = 0
local current_addr = first_record
local last_byte = 0
local is_record_valid = true

while true do
    if row >= written_records then
        break
    end
    current_addr = first_record + (record_size*row)
    last_byte = readBytes(current_addr+record_size-1, 1, true)[1]
    is_record_valid = not (bAnd(last_byte, 128) > 0)
    if is_record_valid then
        local contract_status = game_db_manager:get_table_record_field_value(current_addr, "career_playercontract", "contract_status")
        local is_loaned_in = contract_status == 1 or contract_status == 3 or contract_status == 5
        
        -- Ignore players that are loaned in
        if not is_loaned_in then
            local playerid = game_db_manager:get_table_record_field_value(current_addr, "career_playercontract", "playerid")
            if playerid > 0 then
                local squad_role_addr = get_squad_role_addr(playerid)
                if squad_role_addr > 0 then
                    writeInteger(squad_role_addr + PLAYERROLE_STRUCT["role"], squadrole)
                end
                game_db_manager:set_table_record_field_value(current_addr, "career_playercontract", "playerrole", squadrole)
            end
        end
    end
    row = row + 1
end

showMessage("Done")