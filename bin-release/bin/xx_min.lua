xx = xx or {}
xx.version = "1.0.0"
print("xx(lua) version: " .. xx.version)
local __uidSeed = 0
function xx.newUID()
    __uidSeed = __uidSeed + 1
    return string.format("xx_lua_%d", __uidSeed)
end
function xx.Handler(handler, caller, ...)
    local cache = {...}
    if 0 == xx.arrayCount(cache) then
        cache = nil
    end
    return function(...)
        if caller then
            if cache then
                return handler(caller, unpack(cache), ...)
            else
                return handler(caller, ...)
            end
        else
            if cache then
                return handler(unpack(cache), ...)
            else
                return handler(...)
            end
        end
    end
end
unpack = unpack or table.unpack
function xx.isNil(target)
    return nil == target
end
function xx.isBoolean(target)
    return "boolean" == type(target)
end
function xx.isNumber(target)
    return "number" == type(target)
end
function xx.isString(target)
    return "string" == type(target)
end
function xx.isFunction(target)
    return "function" == type(target)
end
function xx.isTable(target)
    return "table" == type(target)
end
function xx.isUserdata(target)
    return "userdata" == type(target)
end
function xx.isThread(target)
    return "thread" == type(target)
end
function xx.tableClear(map)
    for key, _ in pairs(map) do
        map[key] = nil
    end
    return map
end
function xx.tableClone(map, recursive)
    local copy = {}
    for key, value in pairs(map) do
        if "table" == type(value) and recursive then
            copy[key] = xx.tableClone(value, recursive)
        else
            copy[key] = value
        end
    end
    return copy
end
function xx.tableMerge(map, ...)
    local mapList = {...}
    for i = 1, xx.arrayCount(mapList) do
        if xx.isTable(mapList[i]) then
            for k, v in pairs(mapList[i]) do
                map[k] = v
            end
        end
    end
    return map
end
function xx.tableCount(map)
    local count = 0
    for _, __ in pairs(map) do
        count = count + 1
    end
    return count
end
function xx.tableKeys(map)
    local keys = {}
    for key, _ in pairs(map) do
        xx.arrayPush(keys, key)
    end
    return keys
end
function xx.tableValues(map)
    local values = {}
    for _, value in pairs(map) do
        xx.arrayPush(values, value)
    end
    return values
end
function xx.arrayCount(array)
    local index = 0
    for key, _ in pairs(array) do
        if xx.isNumber(key) and key > index then
            index = key
        end
    end
    return index
end
function xx.arrayClear(array)
    for i = xx.arrayCount(array), 1, -1 do
        array[i] = nil
    end
    return array
end
function xx.arrayInsert(array, item, index)
    local count = xx.arrayCount(array)
    index = (not index or index > count) and count + 1 or (index < 1 and 1 or index)
    if index <= count then
        for i = count, index, -1 do
            array[i + 1] = array[i]
        end
    end
    array[index] = item
    return array
end
function xx.arrayInsertASC(array, value)
    local index = 1
    for i = xx.arrayCount(array), 1, -1 do
        if array[i] <= value then
            index = i + 1
            break
        end
        array[i + 1] = array[i]
    end
    array[index] = value
    return array
end
function xx.arrayRemove(array, item)
    local iNew = 1
    for iOld = 1, xx.arrayCount(array) do
        if array[iOld] ~= item then
            if iNew ~= iOld then
                array[iNew] = array[iOld]
                array[iOld] = nil
            end
            iNew = iNew + 1
        else
            array[iOld] = nil
        end
    end
    return array
end
function xx.arrayRemoveAt(array, index)
    local count = xx.arrayCount(array)
    if index and index >= 1 and index <= count then
        local item = array[index]
        if index < count then
            for i = index + 1, count do
                array[i - 1] = array[i]
            end
        end
        array[count] = nil
        return item
    end
end
function xx.arrayPush(array, ...)
    local args = {...}
    local count = xx.arrayCount(array)
    for i = 1, xx.arrayCount(args) do
        array[count + i] = args[i]
    end
    return array
end
function xx.arrayPop(array)
    return xx.arrayRemoveAt(array, xx.arrayCount(array))
end
function xx.arrayUnshift(array, item)
    return xx.arrayInsert(array, item, 1)
end
function xx.arrayShift(array)
    return xx.arrayRemoveAt(array, 1)
end
function xx.arrayIndexOf(array, item, from)
    local count = xx.arrayCount(array)
    from = from and (from < 0 and count + from + 1 or from) or 1
    for index = from < 1 and 1 or from, count do
        if array[index] == item then
            return index
        end
    end
    return -1
end
function xx.arrayLastIndexOf(array, item, from)
    local count = xx.arrayCount(array)
    from = from and (from < 0 and count + from + 1 or from) or count
    for i = from > count and count or from, 1, -1 do
        if array[i] == item then
            return i
        end
    end
    return -1
end
function xx.arrayContains(array, item)
    for i = 1, xx.arrayCount(array) do
        if item == array[i] then
            return true
        end
    end
    return false
end
function xx.arraySlice(array, start, stop)
    local count = xx.arrayCount(array)
    start = start and (start < 0 and count + start + 1 or start) or 1
    stop = stop and (stop < 0 and count + stop + 1 or stop) or count
    local j = 1
    local result = {}
    for i = start < 1 and 1 or start, stop > count and count or stop do
        result[j] = array[i]
        j = j + 1
    end
    return result
end
function xx.arrayMerge(array, ...)
    local index = xx.arrayCount(array) + 1
    local arrayList = {...}
    for i = 1, xx.arrayCount(arrayList) do
        if xx.isTable(arrayList[i]) then
            for j = 1, xx.arrayCount(arrayList[i]) do
                array[index] = arrayList[i][j]
                index = index + 1
            end
        end
    end
    return array
end
coroutine.isyieldable = function()
    local _, isMain = coroutine.running()
    return not isMain
end
local Class = {__nameClassMap = {}}
xx.Class = Class
function Class.getter(instance, key)
    if not xx.isNil(instance.__proxy[key]) then
        return instance.__proxy[key]
    end
    if not xx.isNil(instance.__class) and not xx.isNil(instance.__class[key]) then
        return instance.__class[key]
    end
end
function Class.setter(instance, key, value)
    instance.__proxy[key] = value
end
function Class.isClass(class)
    return xx.isTable(class) and xx.isString(class.__className) and xx.isTable(class.__metatable)
end
function Class.isInstance(instance)
    return xx.isTable(instance) and Class.isClass(instance.__class)
end
function Class.getClass(name)
    return Class.__nameClassMap[name]
end
function Class.instanceOf(instance, class)
    if Class.isInstance(instance) then
        local loopClass = instance.__class
        while loopClass do
            if loopClass == class then
                return true
            end
            loopClass = loopClass.__superClass
        end
    end
    return false
end
xx.instanceOf = Class.instanceOf
local __instanceMetatable = {
    __index = function(instance, key)
        local getter = Class.getter(instance, "getter")
        if xx.isFunction(getter) then
            return getter(instance, key)
        end
        return Class.getter(instance, key)
    end,
    __newindex = function(instance, key, value)
        local setter = Class.getter(instance, "setter")
        if xx.isFunction(setter) then
            setter(instance, key, value)
        else
            Class.setter(instance, key, value)
        end
    end,
    __call = function(instance, ...)
        local callFunc = instance.call
        if xx.isFunction(callFunc) then
            return callFunc(instance, ...)
        end
    end,
    __add = function(instance, target)
        local addFunc = instance.add
        if xx.isFunction(addFunc) then
            return addFunc(instance, target)
        end
    end,
    __sub = function(instance, target)
        local subFunc = instance.sub
        if xx.isFunction(subFunc) then
            return subFunc(instance, target)
        end
    end,
    __eq = function(instance, target)
        local equalToFunc = instance.equalTo
        if xx.isFunction(equalToFunc) then
            return equalToFunc(instance, target)
        end
    end,
    __lt = function(instance, target)
        local lessThanFunc = instance.lessThan
        if xx.isFunction(lessThanFunc) then
            return lessThanFunc(instance, target)
        end
    end,
    __le = function(instance, target)
        local lessEqualFunc = instance.lessEqual
        if xx.isFunction(lessEqualFunc) then
            return lessEqualFunc(instance, target)
        end
    end,
    __tostring = function(instance)
        local toStringFunc = instance.toString
        if xx.isFunction(toStringFunc) then
            return toStringFunc(instance)
        end
    end
}
function Class.newClass(name, super)
    local class =
        setmetatable(
        {__className = name, __superClass = super, __metatable = __instanceMetatable},
        {
            __index = super,
            __call = function(class, ...)
                local instance =
                    setmetatable({__class = class, __proxy = {}, __isConstructed = false}, class.__metatable)
                local ctorList = {}
                local ctoredList = {}
                local loopClass = class
                while loopClass do
                    local ctor = rawget(loopClass, "ctor")
                    if xx.isFunction(ctor) then
                        xx.arrayPush(ctorList, ctor)
                    end
                    local ctored = rawget(loopClass, "ctored")
                    if xx.isFunction(ctored) then
                        xx.arrayPush(ctoredList, ctored)
                    end
                    loopClass = loopClass.__superClass
                end
                for index = xx.arrayCount(ctorList), 1, -1 do
                    ctorList[index](instance, ...)
                end
                for index = 1, xx.arrayCount(ctoredList) do
                    ctoredList[index](instance, ...)
                end
                instance.__isConstructed = true
                return instance
            end
        }
    )
    Class.__nameClassMap[name] = class
    return class
end
xx.ObjectEx = Class.newClass("ObjectEx")
function xx.ObjectEx:ctor()
    self.uid = xx.newUID()
end
function xx.ObjectEx:toString()
    return self.uid
end
function xx.ObjectEx:setter(key, value)
    local oldValue = self[key]
    if oldValue == value then
        return
    end
    Class.setter(self, key, value)
    if self.__isConstructed and xx.isFunction(self.onDynamicChanged) then
        self:onDynamicChanged(key, value, oldValue)
    end
end
setmetatable(
    Class,
    {
        __call = function(_, name, super)
            return Class.newClass(name, super or xx.ObjectEx)
        end
    }
)
GIdentifiers = GIdentifiers or {}
GIdentifiers.e_changed = "e_changed"
GIdentifiers.e_complete = "e_complete"
GIdentifiers.e_root_changed = "e_root_changed"
GIdentifiers.e_add = "e_add"
GIdentifiers.e_added = "e_added"
GIdentifiers.e_remove = "e_remove"
GIdentifiers.e_removed = "e_removed"
GIdentifiers.e_enter = "e_enter"
GIdentifiers.e_exit = "e_exit"
GIdentifiers.e_down = "e_down"
GIdentifiers.e_up = "e_up"
GIdentifiers.e_click = "e_click"
GIdentifiers.e_drag_begin = "e_drag_begin"
GIdentifiers.e_drag_move = "e_drag_move"
GIdentifiers.e_drag_end = "e_drag_end"
GIdentifiers.e_particle_complete = "e_particle_complete"
GIdentifiers.ni_load = "ni_load"
GIdentifiers.ni_load_stop = "ni_load_stop"
GIdentifiers.load_type_binary = "binary"
GIdentifiers.load_type_string = "string"
GIdentifiers.load_type_texture = "texture"
GIdentifiers.load_type_sprite = "sprite"
GIdentifiers.load_type_audioclip = "audioclip"
GIdentifiers.load_type_assetbundle = "assetbundle"
GIdentifiers.ni_timer_new = "ni_timer_new"
GIdentifiers.ni_timer_pause = "ni_timer_pause"
GIdentifiers.ni_timer_resume = "ni_timer_resume"
GIdentifiers.ni_timer_stop = "ni_timer_stop"
GIdentifiers.ni_timer_rate = "ni_timer_rate"
GIdentifiers.ni_tween_new = "ni_tween_new"
GIdentifiers.ni_tween_stop = "ni_tween_stop"
GIdentifiers.nb_lauch = "nb_lauch"
GIdentifiers.nb_initialize = "nb_initialize"
GIdentifiers.nb_timer = "nb_timer"
GIdentifiers.nb_pause = "nb_pause"
GIdentifiers.nb_resume = "nb_resume"
local JSON = {escape = "\\", comma = ",", colon = ":", null = "null"}
xx.JSON = JSON
function JSON.toString(data, toArray, toFunction, __tableList, __keyList)
    if not xx.isBoolean(toArray) then
        toArray = true
    end
    if not xx.isBoolean(toFunction) then
        toFunction = false
    end
    if not xx.isTable(__tableList) then
        __tableList = {}
    end
    local dataType = type(data)
    if "function" == dataType then
        return toFunction and '"Function"' or nil
    end
    if "string" == dataType then
        data = string.gsub(data, "\\", "\\\\")
        data = string.gsub(data, '"', '\\"')
        return '"' .. data .. '"'
    end
    if "number" == dataType then
        return tostring(data)
    end
    if "boolean" == dataType then
        return data and "true" or "false"
    end
    if "table" == dataType then
        xx.arrayPush(__tableList, data)
        local result
        if toArray and JSON.isArray(data) then
            result = "["
            for i = 1, xx.arrayCount(data) do
                if xx.isTable(v) and xx.arrayContains(__tableList, v) then
                    print("json loop refs warning : " .. JSON.toString(xx.arrayPush(xx.arraySlice(__keyList), k)))
                else
                    local valueString =
                        JSON.toString(
                        data[i],
                        toArray,
                        toFunction,
                        xx.arraySlice(__tableList),
                        __keyList and xx.arrayPush(xx.arraySlice(__keyList), i) or {i}
                    )
                    result = result .. (i > 1 and "," or "") .. (valueString or JSON.null)
                end
            end
            result = result .. "]"
        else
            result = "{"
            local index = 0
            for k, v in pairs(data) do
                if xx.isTable(v) and xx.arrayContains(__tableList, v) then
                    print("json loop refs warning : " .. JSON.toString(xx.arrayPush(xx.arraySlice(__keyList), k)))
                else
                    local valueString =
                        JSON.toString(
                        v,
                        toArray,
                        toFunction,
                        xx.arraySlice(__tableList),
                        __keyList and xx.arrayPush(xx.arraySlice(__keyList), k) or {k}
                    )
                    if valueString then
                        result = result .. (index > 0 and "," or "") .. ('"' .. k .. '":') .. valueString
                        index = index + 1
                    end
                end
            end
            result = result .. "}"
        end
        return result
    end
end
JSON.isArray = function(target)
    if xx.isTable(target) then
        for k, v in pairs(target) do
            if xx.isString(k) then
                return false
            end
        end
        return true
    end
    return false
end
JSON.toJSON = function(text)
    if '"' == string.sub(text, 1, 1) and '"' == string.sub(text, -1, -1) then
        return string.sub(JSON.findMeta(text), 2, -2)
    end
    local lowerText = string.lower(text)
    if "false" == lowerText then
        return false
    elseif "true" == lowerText then
        return true
    end
    if JSON.null == lowerText then
        return
    end
    local number = tonumber(text)
    if number then
        return number
    end
    if "[" == string.sub(text, 1, 1) and "]" == string.sub(text, -1, -1) then
        local remain = string.gsub(text, "[\r\n]+", "")
        remain = string.sub(remain, 2, -2)
        local array, index, value = {}, 1
        while #remain > 0 do
            value, remain = JSON.findMeta(remain)
            if value then
                value = JSON.toJSON(value)
                array[index] = value
                index = index + 1
            end
        end
        return array
    end
    if "{" == string.sub(text, 1, 1) and "}" == string.sub(text, -1, -1) then
        local remain = string.gsub(text, "[\r\n]+", "")
        remain = string.sub(remain, 2, -2)
        local key, value
        local map = {}
        while #remain > 0 do
            key, remain = JSON.findMeta(remain)
            value, remain = JSON.findMeta(remain)
            if key and #key > 0 and value then
                key = JSON.toJSON(key)
                value = JSON.toJSON(value)
                if key and value then
                    map[key] = value
                end
            end
        end
        return map
    end
end
JSON.findMeta = function(text)
    local stack = {}
    local index = 1
    local lastChar = nil
    while index <= #text do
        local char = string.sub(text, index, index)
        if '"' == char then
            if char == lastChar then
                xx.arrayPop(stack)
                lastChar = #stack > 0 and stack[#stack] or nil
            else
                xx.arrayPush(stack, char)
                lastChar = char
            end
        elseif '"' ~= lastChar then
            if "{" == char then
                xx.arrayPush(stack, "}")
                lastChar = char
            elseif "[" == char then
                xx.arrayPush(stack, "]")
                lastChar = char
            elseif "}" == char or "]" == char then
                assert(char == lastChar, text .. " " .. index .. " not expect " .. char .. "<=>" .. lastChar)
                xx.arrayPop(stack)
                lastChar = #stack > 0 and stack[#stack] or nil
            elseif JSON.comma == char or JSON.colon == char then
                if not lastChar then
                    return string.sub(text, 1, index - 1), string.sub(text, index + 1)
                end
            end
        elseif JSON.escape == char then
            text = string.sub(text, 1, index - 1) .. string.sub(text, index + 1)
        end
        index = index + 1
    end
    return string.sub(text, 1, index - 1), string.sub(text, index + 1)
end
function xx.bezier(percent, ...)
    local values = {...}
    local count = xx.arrayCount(values) - 1
    while count > 0 do
        for i = 1, count do
            values[i] = values[i] + (values[i + 1] - values[i]) * percent
        end
        count = count - 1
    end
    return 0 == count and values[1] or 0
end
function xx.getCallback(...)
    local args = {...}
    local count = xx.arrayCount(args)
    if count > 0 then
        if xx.instanceOf(args[count], xx.Callback) then
            return args[count]
        end
    end
end
function xx.getPromise(...)
    local args = {...}
    local count = xx.arrayCount(args)
    if count > 0 then
        if xx.instanceOf(args[count], xx.Promise) then
            return args[count]
        end
    end
end
function xx.getSignal(...)
    local args = {...}
    local count = xx.arrayCount(args)
    if count > 0 then
        if xx.instanceOf(args[count], xx.Signal) then
            return args[count]
        end
    end
