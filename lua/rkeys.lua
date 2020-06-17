--[[
   Author: DonHomka
   [Functions]
      HotKeys:
      # registerHotKey(table keycombo, int activationType, [bool blockInput = false], function callback)
         ������������ ����� ������. ����� �������� �������� ���������� �����. ���������� ID ������ ������
      # unRegisterHotKey(int id)
         ������� ������ �� ID
      # unRegisterHotKey(table keycombo)
         ������� ������ �� ���������� ������. ���������� ��������� �������� � ����������� ��������� �������.
      # isHotKeyDefined(ind id)
         ��������� �� ������������� ������������ ID �������.
      # isHotKeyDefined(table keycombo)
         ��������� �� ������������� ������ � �������� �����������
      # getHotKey(int id)
         ���������� ������ ������ �� ������� tHotKeys �� ID. ������ ������������ ���������� ���� ��������� ������.
      # getHotKey(table keycombo)
         ���������� ������ ������ �� ������� tHotKeys �� ���������� ������. ������ ������������ ���������� ���� ��������� ������.

      Other:
      # isKeyExist(int keyid, [table keylist = tCurKeys])
         ��������� ������������� ������������ ������� � ������. �� ��������� ������� ������ ������� ������� ������.
      # isKeyComboExist(talbe keycombo, [table keylist = tCurKeys])
         ��������� �� ������������� ���������� ������ � ������
      # getKeyPosition(int keyid, [table keylist = tCurKeys])
         ���������� ������� ������� � ������. ���� ������� ��� - ������ nil
      # getExtendedKeys(int keyid, int scancode, int keyex)
         ���������� ���������� ������ ������������� ��� nil
      # getKeys([bool showKeyName = false])
         ���������� ������� ������� ������� ������. ���������� �������� ����� �� ���������� ��� �������.

      tHotKeys data:
         - keys - ������� ��� ������
         - aType - ��� ������:
            1 - ����������� �� ������� �������
            2 - ����������� �� ������� � �� ��� ��� ���� ������� ������
            3 - ����������� ��� ������� ���������(!) ������� � ����� (Alt + Shift + R - ��������� ���� ������ ���������� � ��������� R)
         - isBlock - ����� �� ����������� ���� ��� ���������(!) ������� �����. �� �������� ��� aType = 3.
         - callback - ������� ��������� ������ ��� ������������ �������
         - id - ���������� ����������� ������ (�� ������� � tHotKeys, � ������ ���������� �����������). ������ �� ����� ID ���������� ����� ������.

   E-mail: idonhomka@gmail.com
   VK: http://vk.com/DonHomka
   TeleGramm: http://t.me/iDonHomka
   Discord: DonHomka#2534
]]
local vkeys = require 'vkeys'
local wm = require 'windows.message'
local bitex = require 'bitex'

local tCurKeys = {}
local tModKeys = {[vkeys.VK_MENU] = true, [vkeys.VK_SHIFT] = true, [vkeys.VK_CONTROL] = true}
local tMessageTrigger = {[wm.WM_KEYDOWN] = true, [wm.WM_SYSKEYDOWN] = true, [wm.WM_KEYUP] = true, [wm.WM_SYSKEYUP] = true}
local tHotKeys = {}
local tActKeys = {}
local hkId = 0
local mod = {}
mod._VERSION = "2.0.0"
mod._MODKEYS = tModKeys
mod._LOCKKEYS = false

