local UPDATEPERIOD, elapsed = 0.5, 0
local DraiksBrokerDB = LibStub("AceAddon-3.0"):NewAddon("DraiksBrokerDB", "AceEvent-3.0", "AceTimer-3.0")
local class, classFileName = UnitClass("player");
local f = CreateFrame("frame")
local name = GetUnitName("player", false);
local iLevel = GetAverageItemLevel()
local tname
local tunit
f:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded
f:RegisterEvent("PLAYER_LOGOUT"); -- Fired when about to log out
f:RegisterEvent("CHAT_MSG_ADDON")
local messagePrefix = "DRAIKSBROKERILVL" 
RegisterAddonMessagePrefix(messagePrefix)
--------------------------------------
-- LDB Libs Here
--------------------------------------
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local L = LibStub("AceLocale-3.0"):GetLocale("DraiksBrokerDB")
--------------------------------------
-- ACE Libs Here
--------------------------------------
local LibQTip = LibStub('LibQTip-1.0')
local dataobj = ldb:NewDataObject(L["Draiks Broker ILevel"], {type = "data source", text = "ilvl: 200"})
local LibSharedMedia = LibStub('LibSharedMedia-3.0')
--------------------------------------
-- Font Configs
--------------------------------------

local baseFont = CreateFont("baseFont")

-- CHeck for ElvUI
if LibSharedMedia:IsValid('font', ElvUI[1].db.general.font) then
    baseFont:SetFont(LibSharedMedia:Fetch('font', ElvUI[1].db.general.font), 10)
else
	baseFont:SetFont(GameTooltipText:GetFont(), 10)
end

-- Setup Display Fonts
-- New font looking like GameTooltipText but White with height 12
local white10Font = CreateFont("white10Font")
white10Font:CopyFontObject(baseFont)
white10Font:SetTextColor(1,1,1)
 
-- New font looking like White15font but with height 14
local white14Font = CreateFont("white14Font")
white14Font:CopyFontObject(baseFont)
white14Font:SetFont(baseFont:GetFont(), 14)
 
local hordeFont = CreateFont("hordeFont")
hordeFont:CopyFontObject(baseFont)
hordeFont:SetTextColor(1,0,0)
hordeFont:SetFont(hordeFont:GetFont(), 14)
 
local allianceFont = CreateFont("allianceFont")
allianceFont:CopyFontObject(baseFont)
allianceFont:SetTextColor(0,0,1)
allianceFont:SetFont(allianceFont:GetFont(), 14)
 
-- New font looking like GameTooltipText but White with height 15
local green12Font = CreateFont("green12Font")
green12Font:SetFont(baseFont:GetFont(), 12)
green12Font:SetTextColor(0,1,0)


-- Hunter
hunterFont = CreateFont("hunterFont")
hunterFont:SetFont(baseFont:GetFont(), 10)
hunterFont:SetTextColor(RAID_CLASS_COLORS["HUNTER"].r,RAID_CLASS_COLORS["HUNTER"].g,RAID_CLASS_COLORS["HUNTER"].b)
 
-- Warlock
warlockFont = CreateFont("warlockFont")
warlockFont:SetFont(baseFont:GetFont(), 10)
warlockFont:SetTextColor(RAID_CLASS_COLORS["WARLOCK"].r,RAID_CLASS_COLORS["WARLOCK"].g,RAID_CLASS_COLORS["WARLOCK"].b)
 
-- Priest
priestFont = CreateFont("priestFont")
priestFont:SetFont(baseFont:GetFont(), 10)
priestFont:SetTextColor(RAID_CLASS_COLORS["PRIEST"].r,RAID_CLASS_COLORS["PRIEST"].g,RAID_CLASS_COLORS["PRIEST"].b)
 
-- Mage
mageFont = CreateFont("mageFont")
mageFont:SetFont(baseFont:GetFont(), 10)
mageFont:SetTextColor(RAID_CLASS_COLORS["MAGE"].r,RAID_CLASS_COLORS["MAGE"].g,RAID_CLASS_COLORS["MAGE"].b)
 
-- Paladin
paladinFont = CreateFont("paladinFont")
paladinFont:SetFont(baseFont:GetFont(), 10)
paladinFont:SetTextColor(RAID_CLASS_COLORS["PALADIN"].r,RAID_CLASS_COLORS["PALADIN"].g,RAID_CLASS_COLORS["PALADIN"].b)
 
-- Shaman
shamanFont = CreateFont("shamanFont")
shamanFont:SetFont(baseFont:GetFont(), 10)
shamanFont:SetTextColor(RAID_CLASS_COLORS["SHAMAN"].r,RAID_CLASS_COLORS["SHAMAN"].g,RAID_CLASS_COLORS["SHAMAN"].b)
 
