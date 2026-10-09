-- WoW Retail | Interface: 120100
-- AltVault
-- Version: 0.1.0

local addonName = ...

print("|cffFFD700" .. addonName .. "|r successfully loaded! Welcome to Azeroth.")

local characterName = UnitName("player")

print("AltVault detected character: " .. (characterName or "Unknown"))

local realmName = GetRealmName()

print("AltVault detected realm: " .. (realmName or "Unknown"))


local totalCopper = GetMoney()
local totalGold = math.floor(totalCopper / 10000)
local formattedGold = BreakUpLargeNumbers(totalGold)

print("AltVault detected gold: |cffffd700" .. formattedGold .. "|r")
