# RKeys

### Начало работы
```lua
local vkeys = require 'vkeys' -- Библиотека с кодами клавиш в удобном формате
local rkeys = require 'rkeys' -- Подключаем RKeys
```
### Регистрация клавиш
```lua
-- Регистрируем сочетание клавиш Left Shift + W. Указываем тип активации клавиши как 1. Тертьим аргументом задаем блокировку ввода при нажатии последней клавиши комбинации
local newid = rkeys.registerHotKey({ vkeys.VK_LSHIFT, vkeys.VK_W }, 1, true,
                     function()
                        print("Combo 'iskeypressed' activeted")
                     end)
 -- Возвращает индефикатор новой комбинации.
```
### Удаление клавиш
```lua
-- В качестве аргумента функция принимает комбинацию клавиш (удалит все совпадения) или ID хоткея.
local deleted = rkeys.unRegisterHotKey({vkeys.VK_LSHIFT, vkeys.VK_W})
if deleted then
  print("LShift + W deleted", -1)
end
```