-- Druid
druidFont = CreateFont("druidFont")
druidFont:SetFont(baseFont:GetFont(), 10)
druidFont:SetTextColor(RAID_CLASS_COLORS["DRUID"].r,RAID_CLASS_COLORS["DRUID"].g,RAID_CLASS_COLORS["DRUID"].b)
 
-- deathknight
deathknightFont = CreateFont("deathknightFont") 
deathknightFont:SetFont(baseFont:GetFont(), 10)
deathknightFont:SetTextColor(RAID_CLASS_COLORS["DEATHKNIGHT"].r,RAID_CLASS_COLORS["DEATHKNIGHT"].g,RAID_CLASS_COLORS["DEATHKNIGHT"].b)
 
-- Rogue
rogueFont = CreateFont("rogueFont")
rogueFont:SetFont(baseFont:GetFont(), 10)
rogueFont:SetTextColor(RAID_CLASS_COLORS["ROGUE"].r,RAID_CLASS_COLORS["ROGUE"].g,RAID_CLASS_COLORS["ROGUE"].b)
 
-- Warrior
warriorFont = CreateFont("warriorFont")
warriorFont:SetFont(baseFont:GetFont(), 10)
warriorFont:SetTextColor(RAID_CLASS_COLORS["WARRIOR"].r,RAID_CLASS_COLORS["WARRIOR"].g,RAID_CLASS_COLORS["WARRIOR"].b)

-- Monk
monkFont = CreateFont("monkFont")
monkFont:SetFont(baseFont:GetFont(), 10)
monkFont:SetTextColor(RAID_CLASS_COLORS["MONK"].r,RAID_CLASS_COLORS["MONK"].g,RAID_CLASS_COLORS["MONK"].b)
 
CLASS_FONTS = {
    ["HUNTER"] = hunterFont,
    ["WARLOCK"] = warlockFont,
    ["PRIEST"] = priestFont,
    ["PALADIN"] = paladinFont,
    ["MAGE"] = mageFont,
    ["ROGUE"] = rogueFont,
    ["DRUID"] = druidFont,
    ["SHAMAN"] = shamanFont,
    ["WARRIOR"] = warriorFont,
    ["DEATHKNIGHT"] = deathknightFont,
    ["MONK"] = monkFont,
};

--------------------------------------
-- Initialisation
--------------------------------------
 
