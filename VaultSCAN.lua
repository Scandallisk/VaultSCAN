-- WoW Retail | Interface: 120100
-- VaultSCAN
-- Version: 0.1.0

local addonName = ...

-- Initialize the saved database if it doesn't already exist.
VaultSCANDB = VaultSCANDB or {}
print("|cffFFD700" .. addonName .. "|r successfully loaded! Welcome to Azeroth.")

local characterName = UnitName("player")
print("VaultSCAN detected character: " .. (characterName or "Unknown"))

local realmName = GetRealmName()
print("VaultSCAN detected realm: " .. (realmName or "Unknown"))

local totalCopper = GetMoney()
local totalGold = math.floor(totalCopper / 10000)
local formattedGold = BreakUpLargeNumbers(totalGold)
print("VaultSCAN detected gold: |cffffd700" .. formattedGold .. "|r")
