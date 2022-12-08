--- HOW TO USE:
--- https://i.imgur.com/xZMqzTc.gifv
--- 1. Open Cheat table as usuall and enter your career.
--- 2. In Cheat Engine click on "Memory View" button.
--- 3. Press "CTRL + L" to open lua engine
--- 4. Then press "CTRL + O" and open this script
--- 5. Click on 'Execute' button to execute script and wait for 'done' message box.

--- AUTHOR: ARANAKTU

-- This script will automatically extend the contracts of all players, but not these in your team
-- 5 years by default

local extend_by = 5 -- 5 years

-- Don't touch anything below

local user_team_players = get_user_team_playerids()

function can_extend_cpu_player_contract(pids, pid)
    if pid <= 0 then return false end
    for i=1, #pids do
        if pid == pids[i] then return false end
    end
    return true
end

gCTManager:init_ptrs()
local game_db_manager = gCTManager.game_db_manager
local memory_manager = gCTManager.memory_manager

local first_record = game_db_manager.tables["players"]["first_record"]
local record_size = game_db_manager.tables["players"]["record_size"]
local written_records = game_db_manager.tables["players"]["written_records"]

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
        local playerid = game_db_manager:get_table_record_field_value(current_addr, "players", "playerid")
        if can_extend_cpu_player_contract(user_team_players, playerid) then
            local new_contractvaliduntil = game_db_manager:get_table_record_field_value(current_addr, "players", "contractvaliduntil") + extend_by

            if new_contractvaliduntil > 2047 then 
                new_contractvaliduntil = 2047 
            end

            game_db_manager:set_table_record_field_value(current_addr, "players", "contractvaliduntil", new_contractvaliduntil)
        end
    end
    row = row + 1
end

showMessage("Done")