function DraiksBrokerDB:OnInitialize()
 
     self:RegisterEvent("GROUP_ROSTER_UPDATE")
     
     -- Default values for the save variables
     default_options = {
          global = {
               data = {
                    -- Faction
                    ['*'] = {
                         -- Realm
                         ['*'] = {
                              -- Name
                              ['*'] = {
                                   class = "",   -- Non Localised class name
                                   level = 0,
                                   ilvl = 0,
                                   last_update = 0,
                              }
                         }
                    },
                    partyData = {
                         -- GUID
                         ['*'] = {
                              -- DateTime
                              ['*'] = {
                                   class = "",   -- Non localised class name
                                   level = 0,
                                   ilvl = 0,
                                   name = 0,
                              }
                         }
                    },
               },
               settings = {
                    addonVersion = 1.6
               },
          },
          profile = {
               options = {
                    all_factions = true,
                    all_realms = true,
                    debug_mode = false,
                    refresh_rate = 20,
                    show_class_name = true,
                    colorize_class = true,
                    tooltip_scale = 1,
                    opacity = .9,
                    sort_type = "alpha",
                    use_icons = false,
                    display_bars = true,
                    show_level = false,
                    calculate_own_ilvl = false,
                    show_party = true,
                    save_externals = true,
                    is_ignored = {
                         -- Realm
                         ['*'] = {
                              -- Name
                              ['*'] = false,
                         },
                    },
                    ldbicon = {
                         hide = nil,
                    },
                    group = {
                         formedDate = nil,
                         active = false,
                         type = nil
                    },
               },
          },
     }
 
     self.db = LibStub("AceDB-3.0"):New("ilvlDB", default_options, true)
     self.faction = UnitFactionGroup("player")
     self.realm = GetRealmName()
     self.pc = UnitName("player")
     if self.db.profile.options.calculate_own_ilvl then
          self.db.global.data[self.faction][self.realm][self.pc].ilvl = CalculateUnitItemLevel(getOwnInventory(self.pc))
     else
          self.db.global.data[self.faction][self.realm][self.pc].ilvl = GetAverageItemLevel()
     end
     self.db.global.data[self.faction][self.realm][self.pc].level = UnitLevel("player")
     self.db.global.data[self.faction][self.realm][self.pc].class = classFileName
     self.db.global.data[self.faction][self.realm][self.pc].key = UnitGUID("player")
 
     self.sort_table = {}
     self.scanqueue = {}
     self.partyName = {}
     self.partyClass = {}
     self.partyLevel = {}
     self.partyiLvl = {}

     local options = {
          name = L["Draiks Broker ILevel"],
          childGroups = 'tab',
          type = 'group',
          order = 1,
          args = {
               display = {
                    type = 'group',
                    name = L["Display"],
                    desc = L["Specify what to display"],
                    args = {
                         main = {
                              type = 'header',
                              name = L["Main Settings"],
                              order = 1,
                         },
                         show_level = {
                              name = L["Show Level"],
                              desc = L["Show Character Levels"],
                              type = 'toggle',
                              get = function() return DraiksBrokerDB:GetOption('show_level') end,
                              set = function(info, v) DraiksBrokerDB:SetOption('show_level',v) end,
                              order = 1.1,
                         },
                         calculate_own_ilvl = {
                              name = L["Calculate Own Average iLevel"],
                              desc = L["Calculate your own average iLevel based on what you have equiped instead of using the Blizzard Reported Average iLevel"],
                              type = 'toggle',
                              get = function() return DraiksBrokerDB:GetOption('calculate_own_ilvl') end,
                              set = function(info, v) DraiksBrokerDB:SetOption('calculate_own_ilvl',v) end,
                              order = 1.2,
                         },
                         display_bars = {
                              name = L["Show Bars"],
                              desc = L["Display Table Rows as colored bars with white text"],
                              type = 'toggle',
                              get = function() return DraiksBrokerDB:GetOption('display_bars') end,
                              set = function(info, v) DraiksBrokerDB:SetOption('display_bars',v) end,
                              order = 1.3,
                         },
                         faction_and_realms = {
                              type = 'header',
                              name = L["Factions and Realms"],
                              order = 2,
                         },
                         all_factions = {
                              name = L["All Factions"],
                              desc = L["All factions will be displayed"],
                              type = 'toggle',
                              get = function() return DraiksBrokerDB:GetOption('all_factions') end,
                              set = function(info, v) DraiksBrokerDB:SetOption('all_factions',v) end,
                              order = 2.1,
                         },
                         all_realms = {
                              name = L["All Realms"],
                              desc = L["All realms will be displayed"],
                              type = 'toggle',
                              get = function() return DraiksBrokerDB:GetOption('all_realms') end,
                              set = function(info, v) DraiksBrokerDB:SetOption('all_realms',v) end,
                              order = 2.2,
                         },
                         group_raid = {
                              type = 'header',
                              name = L["Group and Raid Options"],
                              order = 3,
                         },
                         show_party = {
                              name = L["Show Party"],
                              desc = L["Show the ilvl of party and raid members from your server."],
                              type = 'toggle',
                              get = function() return DraiksBrokerDB:GetOption('show_party') end,
                              set = function(info, v) DraiksBrokerDB:SetOption('show_party',v) end,
                              order = 3.1,
                         },
                         save_party = {
                              name = L["Save Party"],
                              desc = L["Save the ilvl of party and raid members from your server."],
                              type = 'toggle',
                              get = function() return DraiksBrokerDB:GetOption('save_externals') end,
                              set = function(info, v) DraiksBrokerDB:SetOption('save_externals',v) end,
                              order = 3.2,
                         },
                         sort = {
                              type = 'header',
                              name = L["Sort Order"],
                              order = 8,
                         },
                         sort_type = {
                              name = L["Sort Type"],
                              desc = L["Select the sort type"],
                              type = 'select',
                              get = function() return DraiksBrokerDB:GetOption('sort_type') end,
                              set = function(info, v) DraiksBrokerDB:SetOption('sort_type',v) end,
                              values  = {
                                   ["alpha"]   = L["By Name"],
                                   ["level"]   = L["By Level"],
                                   ["ilvl"]    = L["By Item Level"],
                              },
                              order     = 8.1,
                         },
                         reverse_sort = {
                              name = L["Sort in reverse order"],
                              desc = L["Use the curent sort type in reverse order"],
                              type = 'toggle',
                              get = function() return DraiksBrokerDB:GetOption('reverse_sort') end,
                              set = function(info, v) DraiksBrokerDB:SetOption('reverse_sort',v) end,
                              order = 8.2,
                         },
                         debug_header = {
                              type = 'header',
                              name = L["Debug Mode"],
                              order = 9,
                         },
                         debug_mode = {
                              name = L["Debug"],
                              desc = L["Enable Debugging"],
                              type = 'toggle',
                              get = function() return DraiksBrokerDB:GetOption('debug_mode') end,
                              set = function(info, v) DraiksBrokerDB:SetOption('debug_mode',v) end,
                              order = 9.1,
                         },
                    }
               },
               ignore = {
                    name = L["Ignore Characters"],
                    desc    = L["Hide characters from display"],
                    type    = 'group',
                    args    = {
                         realm = {
                              name = L["Realm"],
                              type = 'description',
                              order = .5,
                         },
                         name = {
                              name = L["Character Name"],
                              type = 'description',
                              order = .7,
                         },
                    },
                    order   = 20
               },
          },
     }
 
 
     -- Ignore section
     local faction_order = 1
     for faction, faction_table in pairs(DraiksBrokerDB.db.global.data) do
 
          local faction_id = "faction" .. faction_order
          options.args.ignore.args[faction_id] = {
               type    = 'group',
               name    = formatFaction(faction),
               args    = {},
          }
          faction_order = faction_order + 1
 
          local realm_order = 1
          for realm, realm_table in pairs(faction_table) do
               local realm_id = "realm" .. realm_order
               options.args.ignore.args[faction_id].args[realm_id] = {
                    type    = 'group',
                    name    = formatRealm(faction, realm),
                    args    = {},
               }
 
               local pc_order = 1
               for pc, _ in pairs(realm_table) do
                    pc_id = "pc" .. pc_order
                    options.args.ignore.args[faction_id].args[realm_id].args[pc_id] = {
                         name = pc,
                         desc = string.format("Hide %s of %s from display", pc, realm),
                         type = 'toggle',
                         get  = function() return DraiksBrokerDB:GetOption('is_ignored',realm, pc) end,
                         set  = function(info, value) DraiksBrokerDB:SetOption('is_ignored', value, realm, pc) end
                    }
 
                    pc_order = pc_order + 1
               end
 
               realm_order = realm_order + 1
          end
     end
 
     options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
     local AceConfig = LibStub("AceConfig-3.0")
 
     AceConfig:RegisterOptionsTable(L["Draiks Broker ILevel"], options, {L["dil"], L["draiksbrokerilevel"], L["draiksilvl"], L["draiksilevel"]})
 
 
     DraiksBrokerDB.config_menu = options
 
     LibStub("AceConfig-3.0"):RegisterOptionsTable(L["Draiks Broker ILevel"], options)
     DraiksBrokerDB.options_frame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(L["Draiks Broker ILevel"])
 
     -- Check if already in party
     if GetNumGroupMembers() == 0 then
          -- if the mod thingks we are in a party close it out
          if self.db.profile.options.group.active then
               self.db.profile.options.group.active = false
               debug_message("Group party formed :" .. self.db.profile.options.group.formedDate)
          end
     end
 
     -- setup the timer to run every 10 seconds
     self.queueTimer = self:ScheduleRepeatingTimer("TimerQueue", 10)
 
