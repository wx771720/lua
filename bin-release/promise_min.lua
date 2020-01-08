xx = xx or {}
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
xx.version = "1.0.0"
print("xx(lua) version: " .. xx.version)
local __uidSeed = 0
function xx.newUID()
    __uidSeed = __uidSeed + 1
    return string.format("xx_lua_%d", __uidSeed)
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