end
local __singleton = {}
function xx.addInstance(instance)
    if instance and instance.__class and instance.__class.__className then
        __singleton[instance.__class.__className] = instance
    end
    return instance
end
function xx.delInstance(name)
    local instance = __singleton[name]
    __singleton[name] = nil
    return instance
end
function xx.getInstance(name)
    if name then
        if __singleton[name] then
            return __singleton[name]
        end
        local class = xx.Class.getClass(name)
        if class then
            local instance = class()
            __singleton[name] = instance
            return instance
        end
    end
end
local Bits
local Bit = xx.Class("Bit")
xx.Bit = Bit
Bit._bitMinMap = {1}
for i = 2, 64 do
    Bit._bitMinMap[i] = 2 * Bit._bitMinMap[i - 1]
end
Bit._caches = {}
Bit._numCaches = 0
function Bit.new(numBits, bit)
    ---@type Bits
    local bits
    if Bit._numCaches > 0 then
        bits = Bit._caches[Bit._numCaches]
        Bit._caches[Bit._numCaches] = nil
        Bit._numCaches = Bit._numCaches - 1
    else
        bits = {}
    end
    bits.numBits = numBits
    bit = bit or 0
    for i = 1, bits.numBits do
        bits[i] = bit
    end
    return bits
end
function Bit.clone(bits, beginBit, endBit)
    beginBit = beginBit or 1
    endBit = endBit or bits.numBits
    local copy
    if endBit >= beginBit then
        copy = Bit.new(endBit - beginBit + 1)
        for i = 1, copy.numBits do
            if i + beginBit - 1 > bits.numBits then
                break
            end
            copy[i] = bits[i + beginBit - 1]
        end
    else
        copy = Bit.new(beginBit - endBit + 1)
        for i = 1, copy.numBits do
            if beginBit - i + 1 > bits.numBits then
                break
            end
            copy[i] = bits[beginBit - i + 1]
        end
    end
    return copy
end
function Bit.cache(...)
    for _, bits in ipairs({...}) do
        xx.arrayInsert(Bit._caches, bits)
    end
end
function Bit.reset(bits, bit)
    bit = bit or 0
    for i = 1, bits.numBits do
        bits[i] = bit
    end
    return bits
end
function Bit.isEmpty(bits, beginBit, endBit)
    beginBit = beginBit or 1
    endBit = endBit or bits.numBits
    for i = beginBit, endBit do
        if 1 == bits[i] then
            return false
        end
    end
    return true
end
function Bit.intBits(value, numBits)
    numBits = numBits or 32
    local bits
    if value < 0 then
        bits = Bit.intBits(-value - 1, numBits)
        Bit.bitsNOT(bits)
        bits[numBits] = 1
    else
        bits = Bit.new(numBits)
        for i = numBits, 1, -1 do
            if Bit._bitMinMap[i] > 0 and value >= Bit._bitMinMap[i] then
                bits[i] = 1
                value = value - Bit._bitMinMap[i]
            elseif Bit._bitMinMap[i] < 0 and -value <= Bit._bitMinMap[i] then
                bits[i] = 1
                value = value + Bit._bitMinMap[i]
            end
        end
    end
    return bits
end
function Bit.decimalBits(value, numBits)
    local bits = Bit.new(64 == numBits and 64 or 32)
    if 0 == value then
        return bits
    end
    if value < 0 then
        bits[bits.numBits] = 1
        value = -value
    end
    local bitsAll = Bit.new(bits.numBits * 2)
    local beginBit, endBit
    for i = bits.numBits, 1, -1 do
        if Bit._bitMinMap[i] > 0 and value >= Bit._bitMinMap[i] then
            endBit = bits.numBits + 1 - i
            beginBit = beginBit or endBit
            bitsAll[endBit] = 1
            value = value - Bit._bitMinMap[i]
        elseif Bit._bitMinMap[i] < 0 and -value <= Bit._bitMinMap[i] then
            endBit = bits.numBits + 1 - i
            beginBit = beginBit or endBit
            bitsAll[endBit] = 1
            value = value + Bit._bitMinMap[i]
        end
    end
    for i = 1, bits.numBits do
        value = value * 2
        if value >= 1 then
            endBit = bits.numBits + i
            beginBit = beginBit or endBit
            bitsAll[endBit] = 1
            value = value - 1
        end
        if 0 == value then
            break
        end
    end
    if beginBit and endBit then
        --- 指数偏移，指数位数，小数位数
        local offset, numExponents, numDecimals
        if 32 == bits.numBits then
            offset, numExponents, numDecimals = 127, 8, 23
        else
            offset, numExponents, numDecimals = 1023, 11, 52
        end
        local bitsExponent = Bit.intBits(offset + bits.numBits - beginBit, 12)
        for i = 1, numExponents do
            bits[numDecimals + i] = bitsExponent[i]
        end
        Bit.cache(bitsExponent)
        for i = numDecimals, 1, -1 do
            beginBit = beginBit + 1
            if beginBit > endBit then
                break
            end
            bits[i] = bitsAll[beginBit]
        end
        if beginBit < endBit and 1 == bitsAll[beginBit + 1] then
            local carry
            bits, carry = Bit.bitsPlusOnce(bits, 1, numDecimals)
            if carry then
                if 1 == bits[1] then
                    bits, carry = Bit.bitsPlusOnce(bits, 1, numDecimals)
                end
                for i = 1, numDecimals - 1 do
                    bits[i] = bits[i + 1]
                end
                bits[numDecimals] = carry and 1 or 0
                Bit.bitsPlusOnce(bits, numDecimals + 1, bits.numBits - 1)
            end
        end
    end
    Bit.cache(bitsAll)
    return bits
end
function Bit.bitsPlusOnce(bits, beginBit, endBit)
    for i = beginBit or 1, endBit or bits.numBits do
        if 1 == bits[i] then
            bits[i] = 0
        else
            bits[i] = 1
            return bits, false
        end
    end
    return bits, true
end
function Bit.number(bits, beginBit, endBit)
    beginBit = beginBit or 1
    endBit = endBit or bits.numBits
    if 1 == beginBit and 64 == endBit and 1 == bits[endBit] then
        return -Bit.number(Bit.bitsNOT(bits), beginBit, endBit) - 1
    end
    local value = 0
    for i = beginBit, endBit do
        if 1 == bits[i] then
            value = value + Bit._bitMinMap[i - beginBit + 1]
        end
    end
    return value
end
function Bit.decimal(bits)
    if Bit.isEmpty(bits) then
        return 0
    end
    --- 指数偏移，指数位数，小数位数
    local offset, numExponents, numDecimals
    if 32 == bits.numBits then
        offset, numExponents, numDecimals = 127, 8, 23
    else
        offset, numExponents, numDecimals = 1023, 11, 52
    end
    local exponent = Bit.number(bits, numDecimals + 1, bits.numBits - 1)
    local dotOffset = exponent - offset
    if dotOffset > bits.numBits or dotOffset < -bits.numBits then
        return 0
    end
    local int = 0
    if 0 == dotOffset then
        int = 1
    elseif dotOffset > 0 then
        local intBits = Bit.clone(bits, numDecimals - dotOffset + 1, numDecimals + 1)
        intBits[intBits.numBits] = 1
        int = Bit.number(intBits)
        Bit.cache(intBits)
    end
    local decimal, decimalBits = 0
    if 0 == dotOffset then -- 1.xxxxx
        decimalBits = Bit.clone(bits, numDecimals, 1)
    elseif dotOffset > 0 then --xx.xxxxx
        if numDecimals > dotOffset then
            decimalBits = Bit.clone(bits, numDecimals - dotOffset, 1)
        end
    else -- 0.xxxxx
        decimalBits = Bit.clone(bits, numDecimals - dotOffset, 1)
        decimalBits[-dotOffset] = 1
        for i = 1, -dotOffset - 1 do
            decimalBits[i] = 0
        end
    end
    if decimalBits then
        local bitValue = 0.5
        for i = 1, bits.numBits do
            if 1 == decimalBits[i] then
                decimal = decimal + bitValue
            end
            bitValue = bitValue / 2
        end
        Bit.cache(decimalBits)
    end
    local value = int + decimal
    return 1 == bits[bits.numBits] and -value or value
end
function Bit.int(value, numBits)
    numBits = numBits or 32
    if numBits < 64 then
        local bits = Bit.intBits(value, numBits)
        if 1 == bits[bits.numBits] then
            value = -Bit.number(Bit.bitsNOT(bits)) - 1
        else
            value = 0
            for i = 1, bits.numBits do
                if 1 == bits[i] then
                    value = value + Bit._bitMinMap[i]
                end
            end
        end
        Bit.cache(bits)
    end
    return value
end
function Bit.uint(value, numBits)
    numBits = numBits or 32
    local bits = Bit.intBits(value, numBits)
    value = 0
    for i = 1, bits.numBits do
        if 1 == bits[i] and Bit._bitMinMap[i] > 0 then
            value = value + Bit._bitMinMap[i]
        end
    end
    Bit.cache(bits)
    return value
end
function Bit.bitsNOT(bits)
    for i = 1, bits.numBits do
        bits[i] = 1 == bits[i] and 0 or 1
    end
    return bits
end
function Bit.bitsAND(aBits, bBits, bits)
    for i = 1, bits.numBits do
        bits[i] = (1 == aBits[i] and 1 == bBits[i]) and 1 or 0
    end
    return bits
end
function Bit.bitsOR(aBits, bBits, bits)
    for i = 1, bits.numBits do
        bits[i] = (0 == aBits[i] and 0 == bBits[i]) and 0 or 1
    end
    return bits
end
function Bit.bitsXOR(aBits, bBits, bits)
    for i = 1, bits.numBits do
        bits[i] = aBits[i] == bBits[i] and 0 or 1
    end
    return bits
end
function Bit.bitsRotate(bits, offset)
    local copy = Bit.clone(bits)
    Bit.reset(bits)
    offset = offset and -offset or 0
    for i = 1, bits.numBits do
        if 1 == copy[i] then
            i = i + offset
            while i < 1 do
                i = i + bits.numBits
            end
            while i > bits.numBits do
                i = i - bits.numBits
            end
            bits[i] = 1
        end
    end
    Bit.cache(copy)
    return bits
end
function Bit.bitsShift(bits, offset)
    local copy = Bit.clone(bits)
    Bit.reset(bits)
    offset = offset and -offset or 0
    for i = 1, bits.numBits do
        if 1 == copy[i] then
            i = i + offset
            if i >= 1 and i <= bits.numBits then
                bits[i] = 1
            end
        end
    end
    Bit.cache(copy)
    return bits
end
function Bit.bitsAShift(bits, offset)
    if 0 == bits[bits.numBits] or offset <= 0 then
        return Bit.bitsShift(bits, offset)
    end
    offset = offset and -offset or 0
    local numBits = bits.numBits - 1
    local copy = Bit.clone(bits)
    Bit.reset(bits, 1)
    for i = 1, numBits do
        if 0 == copy[i] then
            i = i + offset
            if i >= 1 and i <= numBits then
                bits[i] = 0
            end
        end
    end
    Bit.cache(copy)
    return bits
end
function Bit.bnot(value, numBits)
    numBits = numBits or 32
    local bits = Bit.bitsNOT(Bit.intBits(value, numBits))
    value = Bit.number(bits)
    Bit.cache(bits)
    return value
end
function Bit.band(a, b, numBits)
    numBits = numBits or 32
    local aBits = Bit.intBits(a, numBits)
    local bBits = Bit.intBits(b, numBits)
    local bits = Bit.bitsAND(aBits, bBits, Bit.new(numBits))
    a = Bit.number(bits)
    Bit.cache(aBits, bBits, bits)
    return a
end
function Bit.bor(a, b, numBits)
    numBits = numBits or 32
    local aBits = Bit.intBits(a, numBits)
    local bBits = Bit.intBits(b, numBits)
    local bits = Bit.bitsOR(aBits, bBits, Bit.new(numBits))
    a = Bit.number(bits)
    Bit.cache(aBits, bBits, bits)
    return a
end
function Bit.bxor(a, b, numBits)
    numBits = numBits or 32
    local aBits = Bit.intBits(a, numBits)
    local bBits = Bit.intBits(b, numBits)
    local bits = Bit.bitsXOR(aBits, bBits, Bit.new(numBits))
    a = Bit.number(bits)
    Bit.cache(aBits, bBits, bits)
    return a
end
function Bit.rotate(value, offset, numBits)
    numBits = numBits or 32
    local bits = Bit.intBits(value, numBits)
    if not offset or 0 == offset % bits.numBits then
        value = Bit.number(bits)
    else
        value = Bit.number(Bit.bitsRotate(bits, offset))
    end
    Bit.cache(bits)
    return value
end
function Bit.shift(value, offset, numBits)
    numBits = numBits or 32
    local bits = Bit.intBits(value, numBits)
    if not offset or 0 == offset then
        value = Bit.number(bits)
    else
        value = Bit.number(Bit.bitsShift(bits, offset))
    end
    Bit.cache(bits)
    return value
end
function Bit.ashift(value, offset, numBits)
    numBits = numBits or 32
    if value >= 0 or not offset or offset <= 0 then
        return Bit.shift(value, offset, numBits)
    end
    local bits = Bit.intBits(value, numBits)
    value = Bit.number(Bit.bitsAShift(bits, offset))
    Bit.cache(bits)
    return value
end
local PBField = xx.Class("PBField")
function PBField:ctor(name, package, type, id)
    self.optional, self.required, self.repeated, self.packed, self.map = true, false, false, true, false
    self.name, self.package, self.type, self.id, self.wireType = name, package, type, id
end
local PBMessage = xx.Class("PBMessage")
function PBMessage:ctor(root, name)
    self.fieldIDs = {}
    self.fieldIDMap = {}
    self.root = root
    self.name = name
end
local PBEnum = xx.Class("PBEnum")
function PBEnum:ctor(root, name)
    self.idNameMap = {}
    self.nameIDMap = {}
    self.root = root
    self.name = name
end
local PBRoot = xx.Class("PBRoot")
function PBRoot:ctor(package)
    self.enumMap = {}
    self.messageMap = {}
    self.package = package
end
local PBWriter = xx.Class("PBWriter")
function PBWriter:ctor()
    self.buffer = {}
    self.length = 0