end

f:SetScript("OnUpdate", function(self, elap)
     elapsed = elapsed + elap
     if elapsed < UPDATEPERIOD then return end
 
 
     elapsed = 0
     iLevel = GetAverageItemLevel()
     self.faction = UnitFactionGroup("player")
     self.realm = GetRealmName()
     self.pc = UnitName("player")
     DraiksBrokerDB.db.global.data[self.faction][self.realm][self.pc].ilvl = iLevel
     if not draiksAddonInitialised then
          ilevelDB = {}
          draiksAddonInitialised = true
     end
     
     if DraiksBrokerDB.db.profile.options.calculate_own_ilvl then
          DraiksBrokerDB.db.global.data[self.faction][self.realm][self.pc].ilvl = CalculateUnitItemLevel(getOwnInventory(self.pc))
     end
     DraiksBrokerDB.db.global.data[self.faction][self.realm][self.pc].level = UnitLevel("player")
     dataobj.text = string.format("ilvl: %.1f", DraiksBrokerDB.db.global.data[self.faction][self.realm][self.pc].ilvl)

     addonLoadedBool = true
 
     SendAddonMessage(messagePrefix, DraiksBrokerDB.db.global.data[self.faction][self.realm][self.pc].ilvl, "RAID")
 
end)
 
--------------------------------------
-- Formating Functions
--------------------------------------

function formatFaction(faction)
    if faction == "partyData" then
        faction = "Other Player Characters"
    end
    return faction
end
 
function formatRealm(faction,realm)
    returnval = realm
    if faction == "partyData" then
        for  _, raid_table in pairs(DraiksBrokerDB.db.global.data.partyData[realm]) do
            returnval = raid_table.name
        end
    end
    return returnval
end

--------------------------------------
-- LibDataBroker Display Object Functions
--------------------------------------
 