addEventHandler("onWindowMessage", function (message, wparam, lparam)
   if tMessageTrigger[message] then
      local scancode = bitex.bextract(lparam, 16, 8)
      local keystate = bitex.bextract(lparam, 30, 1)
      local keyex = bitex.bextract(lparam, 24, 1)
      local keydown = mod.isKeyExist(wparam)
      print(scancode, keyex)
      if message == wm.WM_KEYDOWN or message == wm.WM_SYSKEYDOWN then
         if not keydown and keystate == 0 then
            table.insert(tCurKeys, wparam)
            if tModKeys[wparam] then
               local exKey = mod.getExtendedKeys(wparam, scancode, keyex)
               if exKey then
                  table.insert(tCurKeys, exKey)
               end
            end
         end
         for k, v in ipairs(tHotKeys) do
            if v.aType ~= 3 and (tActKeys[v.id] == nil or v.aType == 2) and ((v.aType == 1 and keystate == 0) or v.aType == 2) and mod.isKeyComboExist(v.keys) then
               v.callback(v)
               tActKeys[v.id] = true
            end
            if v.isBlock and (tActKeys[v.id] or v.aType == 2) then
               consumeWindowMessage()
            end
         end
      elseif message == wm.WM_KEYUP or message == wm.WM_SYSKEYUP then
         for k, v in ipairs(tHotKeys) do
            if v.aType == 3 and keystate == 1 and mod.isKeyComboExist(v.keys) then
               v.callback(v)
            end
         end
         if keydown then
            local pos = mod.getKeyPosition(wparam)
            table.remove(tCurKeys, pos)
            if tModKeys[wparam] then
               local exKey = mod.getExtendedKeys(wparam, scancode, keyex)
               if exKey then
                  pos = mod.getKeyPosition(exKey)
                  table.remove(tCurKeys, pos)
               end
            end
         end
         for k, v in ipairs(tHotKeys) do
            if v.aType == 2 or tActKeys[v.id] and not mod.isKeyComboExist(v.keys) then
               tActKeys[v.id] = nil
            end
         end
      end
   elseif message == wm.WM_KILLFOCUS then
      tCurKeys = {}
   end
end)

--[[
   ������������ ����� �����. ��������� ����������� ������ ������.
]]
function mod.registerHotKey(keycombo, activationType, isBlock_or_callback, callback)
   local newId = hkId + 1
   tHotKeys[#tHotKeys + 1] = {
      keys = keycombo,
      aType = activationType,
      callback = type(isBlock_or_callback) == "function" and isBlock_or_callback or callback,
      id = newId,
      isBlock = type(isBlock_or_callback) == "boolean" and isBlock_or_callback or mod._LOCKKEYS
   }
   hkId = hkId + 1
   return newId
end

--[[
   ��������� ���������� �� ��������� �����. ������ ���������� ���������� ��������� ��������, ������ ���������� �������� �����.
]]
function mod.isHotKeyDefined(keycombo_or_id)
   local bool = false
   local count = 0
   if type(keycombo_or_id) == "number" then
      for k, v in ipairs(tHotKeys) do
         if v.id == keycombo_or_id then
            bool = true
            count = count + 1
         end
      end
   elseif type(keycombo_or_id) == "table" then
      for k, v in ipairs(tHotKeys) do
         if mod.compareKeys(v.keys, keycombo_or_id) then
            bool = true
            count = count + 1
         end
      end
   end
   return bool, count
end

--[[
   ���������� ������ ������ �� ID ��� ����� ������. ���������� ��������� ������ � ������� ������.
]]
function mod.getHotKey(keycombo_or_id)
   local bool = false
   local data = {}
   if type(keycombo_or_id) == "number" then
      for k, v in ipairs(tHotKeys) do
         if v.id == keycombo_or_id then
            bool = true
            data = v
            break
         end
      end
   elseif type(keycombo_or_id) == "table" then
      for k, v in ipairs(tHotKeys) do
         if mod.compareKeys(v.keys, keycombo_or_id) then
            bool = true
            data = v
            break
         end
      end
   end
   return bool, data
end

--[[
   �������� ����� ������ ��� ������. ���������� ��������� ���������.
]]
function mod.changeHotKey(id, keycombo)
   local bool = false
   for k, v in ipairs(tHotKeys) do
      if v.id == id then
         bool = true
         v.keys = keycombo
      end
   end
   return bool
