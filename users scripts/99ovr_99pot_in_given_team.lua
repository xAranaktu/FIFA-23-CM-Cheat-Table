--- HOW TO USE:
--- https://i.imgur.com/xZMqzTc.gifv
--- 1. Open Cheat table as usuall and enter your career.
--- 2. In Cheat Engine click on "Memory View" button.
--- 3. Press "CTRL + L" to open lua engine
--- 4. Then press "CTRL + O" and open this script
--- 5. Click on 'Execute' button to execute script and wait for 'done' message box.

--- AUTHOR: ARANAKTU

--- It may take a few mins. Cheat Engine will stop responding and it's normal behaviour. Wait until you get 'Done' message.


-- This script will change:
-- Potential to 99
-- Ovr to 99
-- All Attributess to 99
-- for given teamid


-- CHANGE TEAMID
local teamid = 0


-- Don't touch anything below

if teamid == 0 then
    local msg = "Change TEAMID!"
    showMessage(msg)
    assert(false, msg)
end

local playersEditorFormManager = require 'lua/GUI/forms/playerseditorform/manager';


gCTManager:init_ptrs()
local game_db_manager = gCTManager.game_db_manager
local memory_manager = gCTManager.memory_manager

local fields_to_change = {
    "potential",
    "overallrating",
    
    "gkdiving",
    "gkhandling",
    "gkkicking",
    "gkpositioning",
    "gkreflexes",
    "crossing",
    "finishing",
    "headingaccuracy",
    "shortpassing",
    "volleys",
    "defensiveawareness",
    "standingtackle",
    "slidingtackle",
    "dribbling",
    "curve",
    "freekickaccuracy",
    "longpassing",
    "ballcontrol",
    "shotpower",
    "jumping",
    "stamina",
    "strength",
    "longshots",
    "acceleration",
    "sprintspeed",
    "agility",
    "reactions",
    "balance",
    "aggression",
    "composure",
    "interceptions",
    "positioning",
    "vision",
    "penalties"
}

local playerids_in_team = get_playerids_for_team(teamid)
local pgs = get_players_in_player_growth_system()

local first_record = game_db_manager.tables["players"]["first_record"]
local record_size = game_db_manager.tables["players"]["record_size"]
local written_records = game_db_manager.tables["players"]["written_records"]

local row = 0
local current_addr = first_record
local last_byte = 0
local is_record_valid = true

local new_value = 99
while true do
    if row >= written_records then
        break
    end
    current_addr = first_record + (record_size*row)
    last_byte = readBytes(current_addr+record_size-1, 1, true)[1]
    is_record_valid = not (bAnd(last_byte, 128) > 0)
    if is_record_valid then
        local playerid = game_db_manager:get_table_record_field_value(current_addr, "players", "playerid")
        if playerid > 0 and can_edit_player(playerids_in_team, playerid) then
            for _, fld in ipairs(fields_to_change) do
                game_db_manager:set_table_record_field_value(current_addr, "players", fld, new_value)
                playersEditorFormManager:update_xp_in_player_growth_system(playerid, pgs[playerid], fld, new_value)
            end
        end
    end
    row = row + 1
end

showMessage("Done")