function dataobj:OnEnter()
     -- Acquire a tooltip with 3 columns, respectively aligned to left, center and right
     local tooltip = LibQTip:Acquire("DraiksBrokerDB", 3, "LEFT", "CENTER", "RIGHT")
     self.tooltip = tooltip
 
     tooltip:Clear()
 
 
     tooltip:SetFont(white10Font)
     tooltip:SetHeaderFont(white14Font)
     -- Add an header filling only the first two columns
     local line, column = tooltip:AddHeader()
     tooltip:SetCell(line, 1, L["Character iLevel Breakdown"], "CENTER", 3)
     names = {}
     tooltip:AddSeparator()
 
     for faction, faction_table in pairs (DraiksBrokerDB.db.global.data) do
          if DraiksBrokerDB:GetOption('all_factions') or faction == DraiksBrokerDB.faction  then
               if faction ~= "partyData" then
                    if faction == "Horde" then
                         tooltip:SetHeaderFont(hordeFont)
                    else
                         tooltip:SetHeaderFont(allianceFont)
                    end
                    tooltip:AddHeader(faction)
                    for realm, realm_table in pairs (faction_table) do
                         if DraiksBrokerDB:GetOption('all_realms') or realm == DraiksBrokerDB.realm then
                              tooltip:SetHeaderFont(green12Font)
                              tooltip:AddHeader(realm)
                              DraiksBrokerDB:FetchOrderedNames(names, realm_table)
                              for _,name in ipairs (names) do
                                   if not DraiksBrokerDB:GetOption('is_ignored', realm, name) then
                                        local line, column = tooltip:AddLine()
                                        if DraiksBrokerDB.db.profile.options.display_bars  then
                                             color = RAID_CLASS_COLORS[DraiksBrokerDB.db.global.data[faction][realm][name].class]
                                             tooltip:SetCell(line, 1, name, white10Font)
                                             tooltip:SetCell(line, 3, string.format("%.1f", DraiksBrokerDB.db.global.data[faction][realm][name].ilvl), white10font)
                                             tooltip:SetLineColor(line, color.r, color.g, color.b)
                                             if DraiksBrokerDB.db.profile.options.show_level then
                                                  tooltip:SetCell(line, 2, DraiksBrokerDB.db.global.data[faction][realm][name].level, white10Font)
                                             end
                                        else
                                             tooltip:SetCell(line, 1, name, CLASS_FONTS[DraiksBrokerDB.db.global.data[faction][realm][name].class])
                                             tooltip:SetCell(line, 3, string.format("%.1f",DraiksBrokerDB.db.global.data[faction][realm][name].ilvl), CLASS_FONTS[DraiksBrokerDB.db.global.data[faction][realm][name].class])
                                             if DraiksBrokerDB.db.profile.options.show_level then
                                                  tooltip:SetCell(line, 2, DraiksBrokerDB.db.global.data[faction][realm][name].level, CLASS_FONTS[DraiksBrokerDB.db.global.data[faction][realm][name].class])
                                             end
                                        end
                                   end
                              end
                         end
                    end
                    tooltip:AddLine(" ")
               end
          end
     end
     
     -- Party Ilevel
      if DraiksBrokerDB:GetOption('show_party') and DraiksBrokerDB.db.profile.options.group.active then
          tooltip:AddSeparator()
          tooltip:SetHeaderFont(green12Font)
          tooltip:AddHeader(L["Current Group"])
         if DraiksBrokerDB.locals == true then
          for GUID,pc_table in pairs (DraiksBrokerDB.db.global.data.partyData) do
             for formedDate, resttable in pairs(pc_table) do
              if formedDate == DraiksBrokerDB.db.profile.options.group.formedDate then
               debug_message(resttable.name)

               if check_player_in_group(resttable.name) then
                 local line, column = tooltip:AddLine()
                 if DraiksBrokerDB.db.profile.options.display_bars  then
                      color = RAID_CLASS_COLORS[resttable.class]
                      tooltip:SetCell(line, 1, resttable.name, white10Font)
                      tooltip:SetCell(line, 3, string.format("%.1f", resttable.ilvl), white10font)
                      debug_message(GUID)
                      debug_message (resttable.class)
                      tooltip:SetLineColor(line, color.r, color.g, color.b)
                      if DraiksBrokerDB.db.profile.options.show_level then
                           tooltip:SetCell(line, 2, resttable.level, white10Font)
                      end
                     else
                      tooltip:SetCell(line, 1, resttable.name, CLASS_FONTS[DraiksBrokerDB.db.global.data.partyData[GUID][DraiksBrokerDB.db.profile.options.group.formedDate].class])
                      tooltip:SetCell(line, 3, string.format("%.1f",resttable.ilvl), CLASS_FONTS[DraiksBrokerDB.db.global.data.partyData[GUID][DraiksBrokerDB.db.profile.options.group.formedDate].class])
                      if DraiksBrokerDB.db.profile.options.show_level then
                           tooltip:SetCell(line, 2, resttable.level, CLASS_FONTS[DraiksBrokerDB.db.global.data.partyData[GUID][DraiksBrokerDB.db.profile.options.group.formedDate].class])
                      end
                    end
                 end
               end
             end
          end
        end
  
        if DraiksBrokerDB.foreigners == true then
          -- Show foreigners from RAM but not saved
          for theirName,_ in pairs(DraiksBrokerDB.partyName) do
            if check_player_in_group(theirName) then
               debug_message("Found :" .. theirName)
               local line, column = tooltip:AddLine()
               if DraiksBrokerDB.db.profile.options.display_bars  then
                    color = RAID_CLASS_COLORS[DraiksBrokerDB.partyClass[theirName]]
                    tooltip:SetCell(line, 1, theirName, white10Font)
                    tooltip:SetCell(line, 3, string.format("%.1f", DraiksBrokerDB.partyiLvl[theirName]), white10font)
                    tooltip:SetLineColor(line, color.r, color.g, color.b)
                    if DraiksBrokerDB.db.profile.options.show_level then
                         tooltip:SetCell(line, 2, DraiksBrokerDB.partyLevel[theirName], white10Font)
                    end
               else
                    tooltip:SetCell(line, 1, theirName, CLASS_FONTS[DraiksBrokerDB.partyClass[theirName]])
                    tooltip:SetCell(line, 3, string.format("%.1f",DraiksBrokerDB.partyiLvl[theirName]), CLASS_FONTS[DraiksBrokerDB.partyClass[theirName]])
                    if DraiksBrokerDB.db.profile.options.show_level then
                         tooltip:SetCell(line, 2, DraiksBrokerDB.partyLevel[theirName], CLASS_FONTS[DraiksBrokerDB.partyClass[theirName]])
                    end
               end
            end
          end
        end
     end
 
     -- Use smart anchoring code to anchor the tooltip to our frame
     tooltip:SmartAnchorTo(self)
 
     -- Show it, et voil� !
     tooltip:Show()