end

--[[
   ������� �����. ������ ���������� ���������� ��������� ��������, ������ ���������� ��������� �����.
]]
function mod.unRegisterHotKey(keycombo_or_id)
   local bool = false
   local count = 0
   local idsToRemove = {}
   if type(keycombo_or_id) == "number" then
      for k, v in ipairs(tHotKeys) do
         if v.id == keycombo_or_id then
            bool = true
            count = count + 1
            table.insert(idsToRemove, k)
         end
      end
   elseif type(keycombo_or_id) == "table" then
      for k, v in ipairs(tHotKeys) do
         if mod.compareKeys(v.keys, keycombo_or_id) then
            bool = true
            count = count + 1
            table.insert(idsToRemove, k)
         end
      end
   end
   for k, v in ipairs(idsToRemove) do
      table.remove(tHotKeys, v)
   end
   return bool, count
end

--[[
   ��������� ������� �� ������ keycombo � ������ keylist. ���� ������ keylist - ���������� ������� ������� �������.
]]
function mod.isKeyComboExist(keycombo, keylist)
   keylist = keylist or tCurKeys
   local b = false
   local i = 1
   for k, v in ipairs(keylist) do
      if v == keycombo[i] then
         if i == #keycombo then
            b = true
            break
         end
         i = i + 1
      end
   end
   return b
end

--[[
   ��������� ������� �� ������ keycombo � ������ keylist. ���� ������ keylist - ���������� ������� ������� �������.
]]
function mod.compareKeys(keycombo, keycombotwo)
   local b = true
   for k, v in ipairs(keycombo) do
      if keycombotwo[k] ~= v then
         b = false
         break
      end
   end
   return b
end

--[[
   ���� keyid � ������ keylist. � ������� �� isKeyComboExist �� ���� ��������� ������, � ������ ���� � ��������� �����.
]]
function mod.isKeyExist(keyid, keylist)
   keylist = keylist or tCurKeys
   for k, v in ipairs(keylist) do
      if v == keyid then
         return true
      end
   end
   return false
end

--[[
   ������ isKeyExist, �� ���������� ������� � keylist ���� �������.
]]
function mod.getKeyPosition(keyid, keylist)
   keylist = keylist or tCurKeys
   for k, v in ipairs(keylist) do
      if v == keyid then
         return k
      end
   end
   return nil
end

--[[
   ��������� �������. �������� ���������� ������ Alt, Shift, Ctrl �� ������ �������� � ����������.
]]
function mod.getExtendedKeys(keyid, scancode, extend)
   local newKeyId = nil
   if keyid == vkeys.VK_MENU then
      if extend == 1 then
         newKeyId = vkeys.VK_RMENU
      else
         newKeyId = vkeys.VK_LMENU
      end
   elseif keyid == vkeys.VK_SHIFT then
      if scancode == 42 then
         newKeyId = vkeys.VK_LSHIFT
      elseif scancode == 54 then
         newKeyId = vkeys.VK_RSHIFT
      end
   elseif keyid == vkeys.VK_CONTROL then
      if extend == 1 then
         newKeyId = vkeys.VK_RCONTROL
      else
         newKeyId = vkeys.VK_LCONTROL
      end
   end
   return newKeyId
end

--[[
   ���������� ������ ������� ������� ������ � ������� �������. � �������� ��������� ��������� �� ����� ����� �������� ������. ������ ��, ����� �� �������� ������
]]
function mod.getKeys(keyname, keyscan, keyex)
   keyname = keyname or false
   local szKeys = {}
   for k, v in ipairs(tCurKeys) do
      table.insert(szKeys, ("%s%s"):format(tostring(v), (keyname and ":" .. vkeys.id_to_name(v) or "")))
   end
   return szKeys
end

--[[
   �������� ���������� �������� ������.
]]
function mod.getCountKeys()
   return #tCurKeys
end

return mod