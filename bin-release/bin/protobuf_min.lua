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