end
 
 
 
function dataobj:OnLeave()
 
   -- Release the tooltip
   LibQTip:Release(self.tooltip)
   self.tooltip = nil
end
 
function dataobj:OnClick()
    -- Do Nothing added to solve a Null when used as a part of Elv
end

--------------------------------------
-- Addon Configuration Functions
--------------------------------------
 
function DraiksBrokerDB:GetOption( option, ... )
 
    -- is_ignored has multiple parameters
    if option == 'is_ignored' then
        local realm, name = ...
 
        return self.db.profile.options.is_ignored[realm][name]
 
    -- The sort direction is kept in the sort name
    elseif option == 'reverse_sort' then
        if string.find(self.db.profile.options.sort_type, "rev-") == 1 then
            return true
        else
            return false
        end
    elseif option == 'sort_type' then
        if string.find(self.db.profile.options.sort_type, "rev-") == 1 then
            return string.sub(self.db.profile.options.sort_type, 5)
        else
            return self.db.profile.options.sort_type
        end
    elseif option == 'display_sort_type' then
        -- For display, we need the complete thing
        return self.db.profile.options.sort_type
    end
 
 
    return self.db.profile.options[option] end
 
 
 
-- Set an option value
function DraiksBrokerDB:SetOption( option, value, ... )
 
    local already_set = false
 
    -- Do we need to recompute the totals?
    if option == 'all_factions' or option == 'all_realms' or option == 'is_ignored' then
        if option == 'is_ignored' then
            local realm, name = ...
            self.db.profile.options.is_ignored[realm][name] = value
        else
            self.db.profile.options[option] = value
        end
 
        already_set = true
    -- Set the scale of the tooltip
    elseif option == 'tooltip_scale' and self.tooltip then
        self.tooltip:SetScale(value)
 
    -- Set the opacity of the tablet frame
    elseif option == 'opacity' then
        self:SetTTOpacity(value)
 
    -- Ajust the sort type with the direction
    elseif option == 'sort_type' then
        if self:GetOption('reverse_sort') then
            self.db.profile.options.sort_type = "rev-" .. value
        else
            self.db.profile.options.sort_type = value
        end
 
        already_set = true
    -- Modify the direction of the sort
    elseif option == 'reverse_sort' then
        local sort_type
        if self:GetOption('reverse_sort') then
            sort_type = string.sub(self.db.profile.options.sort_type,5)
        else
            sort_type = self.db.profile.options.sort_type
        end
 
        if value then
            self.db.profile.options.sort_type = "rev-" .. sort_type
        else
            self.db.profile.options.sort_type = sort_type
        end
        already_set = true
        end
 
    -- Set the value
    if not already_set then
        self.db.profile.options[option] = value
    end
 
end
 
function DraiksBrokerDB:FetchOrderedNames(names, characters)
    wipe(names)
    for name, name_table in pairs(characters) do
        table.insert(names, name)
    end
    DraiksBrokerDB.sort_table = characters
        if self.db.profile.options.sort_type == "alpha" then
        table.sort(names)
    elseif self.db.profile.options.sort_type == "rev-alpha" then
        table.sort(names, revAlphaSort)
    elseif self.db.profile.options.sort_type == "rev-level" then
        table.sort(names, revlevelSort)
    elseif self.db.profile.options.sort_type == "level" then
        table.sort(names, levelSort)
    elseif self.db.profile.options.sort_type == "rev-ilvl" then
        table.sort(names, revilvlSort)
    elseif self.db.profile.options.sort_type == "ilvl" then
        table.sort(names, ilvlSort)
    end
