-- IF NEED HELP COME ON DISCORD


-------------------------------------------------------------------------------------------------------------------------------


--|| FILE : es_extended > server > classes > player.lua
-- Add ", gang" at the end 
function CreateExtendedPlayer(playerId, identifier, license, group, accounts, inventory, weight, job, loadout, name, coords, gang)

-- Add in function CreateExtendedPlayer ↓
self.gang = gang
Player(self.source).state:set("gang", self.gang, true)

---------

function self.getGang()
    return self.gang
end

function self.setGang(gang, grade)
    grade = tonumber(grade)
    local lastGang = json.decode(json.encode(self.gang))

    if exports['mgd_gangbuilder']:DoesGangExist(gang, grade) then
        local gangData = exports['mgd_gangbuilder']:GetGangData(gang)
        local gangGradeName = exports['mgd_gangbuilder']:GetGangGradeNameFromID(gang, grade)

        self.gang.name = gangData.name
        self.gang.label  = gangData.label

        self.gang.grade = grade
        self.gang.grade_name   = gangGradeName
        self.gang.grade_label  = gangData.grades[gangGradeName].label
        self.gang.grade_permissions = gangData.grades[gangGradeName].permissions

        TriggerEvent('esx:setGang', self.source, self.gang, lastGang)
        self.triggerEvent('esx:setGang', self.gang, lastGang)
        Player(self.source).state:set("gang", self.gang, true)
    else
        print(('[es_extended - mgd_gangbuilder] [^3WARNING^7] Ignoring invalid ^5.setGang()^7 usage for ID: ^5%s^7, Job: ^5%s^7'):format(self.source, gang))
    end
end

-------------------------------------------------------------------------------------------------------------------------------


--|| FILE : es_extended > server > functions.lua
-- Add data gang save
function Core.SavePlayer(xPlayer, cb)
    MySQL.prepare(
      'UPDATE `users` SET `accounts` = ?, `job` = ?, `job_grade` = ?, `gang`= ?, `gang_grade` = ?, `group` = ?, `position` = ?, `inventory` = ?, `loadout` = ? WHERE `identifier` = ?',
      {json.encode(xPlayer.getAccounts(true)), xPlayer.job.name, xPlayer.job.grade, xPlayer.gang.name, xPlayer.gang.grade, xPlayer.group, json.encode(xPlayer.getCoords()),
       json.encode(xPlayer.getInventory(true)), json.encode(xPlayer.getLoadout(true)), xPlayer.identifier}, function(affectedRows)
        if affectedRows == 1 then
          print(('[^2INFO^7] Saved player ^5"%s^7"'):format(xPlayer.name))
          TriggerEvent('esx:playerSaved', xPlayer.playerId, xPlayer)
        end
        if cb then
          cb()
        end
    end)
end
  
function Core.SavePlayers(cb)
    local xPlayers = ESX.GetExtendedPlayers()
    local count = #xPlayers
    if count > 0 then
        local parameters = {}
        local time = os.time()
        for i = 1, count do
        local xPlayer = xPlayers[i]
        parameters[#parameters + 1] = {json.encode(xPlayer.getAccounts(true)), xPlayer.job.name, xPlayer.job.grade, xPlayer.gang.name, xPlayer.gang.grade, xPlayer.group,
                                        json.encode(xPlayer.getCoords()), json.encode(xPlayer.getInventory(true)), json.encode(xPlayer.getLoadout(true)),
                                        xPlayer.identifier}
        end
        MySQL.prepare(
        "UPDATE `users` SET `accounts` = ?, `job` = ?, `job_grade` = ?, `gang` = ?, `gang_grade` = ?, `group` = ?, `position` = ?, `inventory` = ?, `loadout` = ? WHERE `identifier` = ?",
        parameters, function(results)
            if results then
            if type(cb) == 'function' then
                cb()
            else
                print(('[^2INFO^7] Saved ^5%s^7 %s over ^5%s^7 ms'):format(count, count > 1 and 'players' or 'player', ESX.Math.Round((os.time() - time) / 1000000, 2)))
            end
            end
        end)
    end
end


-------------------------------------------------------------------------------------------------------------------------------


--|| FILE : es_extended > server > main.lua
-- Add ", `gang`, `gang_grade`,"
local loadPlayer = 'SELECT `accounts`, `job`, `job_grade`, `gang`, `gang_grade`, `group`, `position`, `inventory`, `skin`, `loadout`'

-- Add in function loadESXPlayer ↓
-- Add ", gang = {}"
local userData = {accounts = {}, inventory = {}, job = {}, loadout = {}, playerName = GetPlayerName(playerId), weight = 0, gang = {}}

-- Add manage gang data to userData
-- Gang
if exports['mgd_gangbuilder']:DoesGangExist(gang, gangGrade)then
    local gangData = exports['mgd_gangbuilder']:GetGangData(gang)
    gangGradeName = exports['mgd_gangbuilder']:GetGangGradeNameFromID(gang, gangGrade)
    gangObject, gangGradeObject = gangData, gangData.grades[gangGradeName]
else
    print(('[^3WARNING^7] Ignoring invalid gang for ^5%s^7 [gang: ^5%s^7, grade: ^5%s^7]'):format(identifier, gang, gangGrade))
    gang, gangGrade = 'none', '0'
    local gangData = exports['mgd_gangbuilder']:GetGangData(gang)
    gangGradeName = exports['mgd_gangbuilder']:GetGangGradeNameFromID(gang, gangGrade)
    gangObject, gangGradeObject = gangData, gangData.grades[gangGradeName]
end

userData.gang.name = gangObject.name
userData.gang.label  = gangObject.label

userData.gang.grade = tonumber(gangGrade)
userData.gang.grade_name   = gangGradeObject.name
userData.gang.grade_label  = gangGradeObject.label
userData.gang.grade_permissions = gangGradeObject.permissions

-- Add ", userData.gang"
local xPlayer = CreateExtendedPlayer(playerId, identifier, license, userData.group, userData.accounts, userData.inventory, userData.weight, userData.job,
    userData.loadout, userData.playerName, userData.coords, userData.gang)

-- Add "gang = xPlayer.getGang(),"
xPlayer.triggerEvent('esx:playerLoaded',
{
    accounts = xPlayer.getAccounts(),
    coords = xPlayer.getCoords(),
    identifier = xPlayer.getIdentifier(),
    inventory = xPlayer.getInventory(),
    job = xPlayer.getJob(),
    gang = xPlayer.getGang(),
    loadout = xPlayer.getLoadout(),
    maxWeight = xPlayer.getMaxWeight(),
    money = xPlayer.getMoney(),
    sex = xPlayer.get("sex") or "m",
    firstName = xPlayer.get("firstName") or "John",
    lastName = xPlayer.get("lastName") or "Doe",
    dateofbirth = xPlayer.get("dateofbirth") or "01/01/2000",
    height = xPlayer.get("height") or 120,
    dead = false
}, isNew,
userData.skin)
-------------------------------------------------------------------------------------------------------------------------------


--|| FILE : es_extended > client > main.lua
-- Add this event
RegisterNetEvent('esx:setGang')
AddEventHandler('esx:setGang', function(gang)
	ESX.SetPlayerData('gang', gang)
end)


-------------------------------------------------------------------------------------------------------------------------------