end
PBWriter._pool = {}
function PBWriter.instance()
    if #PBWriter._pool > 0 then
        local writer = PBWriter._pool[#PBWriter._pool]
        PBWriter._pool[#PBWriter._pool] = nil
        return writer
    end
    return PBWriter()
end
function PBWriter:destory()
    self.length = 0
    PBWriter._pool[#PBWriter._pool + 1] = self
end
function PBWriter:write(writer)
    for i = 1, writer.length do
        self.length = self.length + 1
        self.buffer[self.length] = writer.buffer[i]
    end
    return self
end
function PBWriter:_varint(value, numBits)
    numBits = numBits or 32
    if value >= 0 then
        while value > 127 do
            self.length = self.length + 1
            self.buffer[self.length] = xx.Bit.uint(xx.Bit.bor(xx.Bit.band(value, 127, numBits), 128, numBits), numBits)
            value = xx.Bit.shift(value, 7, numBits)
        end
        self.length = self.length + 1
        self.buffer[self.length] = value
    else -- 写入负数
        for i = 1, 9 do
            self.length = self.length + 1
            self.buffer[self.length] = xx.Bit.uint(xx.Bit.bor(xx.Bit.band(value, 127, 64), 128, 64), 64)
            value = xx.Bit.ashift(value, 7, 64)
        end
        self.length = self.length + 1
        self.buffer[self.length] = 1
    end
end
function PBWriter:_fixed(bits)
    local byteBits = xx.Bit.new(8)
    for i = 1, bits.numBits do
        if 0 == i % 8 then
            byteBits[8] = bits[i]
            self.length = self.length + 1
            self.buffer[self.length] = xx.Bit.uint(xx.Bit.number(byteBits), 8)
        else
            byteBits[i % 8] = bits[i]
        end
    end
    xx.Bit.cache(byteBits)
end
function PBWriter:int32(value)
    self:_varint(value)
    return self
end
function PBWriter:uint32(value)
    self:_varint(value)
    return self
end
function PBWriter:sint32(value)
    self:uint32(xx.Bit.bxor(xx.Bit.shift(value, -1), xx.Bit.ashift(value, 31)))
    return self
end
function PBWriter:int64(value)
    self:_varint(value, 64)
    return self
end
function PBWriter:uint64(value)
    self:_varint(value, 64)
    return self
end
function PBWriter:sint64(value)
    self:uint64(xx.Bit.bxor(xx.Bit.shift(value, -1, 64), xx.Bit.ashift(value, 63, 64), 64))
    return self
end
function PBWriter:bool(value)
    self.length = self.length + 1
    self.buffer[self.length] = value and 1 or 0
    return self
end
function PBWriter:fixed32(value)
    local bits = xx.Bit.intBits(value)
    self:_fixed(bits)
    xx.Bit.cache(bits)
    return self
end
function PBWriter:sfixed32(value)
    self:fixed32(value)
    return self
end
function PBWriter:float(value)
    local bits = xx.Bit.decimalBits(value)
    self:_fixed(bits)
    xx.Bit.cache(bits)
    return self
end
function PBWriter:fixed64(value)
    local bits = xx.Bit.intBits(value, 64)
    self:_fixed(bits)
    xx.Bit.cache(bits)
    return self
end
function PBWriter:sfixed64(value)
    self:fixed64(value)
    return self
end
function PBWriter:double(value)
    local bits = xx.Bit.decimalBits(value, 64)
    self:_fixed(bits)
    xx.Bit.cache(bits)
    return self
end
function PBWriter:string(value)
    self:uint32(#value)
    for i = 1, #value do
        self.length = self.length + 1
        self.buffer[self.length] = string.byte(value, i)
    end
    return self
end
function PBWriter:bytes(value)
    return self:string(value)
end
local PBReader = xx.Class("PBReader")
function PBReader:ctor(buffer)
    self.buffer = buffer
    self.length = #buffer
    self.position = 1
end
function PBReader:_varint(bits)
    local offset, byte, byteBits = 1
    repeat
        byte = string.byte(self.buffer, self.position)
        self.position = self.position + 1
        byteBits = xx.Bit.intBits(byte, 8)
        for i = 1, 7 do
            bits[offset] = byteBits[i]
            offset = offset + 1
        end
        xx.Bit.cache(byteBits)
    until byte <= 127
    return bits
end
function PBReader:_fixed(bits)
    local offset, byte, byteBits = 1
    for i = 1, bits.numBits / 8 do
        byte = string.byte(self.buffer, self.position)
        self.position = self.position + 1
        byteBits = xx.Bit.intBits(byte, 8)
        for j = 1, 8 do
            bits[offset] = byteBits[j]
            offset = offset + 1
        end
        xx.Bit.cache(byteBits)
    end
    return bits
end
function PBReader:int32()
    local bits = self:_varint(xx.Bit.new(64))
    local value = xx.Bit.int(xx.Bit.number(bits))
    xx.Bit.cache(bits)
    return value
end
function PBReader:uint32()
    local bits = self:_varint(xx.Bit.new(32))
    local value = xx.Bit.uint(xx.Bit.number(bits))
    xx.Bit.cache(bits)
    return value
end
function PBReader:sint32()
    local value = self:uint32()
    return xx.Bit.int(xx.Bit.bxor(xx.Bit.shift(value, 1), -xx.Bit.band(value, 1)))
end
function PBReader:int64()
    local bits = self:_varint(xx.Bit.new(64))
    local value = xx.Bit.number(bits)
    xx.Bit.cache(bits)
    return value
end
function PBReader:uint64()
    local bits = self:_varint(xx.Bit.new(64))
    local value = xx.Bit.uint(xx.Bit.number(bits), 64)
    xx.Bit.cache(bits)
    return value
end
function PBReader:sint64()
    local value = self:uint64()
    return xx.Bit.bxor(xx.Bit.shift(value, 1, 64), -xx.Bit.band(value, 1, 64), 64)
end
function PBReader:bool()
    local value = string.byte(self.buffer, self.position)
    self.position = self.position + 1
    return 0 ~= value
end
function PBReader:fixed32()
    local bits = self:_fixed(xx.Bit.new(32))
    local value = xx.Bit.uint(xx.Bit.number(bits))
    xx.Bit.cache(bits)
    return value
end
function PBReader:sfixed32()
    return self:fixed32()
end
function PBReader:float()
    local bits = self:_fixed(xx.Bit.new(32))
    local value = xx.Bit.decimal(bits)
    xx.Bit.cache(bits)
    return value
end
function PBReader:fixed64()
    local bits = self:_fixed(xx.Bit.new(64))
    local value = xx.Bit.uint(xx.Bit.number(bits), 64)
    xx.Bit.cache(bits)
    return value
end
function PBReader:sfixed64()
    return self:fixed64()
end
function PBReader:double()
    local bits = self:_fixed(xx.Bit.new(64))
    local value = xx.Bit.decimal(bits, 64)
    xx.Bit.cache(bits)
    return value
end
function PBReader:string()
    local length = self:uint32()
    local value = string.sub(self.buffer, self.position, self.position + length - 1)
    self.position = self.position + length
    return value
end
function PBReader:bytes()
    return self:string()
end
local PBParser = xx.Class("PBParser")
function PBParser:ctor(content)
    self.index = 1
    self.lines = {}
    self.numLines = 0
    for line in string.gmatch(content, "[^\r\n]+") do
        if #string.gsub(line, "%s+", "") > 0 then
            self.numLines = self.numLines + 1
            self.lines[self.numLines] = line
        end
    end
end
function PBParser:readLine()
    self.index = self.index + 1
    return self.lines[self.index - 1]
end
function PBParser:isClosureLine(line)
    return nil ~= string.match(line, "}")
end
function PBParser:isPackageLine(line)
    return nil ~= string.match(line, "^package ")
end
function PBParser:getPackageName(line)
    return string.gsub(string.match(line, "[^;]+", #"package " + 1), "%s+", "")
end
function PBParser:isMessageLine(line)
    return nil ~= string.match(line, "^message ")
end
function PBParser:getMessageName(line)
    return string.gsub(string.match(line, "[^%s{]+", #"message " + 1), "%s+", "")
end
function PBParser:getMessageField(line)
    local before = string.match(line, "[^=]+")
    if not before then
        return
    end
    local after = string.match(line, "=[^;]+")
    if not after then
        return
    end
    before = string.gsub(before, "%s+$", "")
    local name = string.match(before, "[^%s]+$")
    before = string.gsub(before, "%s*" .. name .. "%s*$", "")
    local repeated = nil ~= string.match(before, "repeated")
    if repeated then
        before = string.gsub(before, "%s*repeated%s*", "")
    end
    local required = nil ~= string.match(before, "required")
    if required then
        before = string.gsub(before, "%s*required%s*", "")
    end
    local optional = nil ~= string.match(before, "optional") or not required
    if optional then
        before = string.gsub(before, "%s*optional%s*", "")
    end
    local package, type, keyPackage, keyType
    local map = string.match(before, "map%s*<%s*[^%s]+%s*,%s*[^%s]+%s*>")
    if map then -- map
        map = string.gsub(string.gsub(map, "map%s*<", ""), "[%s>]", "")
        keyType = string.match(map, "[^,]+")
        type = string.match(map, "[^,]+$")
        map = true
        keyPackage = string.match(keyType, "[^\\.]+$")
        if keyPackage == keyType then
            keyPackage = nil
        else
            keyType, keyPackage = keyPackage, string.gsub(keyType, "." .. keyPackage .. "$", "")
        end
    else -- 基础类型，消息，枚举
        type = string.match(before, "[^%s]+$")
        if not type then
            return
        end
        map = false
    end
    package = string.match(type, "[^\\.]+$")
    if package == type then
        package = nil
    else
        type, package = package, string.gsub(type, "." .. package .. "$", "")
    end
    local id = string.match(after, "%d+")
    if not id then
        return
    end
    id = tonumber(id)
    local packed = nil == string.match(line, "packed%s*=%s*false")
    local field = PBField(name, package, type, id)
    field.optional = optional
    field.required = required
    field.repeated = repeated
    field.packed = packed
    field.map = map
    if map then
        field.keyPackage = keyPackage
        field.keyType = keyType
    end
    return field
end
function PBParser:isEnumLine(line)
    return nil ~= string.match(line, "^enum ")
end
function PBParser:getEnumName(line)
    return string.gsub(string.match(line, "[^%s{]+", #"enum " + 1), "%s+", "")
end
function PBParser:getEnumItem(line)
    local name = string.match(line, "[^=]+")
    if not name then
        return
    end
    local id = string.match(line, "=[^;]+")
    if not id then
        return
    end
    name = string.gsub(name, "%s+", "")
    id = string.gsub(id, "[=%s]+", "")
    return name, tonumber(id)
end
local Protobuf = xx.Class("Protobuf")
xx.Protobuf = Protobuf
function Protobuf:ctor()
end
Protobuf.pb_int32 = "int32"
Protobuf.pb_uint32 = "uint32"
Protobuf.pb_sint32 = "sint32"
Protobuf.pb_int64 = "int64"
Protobuf.pb_uint64 = "uint64"
Protobuf.pb_sint64 = "sint64"
Protobuf.pb_bool = "bool"
Protobuf.pb_fixed64 = "fixed64"
Protobuf.pb_sfixed64 = "sfixed64"
Protobuf.pb_double = "double"
Protobuf.pb_string = "string"
Protobuf.pb_bytes = "bytes"
Protobuf.pb_fixed32 = "fixed32"
Protobuf.pb_sfixed32 = "sfixed32"
Protobuf.pb_float = "float"
Protobuf.default = 0
Protobuf.typeDefaultMap = {bool = false, string = "", bytes = ""}
Protobuf.typeWireMap = {}
Protobuf.wireTypesMap = {
    [0] = {
        Protobuf.pb_int32,
        Protobuf.pb_uint32,
        Protobuf.pb_sint32,
        Protobuf.pb_int64,
        Protobuf.pb_uint64,
        Protobuf.pb_sint64,
        Protobuf.pb_bool
    },
    [1] = {Protobuf.pb_fixed64, Protobuf.pb_sfixed64, Protobuf.pb_double},
    [2] = {Protobuf.pb_string, Protobuf.pb_bytes},
    [5] = {Protobuf.pb_fixed32, Protobuf.pb_sfixed32, Protobuf.pb_float}
}
for wire, types in pairs(Protobuf.wireTypesMap) do
    for _, type in ipairs(types) do
        Protobuf.typeWireMap[type] = wire
    end
end
Protobuf.typePackedMap = {
    [Protobuf.pb_int32] = true,
    [Protobuf.pb_uint32] = true,
    [Protobuf.pb_sint32] = true,
    [Protobuf.pb_int64] = true,
    [Protobuf.pb_uint64] = true,
    [Protobuf.pb_sint64] = true,
    [Protobuf.pb_bool] = true,
    [Protobuf.pb_fixed64] = true,
    [Protobuf.pb_sfixed64] = true,
    [Protobuf.pb_double] = true,
    [Protobuf.pb_fixed32] = true,
    [Protobuf.pb_sfixed32] = true,
    [Protobuf.pb_float] = true
}
Protobuf.defaultPackageName = "xx_default_package"
Protobuf.packageRootMap = {[Protobuf.defaultPackageName] = PBRoot()}
function Protobuf.parse(source)
    ---@type PBRoot
    local root = Protobuf.packageRootMap[Protobuf.defaultPackageName]
    ---@type table<string,PBMessage[]>
    local packageMessagesMap = {[Protobuf.defaultPackageName] = {}}
    local parser = PBParser(source)
    while parser.index <= parser.numLines do
        local line = parser:readLine()
        if parser:isMessageLine(line) then -- 消息
            local message = PBMessage(root, parser:getMessageName(line))
            if not parser:isClosureLine(line) then
                Protobuf._parseMessage(parser, message)
            end
            root.messageMap[message.name] = message
            table.insert(packageMessagesMap[root.package or Protobuf.defaultPackageName], message)
        elseif parser:isEnumLine(line) then -- 枚举
            local enum = PBEnum(root, parser:getEnumName(line))
            if not parser:isClosureLine(line) then
                Protobuf._parseEnum(parser, enum)
            end
            root.enumMap[enum.name] = enum
        elseif parser:isPackageLine(line) then -- 包名
            local packageName = parser:getPackageName(line)
            if Protobuf.packageRootMap[packageName] then
                root = Protobuf.packageRootMap[packageName]
            else
                root = PBRoot(packageName)
                Protobuf.packageRootMap[packageName] = root
            end
            if not packageMessagesMap[packageName] then
                packageMessagesMap[packageName] = {}
            end
        end
    end
    for package, messages in pairs(packageMessagesMap) do
        if package == Protobuf.defaultPackageName then
            package = nil
        end
        for _, message in ipairs(messages) do
            for _, field in pairs(message.fieldIDMap) do
                if not Protobuf.typeWireMap[field.type] then
                    field.message = Protobuf.getMessage(field.package or package, field.type)
                    if not field.message then
                        field.enum = Protobuf.getEnum(field.package or package, field.type)
                    end
                end
                if field.map and not Protobuf.typeWireMap[field.keyType] then
                    field.keyMessage = Protobuf.getMessage(field.keyPackage or package, field.keyType)
                    if not field.keyMessage then
                        field.keyEnum = Protobuf.getEnum(field.keyPackage or package, field.keyType)
                    end
                end
            end
        end
    end
end
function Protobuf._parseMessage(parser, message)
    ---@type string
    local line
    ---@type PBField
    local field
    repeat
        line = parser:readLine()
        field = parser:getMessageField(line)
        if field then
            field.parent = message
            table.insert(message.fieldIDs, field.id)
            message.fieldIDMap[field.id] = field
        end
        if parser:isClosureLine(line) then
            return
        end
    until false
end
function Protobuf._parseEnum(parser, enum)
    local line, name, id
    repeat
        line = parser:readLine()
        name, id = parser:getEnumItem(line)
        if name and id then
            enum.idNameMap[id] = name
            enum.nameIDMap[name] = id
        end
        if parser:isClosureLine(line) then
            return
        end
    until false
end
function Protobuf.getMessage(packageName, messageName)
    if packageName then
        if Protobuf.packageRootMap[packageName] then
            return Protobuf.packageRootMap[packageName].messageMap[messageName]
        end
    else
        for packageName, root in pairs(Protobuf.packageRootMap) do
            if root.messageMap[messageName] then
                return root.messageMap[messageName]
            end
        end
    end
end
function Protobuf.getEnum(packageName, enumName)
    if packageName then
        if Protobuf.packageRootMap[packageName] then
            return Protobuf.packageRootMap[packageName].enumMap[enumName]
        end
    else
        for packageName, root in pairs(Protobuf.packageRootMap) do
            if root.enumMap[enumName] then
                return root.enumMap[enumName]
            end
        end
    end
end
function Protobuf.decode(packageName, messageName, buffer)
    ---@type PBReader
    local reader = PBReader(buffer)
    local message = Protobuf.getMessage(packageName, messageName)
    if message then
        return Protobuf._decode(message, reader, reader.length)
    end
end
function Protobuf._decode(message, reader, length)
    local value = {}
    ---@type number
    local id
    ---@type number
    local to = reader.position + length
    repeat
        id = Protobuf._decodeTag(reader:uint32()) -- 读 tag
        local field = message.fieldIDMap[id]
        if field.map then -- 表
            if not value[field.name] then
                value[field.name] = {}
            end
            local fieldTo = reader:uint32() + reader.position -- 表结束位置
            local mapID, k, v
            repeat
                mapID = Protobuf._decodeTag(reader:uint32())
                if 1 == mapID then
                    k = Protobuf._readFrom(reader, field.keyType, field.keyMessage, field.enum)
                elseif 2 == mapID then
                    v = Protobuf._readFrom(reader, field.type, field.message, field.enum)
                end
                if k and v then
                    value[field.name][k] = v
                    k, v = nil, nil
                end
            until reader.position >= fieldTo
        elseif field.repeated then --数组
            if not value[field.name] then
                value[field.name] = {}
            end
            local length = #value[field.name]
            if field.packed and (Protobuf.typePackedMap[field.type] or field.enum) then -- packed 格式
                local fieldTo = reader:uint32() + reader.position -- 数组结束位置
                repeat
                    length = length + 1
                    value[field.name][length] = Protobuf._readFrom(reader, field.type, field.message, field.enum)
                until reader.position >= fieldTo
            else
                length = length + 1
                value[field.name][length] = Protobuf._readFrom(reader, field.type, field.message, field.enum)
            end
        else
            value[field.name] = Protobuf._readFrom(reader, field.type, field.message, field.enum)
        end
    until reader.position >= to
    return value
end
function Protobuf._readFrom(reader, type, message, enum)
    if Protobuf.typeWireMap[type] then -- 基础类型
        return reader[type](reader)
    elseif message then -- 自定义类型
        return Protobuf._decode(message, reader, reader:uint32())
    elseif enum then -- 枚举
        return reader:int32()
    else -- 错误的类型
        error("protobuf decode can not find the type : " .. type)
    end
end
function Protobuf._decodeTag(tag)
    return xx.Bit.uint(xx.Bit.shift(tag, 3)), xx.Bit.uint(xx.Bit.band(tag, 3))
end
function Protobuf.encode(packageName, messageName, value)
    ---@type PBWriter
    local writer = PBWriter.instance()
    local message = Protobuf.getMessage(packageName, messageName)
    if message then
        Protobuf._encode(message, value, writer)
    end
    for i = writer.length + 1, #writer.buffer do
        writer.buffer[i] = nil
    end
    local result = string.char(unpack(writer.buffer))
    writer:destory()
    return result
end
function Protobuf._encode(message, value, writer)
    for fieldID, field in pairs(message.fieldIDMap) do
        if nil ~= value[field.name] then
            if field.map then -- 表
                for k, v in pairs(value[field.name]) do
                    if nil ~= v then
                        ---@type PBWriter
                        local fieldWriter = PBWriter.instance()
                        Protobuf._writeTo(fieldWriter, 1, field.keyType, field.keyMessage, field.keyEnum, k) -- 写入键
                        Protobuf._writeTo(fieldWriter, 2, field.type, field.message, field.enum, v) -- 写入值
                        writer:uint32(Protobuf._encodeTag(field.id, 2)) -- 写入 tag
                        writer:uint32(fieldWriter.length) -- 写入长度
                        writer:write(fieldWriter) -- 写入值
                        fieldWriter:destory()
                    end
                end
            elseif field.repeated then -- 数组
                if #value[field.name] > 0 then
                    if field.packed and (Protobuf.typePackedMap[field.type] or field.enum) then -- packed 格式
                        ---@type PBWriter
                        local fieldWriter = PBWriter.instance()
                        for _, v in ipairs(value[field.name]) do
                            if field.enum then
                                fieldWriter:int32(v) -- 写入值
                            else
                                fieldWriter[field.type](fieldWriter, v) -- 写入值
                            end
                        end
                        writer:uint32(Protobuf._encodeTag(field.id, 2)) -- 写入 tag
                        writer:uint32(fieldWriter.length) -- 写入长度
                        writer:write(fieldWriter) -- 写入值
                        fieldWriter:destory()
                    else
                        for _, v in ipairs(value[field.name]) do
                            Protobuf._writeTo(writer, field.id, field.type, field.message, field.enum, v)
                        end
                    end
                end
            else
                Protobuf._writeTo(writer, field.id, field.type, field.message, field.enum, value[field.name])
            end
        end
    end
end
function Protobuf._writeTo(writer, id, type, message, enum, value)
    if Protobuf.typeWireMap[type] then -- 基础类型
        writer:uint32(Protobuf._encodeTag(id, Protobuf.typeWireMap[type])) -- 写入 tag
        writer[type](writer, value) -- 写入值
    elseif message then -- 自定义类型
        ---@type PBWriter
        local fieldWriter = PBWriter.instance()
        Protobuf._encode(message, value, fieldWriter)
        writer:uint32(Protobuf._encodeTag(id, 2)) -- 写入 tag
        writer:uint32(fieldWriter.length) -- 写入长度
        writer:write(fieldWriter) -- 定入值
        fieldWriter:destory()
    elseif enum then -- 枚举
        writer:uint32(Protobuf._encodeTag(id, 0)) -- 写入 tag
        writer:int32(value) -- 写入值
    else -- 错误的类型
        error("protobuf encode can not find the type : " .. type)
    end
end
function Protobuf._encodeTag(id, wireType)
    return xx.Bit.uint(xx.Bit.bor(xx.Bit.shift(id, -3), wireType))
end
local Callback = xx.Class("xx.Callback")
xx.Callback = Callback
function Callback:ctor(handler, caller, ...)
    self.handler = handler
    self.caller = caller
    self.cache = xx.arrayPush({}, ...)
end
function Callback:equalTo(target)
    return self.handler == target.handler and self.caller == target.caller
end
function Callback:equalBy(handler, caller)
    return self.handler == handler and self.caller == caller
end
function Callback:call(...)
    local args = {...}
    if xx.arrayCount(self.cache) > 0 or xx.arrayCount(args) > 0 then
        if self.caller then
            return self.handler(self.caller, unpack(xx.arrayPush(xx.arraySlice(self.cache), ...)))
        else
            return self.handler(unpack(xx.arrayPush(xx.arraySlice(self.cache), ...)))
        end
    else
        if self.caller then
            return self.handler(self.caller)
        else
            return self.handler()
        end
    end
end
function Callback.getIndex(list, handler, caller)
    for index = 1, xx.arrayCount(list) do
        if list[index] and list[index]:equalBy(handler, caller) then
            return index
        end
    end
    return -1
end
local PromiseNext
local Promise = xx.Class("xx.Promise")
xx.Promise = Promise
Promise.state_pending = "pending"
Promise.state_fulfilled = "fulfilled"
Promise.state_rejected = "rejected"
Promise.queue = {}
Promise.promiseAsyncMap = {}
function Promise:ctor(handler)
    self._state = Promise.state_pending
    self._queue = {}
    xx.arrayPush(Promise.queue, self)
    if handler then
        local result = {pcall(handler, xx.Handler(self.resolve, self), xx.Handler(self.reject, self))}
        if not result[1] then
            self:reject(result[2])
        end
    end
end
function Promise:isPending()
    return Promise.state_pending == self._state
end
function Promise:isFulfilled()
    return Promise.state_fulfilled == self._state
end
function Promise:isRejected()
    return Promise.state_rejected == self._state
end
function Promise:resolve(...)
    if self:isPending() then
        self._state, self.value = Promise.state_fulfilled, xx.arrayPush({}, ...)
    end
end
function Promise:reject(reason)
    if self:isPending() then
        self._state, self.reason = Promise.state_rejected, reason
    end
end
function Promise:cancel()
    if self:isPending() then
        ---@type fun(promise:Promise)
        local catchNext
        catchNext = function(promise)
            if 0 == xx.arrayCount(promise._queue) then
                promise:catch()
            else
                for _, promiseNext in ipairs(promise._queue) do
                    catchNext(promiseNext.promise)
                end
            end
        end
        catchNext(self)
        self:reject("promise canceled")
    end
end
function Promise:next(onFulfilled, onRejected)
    local promise = Promise()
    xx.arrayPush(self._queue, {promise = promise, onFulfilled = onFulfilled, onRejected = onRejected})
    return promise
end
function Promise:catch(onRejected)
    return self:next(
        nil,
        onRejected or function(reason)
            end
    )
end
function Promise:finally(callback)
    return self:next(
        function(...)
            callback()
            return ...
        end,
        function(reason)
            pcall(callback)
            error(reason)
        end
    )
end
function Promise.all(...)
    local promises = xx.arrayPush({}, ...)
    return Promise(
        function(resolve, reject)
            local count = xx.arrayCount(promises)
            if count > 0 then
                local values = {}
                for i = 1, count do
                    promises[i]:next(
                        function(...)
                            values[i] = xx.arrayPush({}, ...)
                            count = count - 1
                            if 0 == count then
                                resolve(unpack(values))
                            end
                            return ...
                        end,
                        function(reason)
                            reject(reason)
                            error(reason)
                        end
                    )
                end
            else
                resolve()
            end
        end
    )
end
function Promise.race(...)
    local promises = xx.arrayPush({}, ...)
    return Promise(
        function(resolve, reject)
            for i = 1, xx.arrayCount(promises) do
                promises[i]:next(
                    function(...)
                        resolve(...)
                        return ...
                    end,
                    function(reason)
                        reject(reason)
                        error(reason)
                    end
                )
            end
        end
    )
end
function Promise.asyncLoop()
    for promise, handler in pairs(Promise.promiseAsyncMap) do
        Promise.promiseAsyncMap[promise] = nil
        local result = {
            coroutine.resume(
                coroutine.create(
                    function()
                        local result = {pcall(handler)}
                        if result[1] then -- 回调成功
                            if xx.instanceOf(result[2], Promise) then -- 返回异步
                                ---@type Promise
                                local promiseResult = result[2]
                                promiseResult:next(
                                    function(...) -- 异步完成
                                        promise:resolve(...)
                                        return ...
                                    end,
                                    function(reason) -- 异步拒绝
                                        promise:reject(reason)
                                        error(reason)
                                    end
                                )
                            else -- 返回值
                                xx.arrayRemoveAt(result, 1)
                                promise:resolve(unpack(result))
                            end
                        else -- 回调失败
                            promise:reject(result[2])
                        end
                    end
                )
            )
        }
        if not result[1] then
            promise:reject(result[2])
        end
    end
    for i = xx.arrayCount(Promise.queue), 1, -1 do
        local promise = Promise.queue[i]
        if promise:isFulfilled() or promise:isRejected() then
            xx.arrayRemoveAt(Promise.queue, i)
            for _, promiseNext in ipairs(promise._queue) do
                local result
                if promise:isFulfilled() then -- 完成回调
                    if promiseNext.onFulfilled then
                        result = {pcall(promiseNext.onFulfilled, unpack(promise.value))}
                    else
                        promiseNext.promise:resolve(unpack(promise.value))
                    end
                elseif promise:isRejected() then -- 拒绝回调
                    if promiseNext.onRejected then
                        result = {pcall(promiseNext.onRejected, promise.reason)}
                    else
                        promiseNext.promise:reject(promise.reason)
                    end
                end
                if result then -- 已回调
                    if result[1] then -- 回调成功
                        if xx.instanceOf(result[2], Promise) then -- 返回异步
                            ---@type Promise
                            local promiseResult = result[2]
                            promiseResult:next(
                                function(...) -- 异步完成
                                    promiseNext.promise:resolve(...)
                                    return ...
                                end,
                                function(reason) -- 异步拒绝
                                    promiseNext.promise:reject(reason)
                                    error(reason)
                                end
                            )
                        else -- 返回值
                            xx.arrayRemoveAt(result, 1)
                            promiseNext.promise:resolve(unpack(result))
                        end
                    else -- 回调失败
                        promiseNext.promise:reject(result[2])
                    end
                end
            end
            if promise:isRejected() and 0 == xx.arrayCount(promise._queue) then
                error(promise.reason)
            end
        end
    end
end
function Promise.async(handler, caller, ...)
    local promise = Promise()
    Promise.promiseAsyncMap[promise] = xx.Handler(handler, caller, ...)
    return promise
end
function Promise.await(promise)
    assert(coroutine.isyieldable(), "can not yield")
    local co = coroutine.running()
    promise:next(
        function(...) -- 完成
            local result = {coroutine.resume(co, true, ...)}
            if not result[1] then
                error(result[2])
            end
            return ...
        end,
        function(reason) -- 拒绝
            local result = {coroutine.resume(co, false, reason)}
            if not result[1] then
                error(result[2])
            end
            error(reason)
        end
    )
    local result = {coroutine.yield()}
    if not result[1] then -- 拒绝后直接结束协程
        error(result[2])
    end
    xx.arrayRemoveAt(result, 1)
    return unpack(result)
end
xx.async = Promise.async
xx.await = Promise.await
async = function(handler, caller, ...)
    if xx.isFunction(handler) then
        return Promise.async(handler, caller, ...)
    elseif xx.isTable(handler) and xx.isFunction(handler[1]) then
        return Promise.async(handler[1], unpack(xx.arraySlice(handler, 2)))
    end
    error "async only support function"
end
await = function(promise)
    if xx.instanceOf(promise, Promise) then
        return Promise.await(promise)
    elseif xx.isTable(promise) and xx.instanceOf(promise[1], Promise) then
        return Promise.await(promise[1])
    end
    error "await only support Promise"
end
local Signal = xx.Class("xx.Signal")
xx.Signal = Signal
function Signal:ctor(target)
    self.target = target
    self._callbacks = {}
    self._promises = {}
end
function Signal:addListener(handler, caller, ...)
    local callback
    local index = xx.Callback.getIndex(self._callbacks, handler, caller)
    if index < 0 then
        callback = xx.Callback(handler, caller, ...)
    else
        callback = self._callbacks[index]
        callback.cache = xx.arrayPush({}, ...)
        xx.arrayRemoveAt(self._callbacks, index)
    end
    callback["callOnce"] = false
    xx.arrayPush(self._callbacks, callback)
    return self
end
function Signal:once(handler, caller, ...)
    local callback
    local index = xx.Callback.getIndex(self._callbacks, handler, caller)
    if index < 0 then
        callback = xx.Callback(handler, caller, ...)
    else
        callback = self._callbacks[index]
        callback.cache = xx.arrayPush({}, ...)
        xx.arrayRemoveAt(self._callbacks, index)
    end
    callback["callOnce"] = true
    xx.arrayPush(self._callbacks, callback)
    return self
end
function Signal:removeListener(handler, caller)
    if not handler and not caller then
        xx.arrayClear(self._callbacks)
    elseif not handler then
        for i = xx.arrayCount(self._callbacks), 1, -1 do
            if self._callbacks[i].caller == caller then
                xx.arrayRemoveAt(self._callbacks, i)
            end
        end
    elseif not caller then
        for i = xx.arrayCount(self._callbacks), 1, -1 do
            if self._callbacks[i].handler == handler then
                xx.arrayRemoveAt(self._callbacks, i)
            end
        end
    else
        local index = xx.Callback.getIndex(self._callbacks, handler, caller)
        if index > 0 then
            xx.arrayRemoveAt(self._callbacks, index)
        end
    end
    return self
end
function Signal:hasListener(handler, caller)
    if not handler and not caller then
        return xx.arrayCount(self._callbacks) > 0
    elseif not handler then
        for i = xx.arrayCount(self._callbacks), 1, -1 do
            if self._callbacks[i].caller == caller then
                return true
            end
        end
    elseif not caller then
        for i = xx.arrayCount(self._callbacks), 1, -1 do
            if self._callbacks[i].handler == handler then
                return true
            end
        end
    else
        return xx.Callback.getIndex(self._callbacks, handler, caller) > 0
    end
    return false
end
function Signal:wait()
    local promise = xx.Promise()
    xx.arrayPush(self._promises, promise)
    return promise
end
function Signal:removeWait()
    for i = xx.arrayCount(self._promises), 1, -1 do
        local promise = self._promises[i]
        self._promises[i] = nil
        promise:cancel()
    end
end
function Signal:call(...)
    for i = xx.arrayCount(self._promises), 1, -1 do
        local promise = self._promises[i]
        self._promises[i] = nil
        promise:resolve(...)
    end
    local evt = xx.Event(self, nil, xx.arrayPush({}, ...))
    local copy = xx.arraySlice(self._callbacks)
    for _, callback in ipairs(copy) do
        if self:hasListener(callback.handler, callback.caller) then
            if callback["callOnce"] then
                xx.arrayRemove(self._callbacks, callback)
            end
            callback(evt)
            if evt.isStopImmediate then
                break
            end
        end
    end
    return self
end
local Event = xx.Class("xx.Event")
xx.Event = Event
function Event:ctor(target, type, args)
    self.target = target
    self.type = type
    self.args = args
    self.isStopBubble = false
    self.isStopImmediate = false
end
function Event:stopBubble()
    self.isStopBubble = true
end
function Event:stopImmediate()
    self.isStopImmediate = true
    self.isStopBubble = true
end
local EventDispatcher = xx.Class("EventDispatcher")
xx.EventDispatcher = EventDispatcher
function EventDispatcher:onDynamicChanged(key, newValue, oldValue)
    self(GIdentifiers.e_changed, key, newValue, oldValue)
end
function EventDispatcher:ctor()
    self._typeCallbacksMap = {}
    self._typePromisesMap = {}
end
function EventDispatcher:addEventListener(type, handler, caller, ...)
    local callback
    local callbacks
    if self._typeCallbacksMap[type] then
        callbacks = self._typeCallbacksMap[type]
        local index = xx.Callback.getIndex(callbacks, handler, caller)
        if index < 0 then
            callback = xx.Callback(handler, caller, ...)
        else
            callback = callbacks[index]
            callback.cache = xx.arrayPush({}, ...)
            xx.arrayRemoveAt(callbacks, index)
        end
    else
        callbacks = {}
        self._typeCallbacksMap[type] = callbacks
        callback = xx.Callback(handler, caller, ...)
    end
    callback["callOnce"] = false
    xx.arrayPush(callbacks, callback)
    return self
end
function EventDispatcher:once(type, handler, caller, ...)
    local callback
    local callbacks
    if self._typeCallbacksMap[type] then
        callbacks = self._typeCallbacksMap[type]
        local index = xx.Callback.getIndex(callbacks, handler, caller)
        if index < 0 then
            callback = xx.Callback(handler, caller, ...)
        else
            callback = callbacks[index]
            callback.cache = xx.arrayPush({}, ...)
            xx.arrayRemoveAt(callbacks, index)
        end
    else
        callbacks = {}
        self._typeCallbacksMap[type] = callbacks
        callback = xx.Callback(handler, caller, ...)
    end
    callback["callOnce"] = true
    xx.arrayPush(callbacks, callback)
    return self
end
function EventDispatcher:removeEventListener(type, handler, caller)
    if not type and not handler and not caller then
        xx.tableClear(self._typeCallbacksMap)
    elseif not type then
        if not handler then
            for loopType, callbacks in pairs(self._typeCallbacksMap) do
                for i = xx.arrayCount(callbacks), 1, -1 do
                    if callbacks[i].caller == caller then
                        xx.arrayRemoveAt(callbacks, i)
                    end
                end
                if 0 == xx.arrayCount(callbacks) then
                    self._typeCallbacksMap[loopType] = nil
                end
            end
        elseif not caller then
            for loopType, callbacks in pairs(self._typeCallbacksMap) do
                for i = xx.arrayCount(callbacks), 1, -1 do
                    if callbacks[i].handler == handler then
                        xx.arrayRemoveAt(callbacks, i)
                    end
                end
                if 0 == xx.arrayCount(callbacks) then
                    self._typeCallbacksMap[loopType] = nil
                end
            end
        else
            for loopType, callbacks in pairs(self._typeCallbacksMap) do
                local index = xx.Callback.getIndex(callbacks, handler, caller)
                if index > 0 then
                    if 1 == xx.arrayCount(callbacks) then
                        self._typeCallbacksMap[loopType] = nil
                    else
                        xx.arrayRemoveAt(callbacks, index)
                    end
                end
            end
        end
    elseif self._typeCallbacksMap[type] then
        if not handler and not caller then
            self._typeCallbacksMap[type] = nil
        else
            local callbacks = self._typeCallbacksMap[type]
            if not handler then
                for i = xx.arrayCount(callbacks), 1, -1 do
                    if callbacks[i].caller == caller then
                        xx.arrayRemoveAt(callbacks, i)
                    end
                end
                if 0 == xx.arrayCount(callbacks) then
                    self._typeCallbacksMap[type] = nil
                end
            elseif not caller then
                for i = xx.arrayCount(callbacks), 1, -1 do
                    if callbacks[i].handler == handler then
                        xx.arrayRemoveAt(callbacks, i)
                    end
                end
                if 0 == xx.arrayCount(callbacks) then
                    self._typeCallbacksMap[type] = nil
                end
            else
                local index = xx.Callback.getIndex(callbacks, handler, caller)
                if index > 0 then
                    if 1 == xx.arrayCount(callbacks) then
                        self._typeCallbacksMap[type] = nil
                    else
                        xx.arrayRemoveAt(callbacks, index)
                    end
                end
            end
        end
    end
    return self
end
function EventDispatcher:hasEventListener(type, handler, caller)
    if not type and not handler and not caller then
        return xx.tableCount(self._typeCallbacksMap) > 0
    end
    if not type then
        if not handler then
            for _, callbacks in pairs(self._typeCallbacksMap) do
                for i = xx.arrayCount(callbacks), 1, -1 do
                    if callbacks[i].caller == caller then
                        return true
                    end
                end
            end
        elseif not caller then
            for _, callbacks in pairs(self._typeCallbacksMap) do
                for i = xx.arrayCount(callbacks), 1, -1 do
                    if callbacks[i].handler == handler then
                        return true
                    end
                end
            end
        else
            for _, callbacks in pairs(self._typeCallbacksMap) do
                local index = xx.Callback.getIndex(callbacks, handler, caller)
                if index > 0 then
                    return true
                end
            end
        end
    elseif self._typeCallbacksMap[type] then
        if not handler and not caller then
            return true
        else
            local callbacks = self._typeCallbacksMap[type]
            if not handler then
                for i = xx.arrayCount(callbacks), 1, -1 do
                    if callbacks[i].caller == caller then
                        return true
                    end
                end
            elseif not caller then
                for i = xx.arrayCount(callbacks), 1, -1 do
                    if callbacks[i].handler == handler then
                        return true
                    end
                end
            else
                return xx.Callback.getIndex(callbacks, handler, caller) > 0
            end
        end
    end
    return false
end
function EventDispatcher:wait(type)
    local promise = xx.Promise()
    if self._typePromisesMap[type] then
        xx.arrayPush(self._typePromisesMap[type], promise)
    else
        self._typePromisesMap[type] = {promise}
    end
    return promise
end
function EventDispatcher:removeWait(type)
    if not type then
        for type, promises in pairs(self._typePromisesMap) do
            self._typePromisesMap[type] = nil
            for _, promise in ipairs(promises) do
                promise:cancel()
            end
        end
    elseif self._typePromisesMap[type] then
        local promises = self._typePromisesMap[type]
        self._typePromisesMap[type] = nil
        for _, promise in ipairs(promises) do
            promise:cancel()
        end
    end
    return self
end
function EventDispatcher:hasWait(type)
    if not type then
        return xx.tableCount(self._typePromisesMap) > 0
    end
    return self._typePromisesMap[type] and true or false
end
function EventDispatcher:call(type, ...)
    self:callEvent(xx.Event(self, type, xx.arrayPush({}, ...)))
end
function EventDispatcher:callEvent(evt)
    if self._typePromisesMap[evt.type] then
        local promises = self._typePromisesMap[evt.type]
        self._typePromisesMap[evt.type] = nil
        for i = xx.arrayCount(promises), 1, -1 do
            promises[i]:resolve(unpack(evt.args))
        end
    end
    if self._typeCallbacksMap[evt.type] then
        evt.currentTarget = self
        local callbacks = xx.arraySlice(self._typeCallbacksMap[evt.type])
        for _, callback in ipairs(callbacks) do
            if self:hasEventListener(evt.type, callback.handler, callback.caller) then
                if callback["callOnce"] then
                    self:removeEventListener(evt.type, callback.handler, callback.caller)
                end
                callback(evt)
                if evt.isStopImmediate then
                    break
                end
            end
        end
    end
end
local NoticeResult = xx.Class("xx.NoticeResult")
xx.NoticeResult = NoticeResult
function NoticeResult:ctor()
    self.stop = false
    self.data = nil
end
local Framework = xx.Class("xx.Framework", xx.EventDispatcher)
xx.Framework = Framework
function Framework:ctor()
    self.isRegistered = false
    self.priority = 0
    self._context = {}
    self.isConstructed = false
    self.isFocused = false
    self.isActivated = false
    self.parent = nil
    self.curState = nil
    self.numStates = 0
    self._stateUIDs = {}
    self._uidStateMap = {}
    self._uidAliasMap = {}
    self._aliasUIDMap = {}
end
function Framework:ctored()
    self:addEventListener(GIdentifiers.e_changed, self.onPriorityChanged, self)
end
Framework.uidModuleMap = {}
Framework.noticeUIDsMap = {}
Framework.uidNoticesMap = {}
function Framework:onPriorityChanged(name)
    if self.isRegistered and "priority" == name then
        Framework.sort(self)
    end
end
function Framework.register(module, ...)
    if module.isRegistered then
        Framework.addNotices(module, ...)
    else
        Framework.uidModuleMap[module.uid] = module
        module.isRegistered = true
        Framework.addNotices(module, ...)
        if xx.isFunction(module.onRegister) then
            module:onRegister()
        end
    end
end
function Framework.unregister(module)
    if module.isRegistered then
        Framework.removeNotices(module)
        Framework.uidModuleMap[module.uid] = nil
        module.isRegistered = false
        if xx.isFunction(module.onUnregister) then
            module:onUnregister()
        end
    end
end
function Framework.addNotices(module, ...)
    local args = {...}
    local argCount = xx.arrayCount(args)
    if module.isRegistered and argCount > 0 then
        if not Framework.uidNoticesMap[module.uid] then
            Framework.uidNoticesMap[module.uid] = {}
        end
        for i = 1, argCount do
            local notice = args[i]
            if xx.isString(notice) then
                if not module:hasNotice(notice) then
                    xx.arrayPush(Framework.uidNoticesMap[module.uid], notice)
                    if Framework.noticeUIDsMap[notice] then
                        xx.arrayPush(Framework.noticeUIDsMap[notice], module.uid)
                    else
                        Framework.noticeUIDsMap[notice] = {module.uid}
                    end
                end
            end
        end
        Framework.sort(module)
    end
end
function Framework.removeNotices(module, ...)
    if module.isRegistered and Framework.uidNoticesMap[module.uid] then
        local args = {...}
        local count = xx.arrayCount(args)
        local notices = Framework.uidNoticesMap[module.uid]
        if 0 == count then
            for _, notice in ipairs(notices) do
                local uids = Framework.noticeUIDsMap[notice]
                if 1 == xx.arrayCount(uids) then
                    Framework.noticeUIDsMap[notice] = nil
                else
                    xx.arrayRemove(uids, module.uid)
                end
            end
            Framework.uidNoticesMap[module.uid] = nil
        else
            for i = 1, count do
                local notice = args[i]
                if xx.isString(notice) then
                    if module:hasNotice(notice) then
                        local uids = Framework.noticeUIDsMap[notice]
                        if 1 == xx.arrayCount(uids) then
                            Framework.noticeUIDsMap[notice] = nil
                        else
                            xx.arrayRemove(uids, module.uid)
                        end
                        xx.arrayRemove(notices, notice)
                    end
                end
            end
            if 0 == xx.arrayCount(notices) then
                Framework.uidNoticesMap[module.uid] = nil
            end
        end
    end
end
function Framework.notify(notice, ...)
    local result = xx.NoticeResult()
    if Framework.noticeUIDsMap[notice] then
        local uids = xx.arraySlice(Framework.noticeUIDsMap[notice])
        for _, uid in ipairs(uids) do
            if Framework.uidModuleMap[uid] then
                local module = Framework.uidModuleMap[uid]
                if module:hasNotice(notice) and xx.isFunction(module.onNotice) then
                    module:onNotice(notice, result, ...)
                    if result.stop then
                        break
                    end
                end
            end
        end
    end
    return result.data
end
xx.notify = Framework.notify
function Framework.notifyAsync(notice, ...)
    local promise = xx.Promise()
    if Framework.noticeUIDsMap[notice] then
        local index = 1
        local result = xx.NoticeResult()
        local uids = xx.arraySlice(Framework.noticeUIDsMap[notice])
        local executor
        executor = function(...)
            if index > xx.arrayCount(uids) or result.stop then
                promise:resolve(...)
                return
            end
            local module = Framework.uidModuleMap[uids]
            if module and module:hasNotice(notice) and xx.isFunction(module.onNotice) then
                local callback =
                    xx.Callback(
                    function(...)
                        index = index + 1
                        executor(...)
                    end
                )
                module:onNotice(notice, result, unpack(xx.arrayPush({...}, callback)))
                return
            end
            index = index + 1
            executor(...)
        end
        executor(...)
    else
        promise:resolve()
    end
    return promise
end
xx.notifyAsync = Framework.notifyAsync
function Framework.sort(module)
    local notices = Framework.uidNoticesMap[module.uid]
    for _, notice in ipairs(notices) do
        local uids = Framework.noticeUIDsMap[notice]
        table.sort(
            uids,
            function(uid1, uid2)
                return Framework.uidModuleMap[uid2].priority < Framework.uidModuleMap[uid1].priority
            end
        )
    end
end
function Framework:hasNotice(notice)
    if not notice then
        return nil ~= Framework.uidNoticesMap[self.uid]
    end
    return Framework.uidNoticesMap[self.uid] and xx.arrayContains(Framework.uidNoticesMap[self.uid], notice)
end
function Framework:finishModule(args, ...)
    ---@type Callback
    local callback = xx.getCallback(unpack(args))
    if callback then
        callback(...)
    end
    ---@type Signal
    local signal = xx.getSignal(unpack(args))
    if signal then
        signal(...)
    end
    ---@type Promise
    local promise = xx.getPromise(unpack(args))
    if promise then
        promise:resolve(...)
    end
end
function Framework:callEvent(evt)
    xx.EventDispatcher.callEvent(self, evt)
    if not evt.isStopBubble and self.parent then
        self.parent:callEvent(evt)
    end
end
function Framework:getContext(key)
    if self.parent then
        return self.parent:getContext(key)
    end
    if not self._context then
        return
    end
    return self._context[key]
end
function Framework:setContext(key, value)
    if self.parent then
        self.parent:setContext(key, value)
    else
        if not self._context then
            self._context = {}
        end
        self._context[key] = value
    end
end
function Framework:clearContext(key)
    if self.parent then
        self.parent:clearContext(key)
    elseif self._context then
        if key then
            self._context[key] = nil
        else
            xx.tableClear(self._context)
        end
    end
end
function Framework:addState(state, alias, to)
    local parent = self
    repeat
        if parent == state then
            return
        end
        parent = parent.parent
    until not parent
    if self == state.parent then
        if self._uidAliasMap[state.uid] and self._uidAliasMap[state.uid] ~= alias then
            self._aliasUIDMap[self._uidAliasMap[state.uid]] = nil
            self._uidAliasMap[state.uid] = nil
        end
        if alias then
            self._uidAliasMap[state.uid] = alias
            self._aliasUIDMap[alias] = state.uid
        end
        if self._stateUIDs[xx.arrayCount(self._stateUIDs)] ~= state.uid then
            xx.arrayRemove(self._stateUIDs, state.uid)
            xx.arrayPush(self._stateUIDs, state.uid)
        end
    else
        state:removeFromParent()
        xx.arrayPush(self._stateUIDs, state.uid)
        self._uidStateMap[state.uid] = state
        if alias then
            self._uidAliasMap[state.uid] = alias
            self._aliasUIDMap[alias] = state.uid
        end
        state.parent = self
        state:addEventListener(GIdentifiers.e_complete, self._onChildCompleteHandler, self)
        self.numStates = self.numStates + 1
    end
    if to then
        self:toState(state.uid)
    end
end
function Framework:removeState(uidOrAlias)
    local state = nil
    if xx.isString(uidOrAlias) then
        if self._uidStateMap[uidOrAlias] then
            state = self._uidStateMap[uidOrAlias]
        elseif self._aliasUIDMap[uidOrAlias] then
            state = self._uidStateMap[self._aliasUIDMap[uidOrAlias]]
        end
    elseif xx.instanceOf(uidOrAlias, Framework) and self == uidOrAlias.parent then
        state = uidOrAlias
    end
    if state then
        state:removeEventListener(GIdentifiers.e_complete, self._onChildCompleteHandler, self)
        state.parent = nil
        xx.arrayRemove(self._stateUIDs, state.uid)
        self._uidStateMap[state.uid] = nil
        if self._uidAliasMap[state.uid] then
            self._aliasUIDMap[self._uidAliasMap[state.uid]] = nil
            self._uidAliasMap[state.uid] = nil
        end
        if self.curState == state then
            self.curState = nil
            state:defocus()
        end
        self.numStates = self.numStates - 1
    end
end
function Framework:removeFromParent()
    if self.parent then
        self.parent:removeState(self)
    end
end
function Framework:toState(uidOrAlias)
    local state = nil
    if xx.isString(uidOrAlias) then
        if self._uidStateMap[uidOrAlias] then
            state = self._uidStateMap[uidOrAlias]
        elseif self._aliasUIDMap[uidOrAlias] then
            state = self._uidStateMap[self._aliasUIDMap[uidOrAlias]]
        end
    elseif xx.instanceOf(uidOrAlias, Framework) and self == uidOrAlias.parent then
        state = uidOrAlias
    end
    local oldState = self.curState
    if oldState == state then
        return
    end
    self.curState = state
    if oldState then
        oldState:defocus()
    end
    if self.curState then
        if self.isActivated then
            self.curState:activate()
        elseif self.isFocused then
            self.curState:focus()
        elseif self.isConstructed then
            self.curState:construct()
        end
    end
end
function Framework:getAlias(uid)
    if xx.isString(uid) then
        return self._uidAliasMap[uid]
    end
    if xx.instanceOf(uid, Framework) then
        return self._uidAliasMap[uid.uid]
    end
end
function Framework:getState(uidOrAlias)
    if self._uidStateMap[uidOrAlias] then
        return self._uidStateMap[uidOrAlias]
    elseif self._aliasUIDMap[uidOrAlias] then
        return self._uidStateMap[self._aliasUIDMap[uidOrAlias]]
    end
end
function Framework:construct()
    if not self.isConstructed then
        self.isConstructed = true
        if xx.isFunction(self.onConstruct) then
            self:onConstruct()
        end
        if self.isConstructed and self.curState then
            self.curState:construct()
        end
    end
end
function Framework:focus()
    self:construct()
    if self.isConstructed and not self.isFocused then
        self.isFocused = true
        if xx.isFunction(self.onFocus) then
            self:onFocus()
        end
        if self.isFocused and self.curState then
            self.curState:focus()
        end
    end
end
function Framework:activate()
    self:focus()
    if self.isFocused and not self.isActivated then
        self.isActivated = true
        if xx.isFunction(self.onActivate) then
            self:onActivate()
        end
        if self.isActivated and self.curState then
            self.curState:activate()
        end
    end
end
function Framework:deactivate()
    if self.isActivated then
        if self.curState then
            self.curState:deactivate()
        end
        self.isActivated = false
        if xx.isFunction(self.onDeactivate) then
            self:onDeactivate()
        end
    end
end
function Framework:defocus()
    self:deactivate()
    if self.isFocused then
        if self.curState then
            self.curState:defocus()
        end
        self.isFocused = false
        if xx.isFunction(self.onDefocus) then
            self:onDefocus()
        end
    end
end
function Framework:destruct()
    self:defocus()
    if self.isConstructed then
        if self.curState then
            self.curState:destruct()
        end
        self.isConstructed = false
        for _, state in pairs(self._uidStateMap) do
            state:removeEventListener(GIdentifiers.e_complete, self._onChildCompleteHandler, self)
            state:destruct()
        end
        self.curState = nil
        self.numStates = 0
        xx.tableClear(self._context)
        xx.tableClear(self._stateUIDs)
        xx.tableClear(self._uidStateMap)
        xx.tableClear(self._uidAliasMap)
        xx.tableClear(self._aliasUIDMap)
        if xx.isFunction(self.onDestruct) then
            self:onDestruct()
        end
    end
end
function Framework:finishState(...)
    self(GIdentifiers.e_complete, ...)
end
function Framework:_onChildCompleteHandler(evt)
    evt:stopImmediate()
    if self.curState ~= evt.currentTarget then
        return
    end
    self:toState()
    self:onChildComplete(evt.currentTarget, unpack(evt.args))
end
function Framework:onChildComplete(state, ...)
    local index = xx.arrayIndexOf(self._stateUIDs, state.uid) + 1
    if index > xx.arrayCount(self._stateUIDs) then
        self:finishState(...)
    else
        self:toState(self._stateUIDs[index])
    end
end
local Module = xx.Class("xx.Module", xx.Framework)
xx.Module = Module
function Module:ctor()
    self._noticeHandlerMap = {}
end
function Module:ctored()
    local notices = xx.tableKeys(self._noticeHandlerMap)
    if xx.arrayCount(notices) > 0 then
        self:register(unpack(notices))
    end
end
function Module:onNotice(notice, result, ...)
    if self._noticeHandlerMap[notice] then
        return self._noticeHandlerMap[notice](self, result, ...)
    end
end
local State = xx.Class("xx.State", xx.Framework)
xx.State = State
function State:ctor()
end
local Node = xx.Class("xx.Node", xx.EventDispatcher)
xx.Node = Node
function Node:ctor()
    self._children = {}
    self.root = self
    self.numChildren = 0
end
function Node:callEvent(evt)
    xx.EventDispatcher.callEvent(self, evt)
    if not evt.isStopBubble and self.parent then
        self.parent:callEvent(evt)
    end
end
function Node:addChild(child)
    return self:addChildAt(child, self.numChildren + 1)
end
function Node:addChildAt(child, index)
    if child then
        local parent = self
        repeat
            if parent == child then
                return
            end
            parent = parent.parent
        until not parent
        if self == child.parent then
            index = index <= 0 and 1 or (index > self.numChildren and self.numChildren or index)
            if self._children[index] ~= child then
                xx.arrayRemove(self._children, child)
                xx.arrayInsert(self._children, child, index)
            end
        else --新增子节点
            child(GIdentifiers.e_add, child)
            child:removeFromParent()
            self.numChildren = self.numChildren + 1
            index = index <= 0 and 1 or (index > self.numChildren and self.numChildren or index)
            xx.arrayInsert(self._children, child, index)
            child.parent = self
            child:_setRoot(self.root)
            child(GIdentifiers.e_added, child)
        end
        return child
    end
end
function Node:removeChild(child)
    return child and self:removeChildAt(xx.arrayIndexOf(self._children, child))
end
function Node:removeChildAt(index)
    if index >= 1 and index <= self.numChildren then
        local child = self._children[index]
        child(GIdentifiers.e_remove, child)
        self.numChildren = self.numChildren - 1
        xx.arrayRemoveAt(self._children, index)
        child:_setRoot(child)
        child.parent = nil
        child(GIdentifiers.e_removed, child)
        return child
    end
end
function Node:removeChildren(beginIndex, endIndex)
    beginIndex = beginIndex and (beginIndex < 0 and self.numChildren + beginIndex + 1 or beginIndex) or 1
    endIndex = endIndex and (endIndex < 0 and self.numChildren + endIndex + 1 or endIndex) or self.numChildren
    for i = endIndex > self.numChildren and self.numChildren or endIndex, beginIndex < 1 and 1 or beginIndex, -1 do
        self:removeChildAt(i)
    end
end
function Node:setChildIndex(child, index)
    if index >= 1 and index <= self.numChildren and child and self == child.parent and self._children[index] ~= child then
        xx.arrayRemove(self._children, child)
        xx.arrayInsert(self._children, child, index)
        return child
    end
end
function Node:getChildIndex(child)
    return child and self == child.parent and xx.arrayIndexOf(self._children, child) or -1
end
function Node:getChildAt(index)
    if index and index >= 1 and index <= self.numChildren then
        return self._children[index]
    end
end
function Node:removeFromParent()
    if self.parent then
        self.parent:removeChild(self)
    end
end
function Node:_setRoot(root)
    if self.root ~= root then
        local oldRoot = self.root
        self.root = root
        self(GIdentifiers.e_root_changed, oldRoot)
        for _, child in ipairs(self._children) do
            child:_setRoot(root)
        end
    end
end
local CSEvent = xx.CSEvent
local Util = xx.Util
Color = Color or {}
Vector2 = Vector2 or {}
Vector3 = Vector3 or {}
Vector4 = Vector4 or {}
local UnityEngineMonoBehaviour
local UnityEngineEvents
local UnityEngineApplication
local UnityEngineRay
local UnityEngineNetworking
local UnityEngineResources
local UnityEngineTouch
local UnityEnginePhysics
local UnityEnginePlane
local UnityEngineShader
local UnityEngineAssetBundle
local UnityEngineTime
local UnityEngineInput
local UnityEngineBounds
local UnityEngineMaterial
local UnityEngineAnimator
local UnityEngineParticleSystem
local UnityEngineTexture
local UnityEngineScreen
local UnityEngineSprite
local UnityEngineTexture2D
local UnityEngineRenderer
local UnityEngineCollider
local UnityEngineCamera
local UnityEngineFont
UnityEngine = UnityEngine or {}
local UnityEngineObject
GameObject = UnityEngine.GameObject
local UnityEngineComponent
Transform = UnityEngine.Transform
local Sprite = xx.Class("xx.Sprite", xx.Node)
xx.Sprite = Sprite
Sprite.property_pivot_x = "pivotX"
Sprite.property_pivot_y = "pivotY"
Sprite.property_x = "x"
Sprite.property_y = "y"
Sprite.property_z = "z"
Sprite.property_width = "width"
Sprite.property_height = "height"
Sprite.property_scale_x = "scaleX"
Sprite.property_scale_y = "scaleY"
Sprite.property_scale_z = "scaleZ"
Sprite.property_rotation_x = "rotationX"
Sprite.property_rotation_y = "rotationY"
Sprite.property_rotation_z = "rotationZ"
Sprite.property_alpha = "alpha"
Sprite.property_visible = "visible"
Sprite.property_tint = "tint"
Sprite.property_touchable = "touchable"
Sprite.property_source = "source"
Sprite.property_fill_amount = "fillAmount"
Sprite.property_fill_clockwise = "fillClockwise"
Sprite.property_fill_center = "fillCenter"
Sprite.property_preserve_aspect = "preserveAspect"
Sprite.property_text = "text"
Sprite.property_font_color = "fontColor"
Sprite.property_font_size = "fontSize"
Sprite.property_font = "font"
Sprite.property_align_by_geometry = "alignByGeometry"
Sprite.property_resize_text_for_best_fit = "resizeTextForBestFit"
Sprite.property_resize_text_min_size = "resizeTextMinSize"
Sprite.property_resize_text_max_size = "resizeTextMaxSize"
Sprite.property_line_spacing = "lineSpacing"
function Sprite:onDynamicChanged(key, newValue, oldValue)
    if self._propertyHandler[key] then
        self._propertyHandler[key](self.gameObject, newValue)
    end
    xx.Node.onDynamicChanged(self, key, newValue, oldValue)
end
function Sprite:ctor(gameObject)
    self.gameObject = gameObject or UnityEngine.GameObject(self.uid, typeof("UnityEngine.RectTransform"))
    self._csTypeHandlerMap = {}
    self._propertyHandler = {}
    self._propertyHandler[Sprite.property_pivot_x] = self.gameObject.SetPivotX
    self._propertyHandler[Sprite.property_pivot_y] = self.gameObject.SetPivotY
    self._propertyHandler[Sprite.property_x] = self.gameObject.SetX
    self._propertyHandler[Sprite.property_y] = self.gameObject.SetY
    self._propertyHandler[Sprite.property_z] = self.gameObject.SetZ
    self._propertyHandler[Sprite.property_width] = self.gameObject.SetWidth
    self._propertyHandler[Sprite.property_height] = self.gameObject.SetHeight
    self._propertyHandler[Sprite.property_scale_x] = self.gameObject.SetScaleX
    self._propertyHandler[Sprite.property_scale_y] = self.gameObject.SetScaleY
    self._propertyHandler[Sprite.property_scale_z] = self.gameObject.SetScaleZ
    self._propertyHandler[Sprite.property_rotation_x] = self.gameObject.SetRotationX
    self._propertyHandler[Sprite.property_rotation_y] = self.gameObject.SetRotationY
    self._propertyHandler[Sprite.property_rotation_z] = self.gameObject.SetRotationZ
    self._propertyHandler[Sprite.property_alpha] = self.gameObject.SetAlpha
    self._propertyHandler[Sprite.property_visible] = self.gameObject.SetVisible
    self._propertyHandler[Sprite.property_tint] = self.gameObject.SetColor
    self._propertyHandler[Sprite.property_touchable] = self.gameObject.SetTouchable
    self._propertyHandler[Sprite.property_source] = self.gameObject.SetSprite
    self._propertyHandler[Sprite.property_fill_amount] = self.gameObject.SetFillAmount
    self._propertyHandler[Sprite.property_fill_clockwise] = self.gameObject.SetFillClockwise
    self._propertyHandler[Sprite.property_fill_center] = self.gameObject.SetFillCenter
    self._propertyHandler[Sprite.property_preserve_aspect] = self.gameObject.SetPreserveAspect
    self._propertyHandler[Sprite.property_text] = self.gameObject.SetText
    self._propertyHandler[Sprite.property_font_color] = self.gameObject.SetFontColor
    self._propertyHandler[Sprite.property_font_size] = self.gameObject.SetFontSize
    self._propertyHandler[Sprite.property_font] = self.gameObject.SetFont
    self._propertyHandler[Sprite.property_align_by_geometry] = self.gameObject.SetAlignByGeometry
    self._propertyHandler[Sprite.property_resize_text_for_best_fit] = self.gameObject.SetResizeTextForBestFit
    self._propertyHandler[Sprite.property_resize_text_min_size] = self.gameObject.SetResizeTextMinSize
    self._propertyHandler[Sprite.property_resize_text_max_size] = self.gameObject.SetResizeTextMaxSize
    self._propertyHandler[Sprite.property_line_spacing] = self.gameObject.SetLineSpacing
    xx.Class.setter(self, Sprite.property_pivot_x, self.gameObject:GetPivotX())
    xx.Class.setter(self, Sprite.property_pivot_y, self.gameObject:GetPivotY())
    xx.Class.setter(self, Sprite.property_x, self.gameObject:GetX())
    xx.Class.setter(self, Sprite.property_y, self.gameObject:GetY())
    xx.Class.setter(self, Sprite.property_z, self.gameObject:GetZ())
    xx.Class.setter(self, Sprite.property_width, self.gameObject:GetWidth())
    xx.Class.setter(self, Sprite.property_height, self.gameObject:GetHeight())
    xx.Class.setter(self, Sprite.property_scale_x, self.gameObject:GetScaleX())
    xx.Class.setter(self, Sprite.property_scale_y, self.gameObject:GetScaleY())
    xx.Class.setter(self, Sprite.property_scale_z, self.gameObject:GetScaleZ())
    xx.Class.setter(self, Sprite.property_rotation_x, self.gameObject:GetRotationX())
    xx.Class.setter(self, Sprite.property_rotation_y, self.gameObject:GetRotationY())
    xx.Class.setter(self, Sprite.property_rotation_z, self.gameObject:GetRotationZ())
    xx.Class.setter(self, Sprite.property_alpha, self.gameObject:GetAlpha())
    xx.Class.setter(self, Sprite.property_visible, self.gameObject:GetVisible())
    xx.Class.setter(self, Sprite.property_tint, self.gameObject:GetColor())
    if self:isImage() then
        xx.Class.setter(self, Sprite.property_touchable, self.gameObject:GetTouchable())
        xx.Class.setter(self, Sprite.property_source, self.gameObject:GetSprite())
        xx.Class.setter(self, Sprite.property_fill_amount, self.gameObject:GetFillAmount())
        xx.Class.setter(self, Sprite.property_fill_clockwise, self.gameObject:GetFillClockwise())
        xx.Class.setter(self, Sprite.property_fill_center, self.gameObject:GetFillCenter())
        xx.Class.setter(self, Sprite.property_preserve_aspect, self.gameObject:GetPreserveAspect())
    end
    if self:isText() then
        xx.Class.setter(self, Sprite.property_touchable, self.gameObject:GetTouchable())
        xx.Class.setter(self, Sprite.property_text, self.gameObject:GetText())
        xx.Class.setter(self, Sprite.property_font_color, self.gameObject:GetFontColor())
        xx.Class.setter(self, Sprite.property_font_size, self.gameObject:GetFontSize())
        xx.Class.setter(self, Sprite.property_font, self.gameObject:GetFont())
        xx.Class.setter(self, Sprite.property_align_by_geometry, self.gameObject:GetAlignByGeometry())
        xx.Class.setter(self, Sprite.property_resize_text_for_best_fit, self.gameObject:GetResizeTextForBestFit())
        xx.Class.setter(self, Sprite.property_resize_text_min_size, self.gameObject:GetResizeTextMinSize())
        xx.Class.setter(self, Sprite.property_resize_text_max_size, self.gameObject:GetResizeTextMaxSize())
        xx.Class.setter(self, Sprite.property_line_spacing, self.gameObject:GetLineSpacing())
    end
end
function Sprite:addEventListener(type, handler, caller, ...)
    xx.EventDispatcher.addEventListener(self, type, handler, caller, ...)
    self:checkCSEvents()
    return self
end
function Sprite:once(type, handler, caller, ...)
    xx.EventDispatcher.once(self, type, handler, caller, ...)
    self:checkCSEvents()
    return self
end
function Sprite:removeEventListener(type, handler, caller)
    xx.EventDispatcher.removeEventListener(self, type, handler, caller)
    self:checkCSEvents()
    return self
end
function Sprite:wait(type)
    local promise = xx.EventDispatcher.wait(self, type)
    self:checkCSEvents()
    return promise
end
function Sprite:removeWait(type)
    xx.EventDispatcher.removeWait(self, type)
    self:checkCSEvents()
    return self
end
function Sprite:checkCSEvents()
    for type, csHandler in pairs(self._csTypeHandlerMap) do
        if not self:hasEventListener(type) and not self:hasWait(type) then
            self.gameObject:RemoveEventListener(type, csHandler)
            self._csTypeHandlerMap[type] = nil
        end
    end
    for type, _ in pairs(self._typeCallbacksMap) do
        if not self._csTypeHandlerMap[type] then
            self._csTypeHandlerMap[type] = xx.Handler(self._onCSHandler, self)
            self.gameObject:AddEventListener(type, self._csTypeHandlerMap[type])
        end
    end
    for type, _ in pairs(self._typePromisesMap) do
        if not self._csTypeHandlerMap[type] then
            self._csTypeHandlerMap[type] = xx.Handler(self._onCSHandler, self)
            self.gameObject:AddEventListener(type, self._csTypeHandlerMap[type])
        end
    end
end
function Sprite:_onCSHandler(csEvent)
    local type = csEvent.Type
    if csEvent.Args and csEvent.Args.Length > 0 then
        local args = {}
        for i = 0, csEvent.Args.Length - 1 do
            xx.arrayPush(args, csEvent.Args[i])
        end
        self(type, unpack(args))
    else
        self(type)
    end
    self:checkCSEvents()
end
function Sprite:addChildAt(child, index)
    child = xx.Node.addChildAt(self, child, index)
    if xx.instanceOf(child, Sprite) then
        child.gameObject.transform:SetParent(self.gameObject.transform, false)
        self:_refreshIndex()
    end
    return child
end
function Sprite:removeChildAt(index)
    ---@type Sprite
    local child = xx.Node.removeChildAt(self, index)
    if xx.instanceOf(child, Sprite) then
        child.gameObject.transform:SetParent(nil, false)
        return child
    end
end
function Sprite:setChildIndex(child, index)
    child = xx.Node.setChildIndex(self, child, index)
    if xx.instanceOf(child, Sprite) then
        self:_refreshIndex()
        return child
    end
end
function Sprite:_refreshIndex()
    ---@type Sprite
    local child
    local siblingIndex = 0
    for i = 1, self.numChildren do
        child = self._children[i]
        child.gameObject.transform:SetSiblingIndex(i - 1)
    end
end
function Sprite:getFromHolder(name)
    return self.gameObject:GetFromHolder(name)
end
function Sprite:anchorSet(minX, minY, maxX, maxY, pivotX, pivotY, x, y)
    self.gameObject:AnchorSet(minX, minY, maxX, maxY, pivotX, pivotY, x, y)
end
function Sprite:anchorTop(y)
    self.gameObject:AnchorTop(y or 0)
end
function Sprite:anchorMiddle(y)
    self.gameObject:AnchorMiddle(y or 0)
end
function Sprite:anchorBottom(y)
    self.gameObject:AnchorBottom(y or 0)
end
function Sprite:anchorLeft(x)
    self.gameObject:AnchorLeft(x or 0)
end
function Sprite:anchorCenter(x)
    self.gameObject:AnchorCenter(x or 0)
end
function Sprite:anchorRight(x)
    self.gameObject:AnchorRight(x or 0)
end
function Sprite:anchorTopLeft(x, y)
    self.gameObject:AnchorTopLeft(x or 0, y or 0)
end
function Sprite:anchorTopCenter(x, y)
    self.gameObject:AnchorTopCenter(x or 0, y or 0)
end
function Sprite:anchorTopRight(x, y)
    self.gameObject:AnchorTopRight(x or 0, y or 0)
end
function Sprite:anchorMiddleLeft(x, y)
    self.gameObject:AnchorMiddleLeft(x or 0, y or 0)
end
function Sprite:anchorMiddleCenter(x, y)
    self.gameObject:AnchorMiddleCenter(x or 0, y or 0)
end
function Sprite:anchorMiddleRight(x, y)
    self.gameObject:AnchorMiddleRight(x or 0, y or 0)
end
function Sprite:anchorBottomLeft(x, y)
    self.gameObject:AnchorBottomLeft(x or 0, y or 0)
end
function Sprite:anchorBottomCenter(x, y)
    self.gameObject:AnchorBottomCenter(x or 0, y or 0)
end
function Sprite:anchorBottomRight(x, y)
    self.gameObject:AnchorBottomRight(x or 0, y or 0)
end
function Sprite:stretchHorizontal(left, right)
    self.gameObject:StretchHorizontal(left or 0, right or 0)
end
function Sprite:stretchVertical(top, bottom)
    self.gameObject:StretchVertical(top or 0, bottom or 0)
end
function Sprite:stretchBoth(left, right, top, bottom)
    self.gameObject:StretchBoth(left or 0, right or 0, top or 0, bottom or 0)
end
function Sprite:worldToLocal(worldX, worldY, worldZ)
    return self.gameObject:WorldToLocal(worldX, worldY, worldZ)
end
function Sprite:localToWorld(localX, localY, localZ)
    return self.gameObject:LocalToWorld(localX, localY, localZ)
end
function Sprite:screenToLocal(screenX, screenY)
    return self.gameObject:ScreenToLocal(screenX, screenY)
end
function Sprite:localToScreen(screenX, screenY)
    return self.gameObject:LocalToScreen(screenX, screenY)
end
function Sprite:toImage()
    self.gameObject:ToImage()
    xx.Class.setter(self, Sprite.property_touchable, self.gameObject:GetTouchable())
    xx.Class.setter(self, Sprite.property_source, self.gameObject:GetSprite())
    xx.Class.setter(self, Sprite.property_fill_amount, self.gameObject:GetFillAmount())
    xx.Class.setter(self, Sprite.property_fill_clockwise, self.gameObject:GetFillClockwise())
    xx.Class.setter(self, Sprite.property_fill_center, self.gameObject:GetFillCenter())
    xx.Class.setter(self, Sprite.property_preserve_aspect, self.gameObject:GetPreserveAspect())
end
function Sprite:isImage()
    return self.gameObject:IsImage()
end
function Sprite:setNativeSize()
    self.gameObject:SetNativeSize()
end
function Sprite:setTypeSimple()
    self.gameObject:SetTypeSimple()
end
function Sprite:setTypeSliced()
    self.gameObject:SetTypeSliced()
end
function Sprite:setTypeTiled()
    self.gameObject:SetTypeTiled()
end
function Sprite:setTypeFilled()
    self.gameObject:SetTypeFilled()
end
function Sprite:setFillHorizontal()
    self.gameObject:SetFillHorizontal()
end
function Sprite:setFillVertical()
    self.gameObject:SetFillVertical()
end
function Sprite:setFillRadia90()
    self.gameObject:SetFillRadia90()
end
function Sprite:setFillRadia180()
    self.gameObject:SetFillRadia180()
end
function Sprite:setFillRadia360()
    self.gameObject:SetFillRadia360()
end
function Sprite:setOriginHorizontalLeft()
    self.gameObject:SetOriginHorizontalLeft()
end
function Sprite:setOriginHorizontalRight()
    self.gameObject:SetOriginHorizontalRight()
end
function Sprite:setOriginVerticalBottom()
    self.gameObject:SetOriginVerticalBottom()
end
function Sprite:setOriginVerticalTop()
    self.gameObject:SetOriginVerticalTop()
end
function Sprite:setOriginRadia90BottomLeft()
    self.gameObject:SetOriginRadia90BottomLeft()
end
function Sprite:setOriginRadia90TopLeft()
    self.gameObject:SetOriginRadia90TopLeft()
end
function Sprite:setOriginRadia90TopRight()
    self.gameObject:SetOriginRadia90TopRight()
end
function Sprite:setOriginRadia90BottomRight()
    self.gameObject:SetOriginRadia90BottomRight()
end
function Sprite:setOriginRadia180Bottom()
    self.gameObject:SetOriginRadia180Bottom()
end
function Sprite:setOriginRadia180Left()
    self.gameObject:SetOriginRadia180Left()
end
function Sprite:setOriginRadia180Top()
    self.gameObject:SetOriginRadia180Top()
end
function Sprite:setOriginRadia180Right()
    self.gameObject:SetOriginRadia180Right()
end
function Sprite:setOriginRadia360Bottom()
    self.gameObject:SetOriginRadia360Bottom()
end
function Sprite:setOriginRadia360Right()
    self.gameObject:SetOriginRadia360Right()
end
function Sprite:setOriginRadia360Top()
    self.gameObject:SetOriginRadia360Top()
end
function Sprite:setOriginRadia360Left()
    self.gameObject:SetOriginRadia360Left()
end
function Sprite:toText()
    self.gameObject:ToText()
    xx.Class.setter(self, Sprite.property_touchable, self.gameObject:GetTouchable())
    xx.Class.setter(self, Sprite.property_text, self.gameObject:GetText())
    xx.Class.setter(self, Sprite.property_font_color, self.gameObject:GetFontColor())
    xx.Class.setter(self, Sprite.property_font_size, self.gameObject:GetFontSize())
    xx.Class.setter(self, Sprite.property_font, self.gameObject:GetFont())
    xx.Class.setter(self, Sprite.property_align_by_geometry, self.gameObject:GetAlignByGeometry())
    xx.Class.setter(self, Sprite.property_resize_text_for_best_fit, self.gameObject:GetResizeTextForBestFit())
    xx.Class.setter(self, Sprite.property_resize_text_min_size, self.gameObject:GetResizeTextMinSize())
    xx.Class.setter(self, Sprite.property_resize_text_max_size, self.gameObject:GetResizeTextMaxSize())
    xx.Class.setter(self, Sprite.property_line_spacing, self.gameObject:GetLineSpacing())
end
function Sprite:isText()
    return self.gameObject:IsText()
end
function Sprite:setStyleNormal()
    self.gameObject:SetStyleNormal()
end
function Sprite:setStyleBold()
    self.gameObject:SetStyleBold()
end
function Sprite:setStyleItalic()
    self.gameObject:SetStyleItalic()
end
function Sprite:setStyleBoldAndItalic()
    self.gameObject:SetStyleBoldAndItalic()
end
function Sprite:setHorizontalWrap()
    self.gameObject:SetHorizontalWrap()
end
function Sprite:setHorizontalOverflow()
    self.gameObject:SetHorizontalOverflow()
end
function Sprite:setVerticalTruncate()
    self.gameObject:SetVerticalTruncate()
end
function Sprite:setVerticalOverflow()
    self.gameObject:SetVerticalOverflow()
end
function Sprite:setResizeText(resizeTextForBestFit, resizeTextMinSize, resizeTextMaxSize)
    self.gameObject:SetResizeText(resizeTextForBestFit, resizeTextMinSize, resizeTextMaxSize)
end
function Sprite:setAlignUpperLeft()
    self.gameObject:SetAlignUpperLeft()
end
function Sprite:setAlignUpperCenter()
    self.gameObject:SetAlignUpperCenter()
end
function Sprite:setAlignUpperRight()
    self.gameObject:SetAlignUpperRight()
end
function Sprite:setAlignMiddleLeft()
    self.gameObject:SetAlignMiddleLeft()
end
function Sprite:setAlignMiddleCenter()
    self.gameObject:SetAlignMiddleCenter()
end
function Sprite:setAlignMiddleRight()
    self.gameObject:SetAlignMiddleRight()
end
function Sprite:setAlignLowerLeft()
    self.gameObject:SetAlignLowerLeft()
end
function Sprite:setAlignLowerCenter()
    self.gameObject:SetAlignLowerCenter()
end
function Sprite:setAlignLowerRight()
    self.gameObject:SetAlignLowerRight()
end
function Sprite:setAutoSizeHorizontal(autoSize)
    self.gameObject:SetAutoSizeHorizontal(autoSize)
end
function Sprite:setAutoSizeVertical(autoSize)
    self.gameObject:SetAutoSizeVertical(autoSize)
end
function Sprite:setAutoSize(horizontal, vertical)
    self.gameObject:SetAutoSize(horizontal, vertical)
end
function Sprite:setBool(name, value)
    self.gameObject:SetBool(name, value)
end
function Sprite:setInteger(name, value)
    self.gameObject:SetInteger(name, value)
end
function Sprite:setFloat(name, value)
    self.gameObject:SetFloat(name, value)
end
function Sprite:setTrigger(name)
    self.gameObject:SetTrigger(name)
end
function Sprite:playAnimator(name)
    self.gameObject:PlayAnimator(name)
end
function Sprite:playAnimator(name)
    self.gameObject:PlayAnimator(name)
end
function Sprite:stopAnimator()
    self.gameObject:StopAnimator()
end
function Sprite:updateAnimator(deltaTimeMS)
    self.gameObject:UpdateAnimator(deltaTimeMS)
end
function Sprite:playParticleSystem(withChildren)
    self.gameObject:PlayParticleSystem(true == withChildren)
end
function Sprite:pauseParticleSystem(withChildren)
    self.gameObject:PauseParticleSystem(true == withChildren)
end
function Sprite:stopParticleSystem(withChildren)
    self.gameObject:StopParticleSystem(true == withChildren)
end
local Root = xx.Class("xx.Root", xx.Sprite)
xx.Root = Root
function Root:ctor(cvs, go)
    self._rootGO = go
    self._layerMap = {}
    self._childLayerMap = {}
end
function Root:getFromHolder(name)
    return self._rootGO:GetFromHolder(name)
end
function Root:layerAdd(child, layer)
    if not self._layerMap[layer] then
        self._layerMap[layer] = xx.Sprite(xx.Util.GetLayerCVS(layer))
    end
    if self._childLayerMap[child] and self._childLayerMap[child] ~= layer then
        self:layerRemove(child)
    end
    self._childLayerMap[child] = layer
    self._layerMap[layer]:addChild(child)
end
function Root:layerRemove(child)
    if not self._childLayerMap[child] then
        return
    end
    self._layerMap[self._childLayerMap[child]]:removeChild(child)
    self._childLayerMap[child] = nil
end
function Root:layerTop(child)
    if not self._childLayerMap[child] then
        return
    end
    self._layerMap[self._childLayerMap[child]]:addChild(child)
end
function Root:layerBottom(child)
    if not self._childLayerMap[child] then
        return
    end
    self._layerMap[self._childLayerMap[child]]:addChildAt(child, 0)
end
local Timer = xx.Class("xx.Timer")
function Timer:ctor(duration, count, rate, onOnce, onComplete)
    self.duration = duration
    self.count = count
    self.rate = rate
    self.onOnce = onOnce
    self.onComplete = onComplete
    self.counted = 0
    self.time = 0
    self.isPaused = false
    self.isStopped = false
    self.trigger = false
end
function Timer:isComplete()
    return self.count > 0 and self.counted >= self.count
end
local MTimer = xx.Class("xx.MTimer", xx.Module)
xx.MTimer = MTimer
function MTimer:ctor()
    self._isPaused = false
    self._timerList = {}
    self._uidTimerMap = {}
    self._noticeHandlerMap[GIdentifiers.nb_timer] = self.onAppTimer
    self._noticeHandlerMap[GIdentifiers.nb_pause] = self.onAppPause
    self._noticeHandlerMap[GIdentifiers.nb_resume] = self.onAppResume
    self._noticeHandlerMap[GIdentifiers.ni_timer_new] = self.onNew
    self._noticeHandlerMap[GIdentifiers.ni_timer_pause] = self.onPause
    self._noticeHandlerMap[GIdentifiers.ni_timer_resume] = self.onResume
    self._noticeHandlerMap[GIdentifiers.ni_timer_stop] = self.onStop
    self._noticeHandlerMap[GIdentifiers.ni_timer_rate] = self.onRate
end
function MTimer:onAppTimer(result, interval)
    if self._isPaused then
        return
    end
    if interval < 1000 then
        for i = xx.arrayCount(self._timerList), 1, -1 do
            local timer = self._timerList[i]
            if timer.isStopped then
                self._uidTimerMap[timer.uid] = nil
                xx.arrayRemoveAt(self._timerList, i)
                if timer.trigger and timer.onComplete then -- 触发回调
                    timer.onComplete()
                end
            elseif not timer.isPaused then -- 正常
                local time = interval * timer.rate
                timer.time = timer.time + time
                local count = timer.duration > 0 and math.floor(timer.time / timer.duration) - timer.counted or 1
                while count > 0 and not timer:isComplete() and not timer.isPaused and not timer.isStopped do
                    timer.counted = timer.counted + 1
                    if timer.onOnce then -- 触发回调
                        timer.onOnce(time, timer.counted)
                    end
                    time = 0
                    count = count - 1
                end
                if timer:isComplete() and not timer.isPaused and not timer.isStopped then
                    self._uidTimerMap[timer.uid] = nil
                    xx.arrayRemoveAt(self._timerList, i)
                    if timer.onComplete then -- 触发回调
                        timer.onComplete()
                    end
                end
            end
        end
    end
    xx.Promise.asyncLoop()
end
function MTimer:onAppPause(result)
    self._isPaused = true
end
function MTimer:onAppResume(result)
    self._isPaused = false
end
function MTimer:onNew(result, durationOrTimer, countOrOnComplete, onOnce, onComplete)
    ---@type Timer
    local timer
    if xx.instanceOf(durationOrTimer, Timer) then
        timer = durationOrTimer
        if xx.isNil(timer.onComplete) and xx.instanceOf(countOrOnComplete, xx.Callback) then
            timer.onComplete = countOrOnComplete
        end
    else
        timer = Timer(durationOrTimer, countOrOnComplete, 1, onOnce, onComplete)
    end
    xx.arrayPush(self._timerList, timer)
    self._uidTimerMap[timer.uid] = timer
    result.data = timer.uid
end
function MTimer:onPause(result, id)
    if self._uidTimerMap[id] then
        self._uidTimerMap[id].isPaused = true
    end
end
function MTimer:onResume(result, id)
    if self._uidTimerMap[id] then
        self._uidTimerMap[id].isPaused = false
    end
end
function MTimer:onStop(result, id, trigger)
    if self._uidTimerMap[id] then
        self._uidTimerMap[id].isStopped = true
        self._uidTimerMap[id].trigger = trigger
    end
end
function MTimer:onRate(result, id, rate)
    local id, rate = unpack(args)
    if self._uidTimerMap[id] then
        self._uidTimerMap[id].rate = rate
    end
end
function xx.later(handler, caller, ...)
    return xx.notify(GIdentifiers.ni_timer_new, 0, 1, nil, xx.Callback(handler, caller, ...))
end
function xx.delay(time, handler, caller, ...)
    return xx.notify(GIdentifiers.ni_timer_new, time, 1, nil, xx.Callback(handler, caller, ...))
end
function xx.loop(interval, count, onOnce, caller, onComplete, ...)
    onOnce = xx.isFunction(onOnce) and xx.Callback(onOnce, caller, ...) or nil
    onComplete = xx.isFunction(onComplete) and xx.Callback(onComplete, caller, ...) or nil
    return xx.notify(GIdentifiers.ni_timer_new, interval, count, onOnce, onComplete)
end
function xx.sleep(time)
    local promise = xx.Promise()
    return promise, xx.delay(
        time,
        function()
            promise:resolve()
        end
    )
end
function xx.timerPause(id)
    xx.notify(GIdentifiers.ni_timer_pause, id)
end
function xx.timerResume(id)
    xx.notify(GIdentifiers.ni_timer_resume, id)
end
function xx.timerStop(id, trigger)
    if not xx.isBoolean(trigger) then
        trigger = false
    end
    xx.notify(GIdentifiers.ni_timer_stop, id, trigger)
end
function xx.timerRate(id, rate)
    if not xx.isNumber(rate) then
        rate = 1
    end
    xx.notify(GIdentifiers.ni_timer_rate, id, rate)
end
xx.getInstance("xx.MTimer")
local TweenCallbackStep = xx.Class("TweenCallbackStep")
function TweenCallbackStep:ctor(tween, onComplete)
    self._tween = tween
    self._callback = onComplete
end
function TweenCallbackStep:update(interval)
    self._tween.stepIndex = self._tween.stepIndex + 1
    if self._callback then
        self._callback()
    end
    return interval
end
local TweenFrameStep = xx.Class("xx.TweenFrameStep")
function TweenFrameStep:ctor(tween, count)
    self._tween = tween
    self._count = count
    self._counted = 0
end
function TweenFrameStep:update(interval)
    if self._counted >= self._count then
        self._counted = 0
        self._tween.stepIndex = self._tween.stepIndex + 1
    else
        self._counted = self._counted + 1
        interval = 0
    end
    return interval
end
local TweenLoopStep = xx.Class("xx.TweenLoopStep")
function TweenLoopStep:ctor(tween, count, preCount, onOnce)
    self._tween = tween
    self._count = count or 0
    self._preCount = preCount or 0
    self._onOnce = onOnce
    self._counted = 0
end
function TweenLoopStep:update(interval)
    if self._counted > 0 and self._onOnce then
        self._onOnce()
    end
    if self._count <= 0 or self._counted < self._count then
        self._counted = self._counted + 1
        if self._preCount <= 0 or self._preCount >= self._tween.stepIndex then
            self._tween.stepIndex = 1
        else
            self._tween.stepIndex = self._tween.stepIndex - self._preCount
        end
    else
        self._counted = 0
        self._tween.stepIndex = self._tween.stepIndex + 1
    end
    return interval
end
local TweenRateStep = xx.Class("xx.TweenRateStep")
function TweenRateStep:ctor(tween, isTo, rate)
    self._tween = tween
    self._isTo = isTo
    self._rate = rate or 1
end
function TweenRateStep:update(interval)
    self._tween.rate = self._isTo and self._rate or self._tween.rate + self._rate
    self._tween.stepIndex = self._tween.stepIndex + 1
    return interval
end
local TweenSetStep = xx.Class("xx.TweenSetStep")
function TweenSetStep:ctor(tween, isTo, properties)
    self._tween = tween
    self._isTo = isTo
    self._properties = properties
end
function TweenSetStep:update(interval)
    for _, target in ipairs(self._tween.targets) do
        for k, v in pairs(self._properties) do
            if not self._isTo then
                v = v + self._tween.curValueMap[target][k]
            end
            self._tween.curValueMap[target][k] = v
            target[k] = v
        end
    end
    self._tween.stepIndex = self._tween.stepIndex + 1
    return interval
end
local TweenSleepStep = xx.Class("xx.TweenSleepStep")
function TweenSleepStep:ctor(tween, time)
    self._tween = tween
    self._time = time or 1000
    self._timePassed = 0
end
function TweenSleepStep:update(interval)
    self._timePassed = self._timePassed + interval
    if self._timePassed >= self._time then
        interval = self._timePassed - self._time
        self._timePassed = 0
        self._tween.stepIndex = self._tween.stepIndex + 1
    else
        interval = 0
    end
    return interval
end
local TweenStep = xx.Class("xx.TweenStep")
function TweenStep:ctor(tween, isTo, properties, time, playback, ease, onPlayback, onUpdate)
    self._tween = tween
    self._isTo = isTo
    self._properties = properties
    self._time = time or 1000
    if xx.isBoolean(playback) then
        self._playback = playback
    else
        self._playback = false
    end
    self._ease = ease or xx.easeLinear
    self._onPlayback = onPlayback
    self._onUpdate = onUpdate
    self._timePassed = 0
end
function TweenStep:update(interval)
    if not self._beginMap then
        self._beginMap = {}
        self._changeMap = {}
        for _, target in ipairs(self._tween.targets) do
            local beginMap = {}
            local changeMap = {}
            for k, v in pairs(self._properties) do
                beginMap[k] = self._tween.curValueMap[target][k]
                if xx.isTable(v) then
                    changeMap[k] = {0}
                    for i = 1, xx.arrayCount(v) do
                        xx.arrayPush(changeMap[k], self._isTo and v[i] - beginMap[k] or v[i])
                    end
                else -- 普通缓动
                    changeMap[k] = self._isTo and v - beginMap[k] or v
                end
            end
            self._beginMap[target] = beginMap
            self._changeMap[target] = changeMap
        end
    end
    local halfTime = self._time / 2
    local isPlayback = self._playback and self._timePassed < halfTime and self._timePassed + interval >= halfTime
    self._timePassed = self._timePassed + interval
    local value
    local time = self._timePassed > self._time and self._time or self._timePassed
    if self._playback then
        time = (time < halfTime and time or self._time - time) * 2
    end
    for _, target in ipairs(self._tween.targets) do
        local beginMap = self._beginMap[target]
        local changeMap = self._changeMap[target]
        for k, beginV in pairs(beginMap) do
            local change = changeMap[k]
            if xx.isTable(change) then
                value = beginV + xx.bezier(self._ease(time, 0, 1, self._time), unpack(change))
            else
                value = self._ease(time, beginV, change, self._time)
            end
            self._tween.curValueMap[target][k] = value
            target[k] = value
            if self._onUpdate then
                self._onUpdate(target, k, value)
            end
        end
    end
    if isPlayback and self._onPlayback then
        self._onPlayback()
    end
    if self._timePassed >= self._time then
        interval = self._timePassed - self._time
        self._timePassed = 0
        self._beginMap = nil
        self._changeMap = nil
        self._tween.stepIndex = self._tween.stepIndex + 1
    else
        interval = 0
    end
    return interval
end
local TweenStop = xx.Class("TweenStop")
function TweenStop:ctor(target, trigger, toEnd)
    self.target = target
    self.trigger = trigger
    self.toEnd = toEnd
end
function xx.easeLinear(time, begin, change, duration)
    return begin + change * time / duration
end
function xx.CircularIn(time, begin, change, duration)
    time = time / duration
    return -change * (math.sqrt(1 - time * time) - 1) + begin
end
function xx.CircularOut(time, begin, change, duration)
    time = time / duration - 1
    return change * math.sqrt(1 - time * time) + begin
end
function xx.CircularInOut(time, begin, change, duration)
    time = 2 * time / duration
    if time < 1 then
        return -change / 2 * (math.sqrt(1 - time * time) - 1) + begin
    end
    time = time - 2
    return change / 2 * (math.sqrt(1 - time * time) + 1) + begin
end
function xx.QuadraticIn(time, begin, change, duration)
    time = time / duration
    return change * time * time + begin
end
function xx.QuadraticOut(time, begin, change, duration)
    time = time / duration
    return -change * time * (time - 2) + begin
end
function xx.QuadraticInOut(time, begin, change, duration)
    time = 2 * time / duration
    if time < 1 then
        return change / 2 * time * time + begin
    end
    time = time - 1
    return -change / 2 * (time * (time - 2) - 1) + begin
end
function xx.CubicIn(time, begin, change, duration)
    time = time / duration
    return change * time * time * time + begin
end
function xx.CubicOut(time, begin, change, duration)
    time = time / duration - 1
    return change * (time * time * time + 1) + begin
end
function xx.CubicInOut(time, begin, change, duration)
    time = 2 * time / duration
    if time < 1 then
        return change / 2 * time * time * time + begin
    end
    time = time - 2
    return change / 2 * (time * time * time + 2) + begin
end
function xx.QuarticIn(time, begin, change, duration)
    time = time / duration
    return change * time * time * time * time + begin
end
function xx.QuarticOut(time, begin, change, duration)
    time = time / duration - 1
    return -change * (time * time * time * time - 1) + begin
end
function xx.QuarticInOut(time, begin, change, duration)
    time = 2 * time / duration
    if time < 1 then
        return change / 2 * time * time * time * time + begin
    end
    time = time - 2
    return -change / 2 * (time * time * time * time - 2) + begin
end
function xx.QuinticIn(time, begin, change, duration)
    time = time / duration
    return change * time * time * time * time * time + begin
end
function xx.QuinticOut(time, begin, change, duration)
    time = time / duration - 1
    return change * (time * time * time * time * time + 1) + begin
end
function xx.QuinticInOut(time, begin, change, duration)
    time = 2 * time / duration
    if time < 1 then
        return change / 2 * time * time * time * time * time + begin
    end
    time = time - 2
    return change / 2 * (time * time * time * time * time + 2) + begin
end
function xx.ExponentialIn(time, begin, change, duration)
    if 0 == time then
        return begin
    end
    return change * (2 ^ (10 * (time / duration - 1))) + begin
end
function xx.ExponentialOut(time, begin, change, duration)
    if time == duration then
        return begin + change
    end
    return change * (1 - (2 ^ (-10 * time / duration))) + begin
end
function xx.ExponentialInOut(time, begin, change, duration)
    if 0 == time then
        return begin
    end
    if time == duration then
        return begin + change
    end
    time = 2 * time / duration
    if time < 1 then
        return change / 2 * (2 ^ (10 * (time - 1))) + begin
    end
    time = time - 1
    return change / 2 * (2 - (2 ^ (-10 * time))) + begin
end
function xx.SineIn(time, begin, change, duration)
    return -change * math.cos(time / duration * (math.pi / 2)) + change + begin
end
function xx.SineOut(time, begin, change, duration)
    return change * math.sin(time / duration * (math.pi / 2)) + begin
end
function xx.SineInOut(time, begin, change, duration)
    return -change / 2 * (math.cos(math.pi * time / duration) - 1) + begin
end
function xx.BounceIn(time, begin, change, duration)
    return change - xx.BounceOut(duration - time, 0, change, duration) + begin
end
function xx.BounceOut(time, begin, change, duration)
    time = time / duration
    if time < (1 / 2.75) then
        return change * (7.5625 * time * time) + begin
    elseif time < (2 / 2.75) then
        time = time - (1.5 / 2.75)
        return change * (7.5625 * time * time + 0.75) + begin
    elseif time < (2.5 / 2.75) then
        time = time - (2.25 / 2.75)
        return change * (7.5625 * time * time + 0.9375) + begin
    end
    time = time - (2.625 / 2.75)
    return change * (7.5625 * time * time + 0.984375) + begin
end
function xx.BounceInOut(time, begin, change, duration)
    if time < duration / 2 then
        return xx.BounceIn(time * 2, 0, change, duration) * 0.5 + begin
    end
    return xx.BounceOut(time * 2 - duration, 0, change, duration) * 0.5 + change * 0.5 + begin
end
local BACK = 1.70158
function xx.BackIn(time, begin, change, duration)
    time = time / duration
    return change * time * time * ((BACK + 1) * time - BACK) + begin
end
function xx.BackOut(time, begin, change, duration)
    time = time / duration - 1
    return change * (time * time * ((BACK + 1) * time + BACK) + 1) + begin
end
function xx.BackInOut(time, begin, change, duration)
    local s = BACK
    time = 2 * time / duration
    if time < 1 then
        s = s * 1.525
        return change / 2 * (time * time * ((s + 1) * time - s)) + begin
    end
    time = time - 2
    s = s * 1.525
    return change / 2 * (time * time * ((s + 1) * time + s) + 2) + begin
end
function xx.ElasticIn(time, begin, change, duration)
    if 0 == time then
        return begin
    end
    time = time / duration
    if 1 == time then
        return begin + change
    end
    local p = duration * 0.3
    local s = p / 4
    time = time - 1
    return -(change * (2 ^ (10 * time)) * math.sin((time * duration - s) * (2 * math.pi) / p)) + begin
end
function xx.ElasticOut(time, begin, change, duration)
    if 0 == time then
        return begin
    end
    time = time / duration
    if 1 == time then
        return begin + change
    end
    local p = duration * 0.3
    local s = p / 4
    return change * (2 ^ (-10 * time)) * math.sin((time * duration - s) * (2 * math.pi) / p) + change + begin
end
function xx.ElasticInOut(time, begin, change, duration)
    if 0 == time then
        return begin
    end
    time = 2 * time / duration
    if 2 == time then
        return begin + change
    end
    local p = duration * (0.3 * 1.5)
    local s = p / 4
    if time < 1 then
        time = time - 1
        return -0.5 * (change * (2 ^ (10 * time)) * math.sin((time * duration - s) * (2 * math.pi) / p)) + begin
    end
    time = time - 1
    return change * (2 ^ (-10 * time)) * math.sin((time * duration - s) * (2 * math.pi) / p) * 0.5 + change + begin
end
local Tween = xx.Class("xx.Tween", xx.Promise)
function Tween:ctor(...)
    self.rate = 1
    self.targets = {...}
    self.curValueMap = {}
    self.endValueMap = {}
    for _, target in ipairs(self.targets) do
        self.curValueMap[target] = {}
        self.endValueMap[target] = {}
    end
    self.stepIndex = 1
    self.stepList = {}
    self.stopList = {}
    self.isPaused = false
    self.isStopped = false
    self.trigger = false
    self.toEnd = false
    self.isCompleted = false
end
function Tween:getter(key)
    if "isCompleted" == key then
        return self.stepIndex > xx.arrayCount(self.stepList)
    end
    return xx.Class.getter(self, key)
end
function Tween:pause()
    self.isPaused = true
end
function Tween:resume()
    self.isPaused = false
end
function Tween:stop(trigger, toEnd, ...)
    local targets = {...}
    local count = xx.arrayCount(targets)
    if 0 == count then
        self.isStopped = true
        self.trigger = trigger
        self.toEnd = toEnd
    else
        for i = 1, count do
            xx.arrayPush(TweenStop(targets[i], trigger, toEnd))
        end
    end
end
function Tween:to(properties, time, playback, ease, onPlayback, onUpdate)
    for _, target in ipairs(self.targets) do
        local curMap = self.curValueMap[target]
        local endMap = self.endValueMap[target]
        for k, v in pairs(properties) do
            if not curMap[k] then
                curMap[k] = target[k]
            end
            if not playback then
                endMap[k] = xx.isTable(v) and v[xx.arrayCount(v)] or v
            elseif not endMap[k] then
                endMap[k] = curMap[k]
            end
        end
    end
    xx.arrayPush(self.stepList, TweenStep(self, true, properties, time, playback, ease, onPlayback, onUpdate))
    return self
end
function Tween:by(properties, time, playback, ease, onPlayback, onUpdate)
    for _, target in ipairs(self.targets) do
        local curMap = self.curValueMap[target]
        local endMap = self.endValueMap[target]
        for k, v in pairs(properties) do
            if not curMap[k] then
                curMap[k] = target[k]
            end
            if not playback then
                if xx.isTable(v) then
                    v = v[xx.arrayCount(v)]
                end
                endMap[k] = (endMap[k] or curMap[k]) + v
            elseif not endMap[k] then
                endMap[k] = curMap[k]
            end
        end
    end
    xx.arrayPush(self.stepList, TweenStep(self, false, properties, time, playback, ease, onPlayback, onUpdate))
    return self
end
function Tween:setTo(properties)
    for _, target in ipairs(self.targets) do
        local curMap = self.curValueMap[target]
        local endMap = self.endValueMap[target]
        for k, v in pairs(properties) do
            if not curMap[k] then
                curMap[k] = target[k]
            end
            endMap[k] = v
        end
    end
    xx.arrayPush(self.stepList, TweenSetStep(self, true, properties))
    return self
end
function Tween:setBy(properties)
    for _, target in ipairs(self.targets) do
        local curMap = self.curValueMap[target]
        local endMap = self.endValueMap[target]
        for k, v in pairs(properties) do
            if not curMap[k] then
                curMap[k] = target[k]
            end
            endMap[k] = (endMap[k] or curMap[k]) + v
        end
    end
    xx.arrayPush(self.stepList, TweenSetStep(self, false, properties))
    return self
end
function Tween:rateTo(rate)
    xx.arrayPush(self.stepList, TweenRateStep(self, true, rate))
    return self
end
function Tween:rateBy(rate)
    xx.arrayPush(self.stepList, TweenRateStep(self, false, rate))
    return self
end
function Tween:sleep(time)
    xx.arrayPush(self.stepList, TweenSleepStep(self, time))
    return self
end
function Tween:frame(count)
    xx.arrayPush(self.stepList, TweenFrameStep(self, count))
    return self
end
function Tween:loop(count, preCount, onOnce)
    xx.arrayPush(self.stepList, TweenLoopStep(self, count, preCount, onOnce))
    return self
end
function Tween:callback(callback)
    xx.arrayPush(self.stepList, TweenCallbackStep(self, callback))
    return self
end
local MTween = xx.Class("xx.MTween", xx.Module)
function MTween:ctor()
    self._isPaused = false
    self._tweenList = {}
    self._uidTweenMap = {}
    self._targetUIDsMap = {}
    self._noticeHandlerMap[GIdentifiers.nb_timer] = self.onAppTimer
    self._noticeHandlerMap[GIdentifiers.nb_pause] = self.onAppPause
    self._noticeHandlerMap[GIdentifiers.nb_resume] = self.onAppResume
    self._noticeHandlerMap[GIdentifiers.ni_tween_new] = self.onNew
    self._noticeHandlerMap[GIdentifiers.ni_tween_stop] = self.onStop
end
function MTween:onAppTimer(result, interval)
    if self._isPaused or interval >= 1000 then
        return
    end
    local uids
    for index = xx.arrayCount(self._tweenList), 1, -1 do
        local tween = self._tweenList[index]
        if xx.arrayCount(tween.stopList) > 0 then
            for _, stop in ipairs(tween.stopList) do
                tween.trigger = tween.trigger or stop.trigger
                local map = tween.endValueMap[stop.target]
                xx.arrayRemove(tween.targets, stop.target)
                tween.curValueMap[stop.target] = nil
                tween.endValueMap[stop.target] = nil
                uids = self._targetUIDsMap[stop.target]
                if 1 == xx.arrayCount(uids) then
                    self._targetUIDsMap[stop.target] = nil
                else
                    xx.arrayRemove(uids, tween.uid)
                end
                if stop.toEnd then
                    for k, v in pairs(map) do
                        stop.target[k] = v
                    end
                end
            end
            xx.arrayContains(tween.stopList)
            tween.isStopped = tween.isStopped or 0 == xx.arrayCount(tween.targets)
        end
        repeat
            if tween.isStopped then
                xx.arrayRemoveAt(self._tweenList, index)
                self._uidTweenMap[tween.uid] = nil
                for _, target in ipairs(tween.targets) do
                    uids = self._targetUIDsMap[target]
                    if 1 == xx.arrayCount(uids) then
                        self._targetUIDsMap[target] = nil
                    else
                        xx.arrayRemove(uids, tween.uid)
                    end
                    if tween.toEnd then
                        local map = tween.endValueMap[target]
                        for k, v in pairs(map) do
                            target[k] = v
                        end
                    end
                end
                if tween.trigger then
                    tween:resolve()
                else
                    tween:cancel()
                end
                break
            end
            if tween.isPaused then
                break
            end
            local time = interval * tween.rate
            if time < 0 then
                break
            end
            while self._uidTweenMap[tween.uid] and time > 0 and not tween.isCompleted do
                time = tween.stepList[tween.stepIndex]:update(time)
            end
            if tween.isCompleted then
                xx.arrayRemoveAt(self._tweenList, index)
                self._uidTweenMap[tween.uid] = nil
                for _, target in ipairs(tween.targets) do
                    uids = self._targetUIDsMap[target]
                    if 1 == xx.arrayCount(target) then
                        self._targetUIDsMap[target] = nil
                    else
                        xx.arrayRemove(uids, tween.uid)
                    end
                end
                tween:resolve()
            end
        until true
    end
end
function MTween:onAppPause(result)
    self._isPaused = true
end
function MTween:onAppResume(result)
    self._isPaused = false
end
function MTween:onNew(result, ...)
    local tween = Tween(...)
    xx.arrayPush(self._tweenList, tween)
    self._uidTweenMap[tween.uid] = tween
    for _, target in ipairs(tween.targets) do
        if self._targetUIDsMap[target] then
            xx.arrayPush(self._targetUIDsMap[target], tween.uid)
        else
            self._targetUIDsMap[target] = {tween.uid}
        end
    end
    result.data = tween
end
function MTween:onStop(result, target, trigger, toEnd)
    if self._targetUIDsMap[target] then
        local uids = self._targetUIDsMap[target]
        for _, uid in ipairs(uids) do
            self._uidTweenMap[uid]:stop(trigger, toEnd, target)
        end
    end
end
function xx.tween(...)
    return xx.notify(GIdentifiers.ni_tween_new, ...)
end
function xx.tweenStop(target, trigger, toEnd)
    xx.notify(GIdentifiers.ni_tween_stop, target, trigger, toEnd)
end
xx.getInstance("xx.MTween")
local MLauncher = xx.Class("xx.MLauncher", xx.Module)
function MLauncher:ctor()
    self._noticeHandlerMap[GIdentifiers.nb_lauch] = self.onLaunch
end
function MLauncher:onLaunch(result)
    ---@type Root
    xx.root = xx.Root(xx.Util.GetRootCVS(), xx.Util.GetRootGO())
    xx.addInstance(xx.root)
end
xx.getInstance("xx.MLauncher")
local MLoad = xx.Class("xx.MLoad", xx.Module)
function MLoad:ctor()
    self._noticeHandlerMap[GIdentifiers.ni_load] = self.onLoad
    self._noticeHandlerMap[GIdentifiers.ni_load_stop] = self.onStop
end
function MLoad:onLoad(result, url, type, tryCount, tryDelay, timeout, onRetry, onComplete)
    result.data =
        xx.Util.Load(
        url,
        function(...)
            if onComplete then
                onComplete(...)
            end
        end,
        function(...)
            if onRetry then
                onRetry(...)
            end
        end,
        type,
        tryCount or 0,
        tryDelay or 1000,
        timeout or 0
    )
end
function MLoad:onStop(result, id)
    xx.Util.LoadStop(id)
end
function xx.load(url, onComplete, onRetry, type, tryCount, tryDelay, timeout)
    xx.notify(
        GIdentifiers.ni_load,
        url,
        type,
        tryCount,
        tryDelay,
        timeout,
        xx.Callback(onRetry),
        xx.Callback(onComplete)
    )
end
function xx.loadBinary(url, onComplete, onRetry, tryCount, tryDelay, timeout)
    xx.load(url, onComplete, onRetry, GIdentifiers.load_type_binary, tryCount, tryDelay, timeout)
end
function xx.loadString(url, onComplete, onRetry, tryCount, tryDelay, timeout)
    xx.load(url, onComplete, onRetry, GIdentifiers.load_type_string, tryCount, tryDelay, timeout)
end
function xx.loadTexture(url, onComplete, onRetry, tryCount, tryDelay, timeout)
    xx.load(url, onComplete, onRetry, GIdentifiers.load_type_texture, tryCount, tryDelay, timeout)
end
function xx.loadSprite(url, onComplete, onRetry, tryCount, tryDelay, timeout)
    xx.load(url, onComplete, onRetry, GIdentifiers.load_type_sprite, tryCount, tryDelay, timeout)
end
function xx.loadAudio(url, onComplete, onRetry, tryCount, tryDelay, timeout)
    xx.load(url, onComplete, onRetry, GIdentifiers.load_type_audioclip, tryCount, tryDelay, timeout)
end
function xx.loadAssetBundle(url, onComplete, onRetry, tryCount, tryDelay, timeout)
    xx.load(url, onComplete, onRetry, GIdentifiers.load_type_assetbundle, tryCount, tryDelay, timeout)
end
function xx.loadAsync(url, onRetry, type, tryCount, tryDelay, timeout)
    local promise = xx.Promise()
    return promise, xx.load(
        url,
        function(...)
            promise:resolve(...)
        end,
        onRetry,
        type,
        tryCount,
        tryDelay,
        timeout
    )
end
function xx.loadBinaryAsync(url, onRetry, tryCount, tryDelay, timeout)
    return xx.loadAsync(url, onRetry, GIdentifiers.load_type_binary, tryCount, tryDelay, timeout)
end
function xx.loadStringAsync(url, onRetry, tryCount, tryDelay, timeout)
    return xx.loadAsync(url, onRetry, GIdentifiers.load_type_string, tryCount, tryDelay, timeout)
end
function xx.loadTextureAsync(url, onRetry, tryCount, tryDelay, timeout)
    return xx.loadAsync(url, onRetry, GIdentifiers.load_type_texture, tryCount, tryDelay, timeout)
end
function xx.loadSpriteAsync(url, onRetry, tryCount, tryDelay, timeout)
    return xx.loadAsync(url, onRetry, GIdentifiers.load_type_sprite, tryCount, tryDelay, timeout)
end
function xx.loadAudioAsync(url, onRetry, tryCount, tryDelay, timeout)
    return xx.loadAsync(url, onRetry, GIdentifiers.load_type_audioclip, tryCount, tryDelay, timeout)
end
function xx.loadAssetBundleAsync(url, onRetry, tryCount, tryDelay, timeout)
    return xx.loadAsync(url, onRetry, GIdentifiers.load_type_assetbundle, tryCount, tryDelay, timeout)
end
function xx.loadStop(id)
    xx.notify(GIdentifiers.ni_load_stop, id)
end
xx.getInstance("xx.MLoad")