end
 
--------------------------------------
-- Utility Functions
-------------------------------------- 
 
function revAlphaSort(a,b)
    return b < a
end
 
function revlevelSort(a,b)
  return DraiksBrokerDB.sort_table[b].level < DraiksBrokerDB.sort_table[a].level
end
 
function levelSort(a,b)
  return DraiksBrokerDB.sort_table[a].level < DraiksBrokerDB.sort_table[b].level
end
 
function revilvlSort(a,b)
  return DraiksBrokerDB.sort_table[b].ilvl < DraiksBrokerDB.sort_table[a].ilvl end
 
function ilvlSort(a,b)
  return DraiksBrokerDB.sort_table[a].ilvl < DraiksBrokerDB.sort_table[b].ilvl end
 
-- Clears a Lua Table
function zap(table)
    local next = next
    local k = next(table)
    while k do
        table[k] = nil
        k = next(table)
    end
end

 
function CalculateUnitItemLevel(calcItems)
    local t,c=0,0
    local ail=0
 	debug_message("Calculating iLevel")
        for i =1,17 do
          if not isempty(calcItems[i]) then
            if i~=4 then
                debug_message ("Testing " .. calcItems[i])
                local iname,_,_,l,_,_,_,_,_=GetItemInfo(calcItems[i])
                t=t+l
                c=c+1
                debug_message ("Found " .. iname .. ". ilvl: " .. l .. ", total=" .. t .. " Average= " .. (t/c) .. " Iteration: " .. i)
            end
          end
        end
        if c>0 then
            debug_message("Inspected with average iLevel " .. t/c)
            ail=t/c
        end
    return ail
end

function check_player_in_group(name)
    debug_message("Checking for " .. name)
    local found = false
    local type="party"
    if IsInRaid() then
        type="raid"
    end
    -- if its you skip it
    if name ~= DraiksBrokerDB.pc then
       -- loop party members
       for i=1, GetNumGroupMembers() do
            if GetUnitName(type .. i) == name then
              found = true
              debug_message("found " .. name .. " at " .. type .. i)
           end
       end
    end
    return found
end

function getOwnInventory(unit)
  myItems = getInventory(unit)
  return CalculateUnitItemLevel(myItems)
end

function getInventory(unit)
  unitItems = {} 
  for i =1,17 do
     local itemLink = GetInventoryItemLink(unit, i);
     if itemLink == nil then
       debug_message("Nothing in slot " .. i)
     else
       debug_message("added Item in slot " .. i)
       unitItems[i]=itemLink
     end
  end
  return unitItems
end

function debug_message(message)
    if DraiksBrokerDB:GetOption('debug_mode') then
        print("DIB: " .. message)
    end
end

function checkCombat()
    if UnitAffectingCombat('player') then 
         return 1
    end
end

function isempty(s)
  return s == nil or s == ''
end
--------------------------------------
-- Party List Functions
--------------------------------------
 
function DraiksBrokerDB:GROUP_ROSTER_UPDATE(...)
   if GetNumGroupMembers() > 0 then
     if not self.db.profile.options.group.active then
        self.db.profile.options.group.formedDate = date("%y/%m/%d %H:%M:%S")
        self.db.profile.options.group.type = "group"
        self.db.profile.options.group.active = true
        debug_message("Group party formed :" .. self.db.profile.options.group.formedDate)
     end
   else
    self.db.profile.options.group.active = false
    DraiksBrokerDB.locals = false
    zap(DraiksBrokerDB.partyClass)
    zap(DraiksBrokerDB.partyName)
    zap(DraiksBrokerDB.partyLevel )
    zap(DraiksBrokerDB.partyiLvl)
    zap(DraiksBrokerDB.scanqueue)
    DraiksBrokerDB.foreigners = false
    debug_message("Group formed :" .. self.db.profile.options.group.formedDate .. " Successfully Disbanded")
   end 
end

function DraiksBrokerDB:InspectReady()
    DraiksBrokerDB:UnregisterEvent("INSPECT_READY")
    local unit = DraiksBrokerDB.tunit
    local missing -- will be true if any links missing (not cached)
    -- first make sure all links are valid (cached)
    for i=1,17 do
        if GetInventoryItemID(unit,i) and not GetInventoryItemLink(unit,i) then
            missing = true
        end
    end
    -- not all links cached, come back next frame
    if missing then
        return
    end
    -- at this point all links are valid
    CheckChar(unit,DraiksBrokerDB.tname) 

end
function DraiksBrokerDB:INSPECT_READY(...)
    DraiksBrokerDB:InspectReady()
end

function DraiksBrokerDB:CHAT_MSG_ADDON(prefix, message, channel, sender)
    debug_message("Got message from " .. sender .. " with ilevel of " .. message)
    if self.db.profile.options.group.active then
        local _, theirClass = UnitClass(sender)
        return addUsertoDB(sender, theirClass, sender, UnitLevel(sender), message )
    end
end
 
function Scan_Party()
	if checkGroup() and not checkCombat() then
        local inRaid = IsInRaid()
        local oor
        for i=1,GetNumGroupMembers() do
            local unit = inRaid and "raid"..i or i==1 and "player" or "party"..(i-1)
            local name = GetUnitName(unit,true)
            
            debug_message ("Have we found unit ".. name .. "? " .. tostring(isempty(DraiksBrokerDB.scanqueue[name])))
            if isempty(DraiksBrokerDB.scanqueue[name]) and CanInspect(unit) then
                if CheckInteractDistance(unit,1) then
                    debug_message ("Inspecting " .. GetUnitName(unit) .. " " .. name)
                    NotifyInspect(unit)
                    DraiksBrokerDB.tunit = unit
                    DraiksBrokerDB.tname = name
                    DraiksBrokerDB:RegisterEvent("INSPECT_READY")
                    return -- leaving
                else
                    oor = true
                    debug_message (GetUnitName(unit) .. " out of range will try them later.")
                end
             end
         end
    end 
end

function CheckChar(targetunit, targetname)
    local theirGUID = UnitGUID(targetunit)
    debug_message ("Unit" .. targetname .. " " .. targetunit .. " has GUID of " .. theirGUID)
    storeInspectedData(UnitGUID(targetunit), getInventory(targetunit))
end

function checkGroup()
	localgroupval = false
	-- Normal Group
	if IsInGroup() then
		localgroupval = true
		debug_message ("User in local Group")
	end
	-- Normal Ra9d
	if IsInRaid() then
		localgroupval = true
		debug_message ("User in local Raid")
	end
	-- LFR Group in case the checks above didnt catch that we were in LFG / LFR
	if GetNumGroupMembers(LE_PARTY_CATEGORY_INSTANCE) > 0 then
		localgroupval= true
		debug_message ("User foundin LFG/LFR")
	end	
	return localgroupval
end
 
--------------------------------------
-- Timer Functions
--------------------------------------
 
function DraiksBrokerDB:TimerQueue()
    Scan_Party()
end


--------------------------------------
-- Data Storage Functions
--------------------------------------

function storeInspectedData(returnedGuid, returnedItems)
      returnval = false
      local class_loc, class, locRace, engRace, gender, theirName, realm = GetPlayerInfoByGUID(returnedGuid);
      local theiriLvl = CalculateUnitItemLevel(returnedItems)
      local theirLevel = UnitLevel(theirName)
      debug_message("Found ".. class .. " " .. theirName  .." with average ilevel of " .. theiriLvl)
      return addUsertoDB(theirName, class, theirName, theirLevel, theiriLvl )
end

function addUsertoDB(theirUnit,theirClass,theirName,theirLevel,theiriLvl)
      local theirGUID = UnitGUID(theirUnit)
      if UnitIsSameServer(theirUnit, "player") and DraiksBrokerDB:GetOption('save_externals') then   --Only save units from my server
           debug_message("Added " .. name .. " to permanent table.")
           DraiksBrokerDB.db.global.data.partyData[theirGUID][DraiksBrokerDB.db.profile.options.group.formedDate].class =  theirClass
           DraiksBrokerDB.db.global.data.partyData[theirGUID][DraiksBrokerDB.db.profile.options.group.formedDate].name =  theirName
           DraiksBrokerDB.db.global.data.partyData[theirGUID][DraiksBrokerDB.db.profile.options.group.formedDate].level =  theirLevel
           if theiriLvl > DraiksBrokerDB.db.global.data.partyData[theirGUID][DraiksBrokerDB.db.profile.options.group.formedDate].ilvl then
                DraiksBrokerDB.db.global.data.partyData[theirGUID][DraiksBrokerDB.db.profile.options.group.formedDate].ilvl =  theiriLvl
           end
           -- I have them take them out of the queue
           returnval = true
           DraiksBrokerDB.scanqueue[name] = theirName     
           DraiksBrokerDB.locals = true
      else
           debug_message("Added " .. theirName .. " to local table.")
           DraiksBrokerDB.partyClass[theirName] =  class
           DraiksBrokerDB.partyLevel[theirName] =  theirLevel
           DraiksBrokerDB.partyiLvl[theirName] =  theiriLvl
           DraiksBrokerDB.partyName[theirName] =  theirName
           -- I have them take them out of the queue
           DraiksBrokerDB.scanqueue[name] = theirName
           returnval = true
           DraiksBrokerDB.foreigners = true
      end
      return returnval

end


