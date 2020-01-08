---位数组
---@class Bits
---@field numBits number 位数
local Bits

---位操作
---@class Bit:ObjectEx by wx771720@outlook.com 2020-01-02 18:15:39
local Bit = xx.Class("Bit")

---@see Bit
xx.Bit = Bit

---位数 - 最小值
---@type table<number,number>
Bit._bitMinMap = {1}
for i = 2, 64 do
    Bit._bitMinMap[i] = 2 * Bit._bitMinMap[i - 1]
end
---位数组缓存
---@type Bits[]
Bit._caches = {}
---位数组缓存数量
---@type number
Bit._numCaches = 0

---新建位数组
---@type fun(numBits:number,bit:number):Bits
---@param numBits number 位数
---@param bit number 初始化位的值，默认 0
---@return Bits 位数组
function Bit.new(numBits, bit)
    ---@type Bits
    local bits
    -- 从缓存中获取
    if Bit._numCaches > 0 then
        bits = Bit._caches[Bit._numCaches]
        Bit._caches[Bit._numCaches] = nil
        Bit._numCaches = Bit._numCaches - 1
    else
        bits = {}
    end
    bits.numBits = numBits
    -- 赋值
    bit = bit or 0
    for i = 1, bits.numBits do
        bits[i] = bit
    end
    return bits
end
---拷贝位数组
---@type fun(bits:Bits,beginBit:number,endBit:number):Bits
---@param bits Bits 位数组
---@param beginBit number 起始位，默认 nil 表示 1
---@param endBit number 结束位，默认 nil 表示 bits.numBits
---@return Bits 返回拷贝的位数组
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
---缓存位数组
---@type fun(...:Bits)
---@vararg Bits
function Bit.cache(...)
    for _, bits in ipairs({...}) do
        xx.arrayInsert(Bit._caches, bits)
    end
end
---重置位数组
---@type fun(bits:Bits,bit:number):Bits
---@param bits Bits 位数组
---@param bit number 初始化位的值，默认 0
---@return Bits bits
function Bit.reset(bits, bit)
    bit = bit or 0
    for i = 1, bits.numBits do
        bits[i] = bit
    end
    return bits
end
---判断位数组是否全是 0
---@type fun(bits:Bits,beginBit:number,endBit:number):boolean
---@param bits Bits 位数组
---@param beginBit number 起始位，默认 nil 表示 1
---@param endBit number 结束位，默认 nil 表示 bits.numBits
---@return boolean
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
-- -----------------------------------------------------------------------------
-- 转换为二进制
-- -----------------------------------------------------------------------------
---将整数转换为位数组
---@type fun(value:number,numBits:number):Bits
---@param value number 数值
---@param numBits number 位数
---@return Bits 返回位数组
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
---将单精度小数转换为位数组
---@type fun(value:number,numBits:number):Bits
---@param value number 数值
---@param numBits number 位数，默认 32，只能是 32 或者 64
---@return Bits 返回位数组
function Bit.decimalBits(value, numBits)
    local bits = Bit.new(64 == numBits and 64 or 32)
    if 0 == value then
        return bits
    end
    -- 符号位
    if value < 0 then
        bits[bits.numBits] = 1
        value = -value
    end
    -- 将整数和小数转换为二进制
    local bitsAll = Bit.new(bits.numBits * 2)
    -- 有效值开始和结束位
    local beginBit, endBit
    -- 整数
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
    -- 小数
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
    -- 有效值
    if beginBit and endBit then
        --- 指数偏移，指数位数，小数位数
        local offset, numExponents, numDecimals
        if 32 == bits.numBits then
            offset, numExponents, numDecimals = 127, 8, 23
        else
            offset, numExponents, numDecimals = 1023, 11, 52
        end
        -- 指数
        local bitsExponent = Bit.intBits(offset + bits.numBits - beginBit, 12)
        for i = 1, numExponents do
            bits[numDecimals + i] = bitsExponent[i]
        end
        Bit.cache(bitsExponent)
        -- 尾数
        for i = numDecimals, 1, -1 do
            beginBit = beginBit + 1
            if beginBit > endBit then
                break
            end
            bits[i] = bitsAll[beginBit]
        end
        -- 0 舍 1 入
        if beginBit < endBit and 1 == bitsAll[beginBit + 1] then
            local carry
            bits, carry = Bit.bitsPlusOnce(bits, 1, numDecimals)
            -- 溢出右规
            if carry then
                -- 0 舍 1 入
                if 1 == bits[1] then
                    bits, carry = Bit.bitsPlusOnce(bits, 1, numDecimals)
                end
                -- 右规
                for i = 1, numDecimals - 1 do
                    bits[i] = bits[i + 1]
                end
                bits[numDecimals] = carry and 1 or 0
                -- 指数进位
                Bit.bitsPlusOnce(bits, numDecimals + 1, bits.numBits - 1)
            end
        end
    end
    Bit.cache(bitsAll)
    return bits
end
---位数组加1
---@type fun(bits:Bits,beginBit:number,endBit:number):Bits,boolean
---@param bits Bits 位数组
---@param beginBit number 起始位，默认 nil 表示 1
---@param endBit number 结束位，默认 nil 表示 bits.numBits
---@return Bits,boolean 返回 bits，是否需要进位
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
-- -----------------------------------------------------------------------------
-- 转换为数值
-- -----------------------------------------------------------------------------
---将位数组转换为数值
---@type fun(bits:Bits,beginBit:number,endBit:number):number
---@param bits Bits 位数组
---@param beginBit number 起始位，默认 nil 表示 1
---@param endBit number 结束位，默认 nil 表示 bits.numBits
---@return number
function Bit.number(bits, beginBit, endBit)
    beginBit = beginBit or 1
    endBit = endBit or bits.numBits
    -- 解析 64 位负数
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
---将位数组转换为浮点数
---@type fun(bits:Bits):number
---@param bits Bits 位数组
---@return number
function Bit.decimal(bits)
    -- 0
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
    -- 指数
    local exponent = Bit.number(bits, numDecimals + 1, bits.numBits - 1)
    -- 小数点偏移
    local dotOffset = exponent - offset
    -- 超出范围
    if dotOffset > bits.numBits or dotOffset < -bits.numBits then
        return 0
    end
    -- 整数
    local int = 0
    if 0 == dotOffset then
        int = 1
    elseif dotOffset > 0 then
        local intBits = Bit.clone(bits, numDecimals - dotOffset + 1, numDecimals + 1)
        intBits[intBits.numBits] = 1
        int = Bit.number(intBits)
        Bit.cache(intBits)
    end
    -- 小数
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
    -- 实数
    local value = int + decimal
    return 1 == bits[bits.numBits] and -value or value
end
---将数值转换为指定位数的有符号数值
---@type fun(value:number,numBits:number):number
---@param value number 数值
---@param numBits number 位数，默认 32 位
---@return number
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
---将数值转换为指定位数的有符号数值
---@type fun(value:number,numBits:number):number
---@param value number 数值
---@param numBits number 位数，默认 32 位
---@return number
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
-- -----------------------------------------------------------------------------
-- 位运算
-- -----------------------------------------------------------------------------
---按位取反
---@type fun(bits:Bits):Bits
---@param bits Bits 位数组
---@return Bits bits
function Bit.bitsNOT(bits)
    for i = 1, bits.numBits do
        bits[i] = 1 == bits[i] and 0 or 1
    end
    return bits
end
---按位与
---@type fun(aBits:Bits,bBits:Bits,bits:Bits):Bits
---@param aBits Bits 源位数组
---@param bBits Bits 源位数组
---@param bits Bits 输出的位数组
---@return Bits bits
function Bit.bitsAND(aBits, bBits, bits)
    for i = 1, bits.numBits do
        bits[i] = (1 == aBits[i] and 1 == bBits[i]) and 1 or 0
    end
    return bits
end
---按位或
---@type fun(aBits:Bits,bBits:Bits,bits:Bits):Bits
---@param aBits Bits 源位数组
---@param bBits Bits 源位数组
---@param bits Bits 输出的位数组
---@return Bits bits
function Bit.bitsOR(aBits, bBits, bits)
    for i = 1, bits.numBits do
        bits[i] = (0 == aBits[i] and 0 == bBits[i]) and 0 or 1
    end
    return bits
end
---按位异或
---@type fun(aBits:Bits,bBits:Bits,bits:Bits):Bits
---@param aBits Bits 源位数组
---@param bBits Bits 源位数组
---@param bits Bits 输出的位数组
---@return Bits bits
function Bit.bitsXOR(aBits, bBits, bits)
    for i = 1, bits.numBits do
        bits[i] = aBits[i] == bBits[i] and 0 or 1
    end
    return bits
end
---循环位移操作
---@type fun(bits:Bits,offset:number):Bits
---@param bits Bits 位数组
---@param offset number 负数左移，正数右移，默认 nil 或者 0 取整
---@return Bits bits
function Bit.bitsRotate(bits, offset)
    local copy = Bit.clone(bits)
    Bit.reset(bits)
    -- 位数组低位在低下标
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
---逻辑位移操作（用 0 补位）
---@type fun(bits:Bits,offset:number):Bits
---@param bits Bits 位数组
---@param offset number 负数左移，正数右移，默认 nil 或者 0 取整
---@return Bits bits
function Bit.bitsShift(bits, offset)
    local copy = Bit.clone(bits)
    Bit.reset(bits)
    -- 位数组低位在低下标
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
---算术位移操作（保留符号位）
---@type fun(bits:Bits,offset:number):Bits
---@param bits Bits 位数组
---@param offset number 负数左移，正数右移，默认 nil 或者 0 取整
---@return Bits bits
function Bit.bitsAShift(bits, offset)
    -- 同逻辑位移操作
    if 0 == bits[bits.numBits] or offset <= 0 then
        return Bit.bitsShift(bits, offset)
    end
    -- 位数组低位在低下标
    offset = offset and -offset or 0
    -- 需要移动的位数
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
-- -----------------------------------------------------------------------------
-- 数值运算
-- -----------------------------------------------------------------------------
---取反
---@type fun(value:number,numBits:numBits):number
---@param value number 数值
---@param numBits number 位数，默认 32 位
---@return number
function Bit.bnot(value, numBits)
    numBits = numBits or 32
    local bits = Bit.bitsNOT(Bit.intBits(value, numBits))
    value = Bit.number(bits)
    Bit.cache(bits)
    return value
end
---与操作
---@type fun(a:number,b:number,numBits:number):number
---@param a number 源数值
---@param b number 源数值
---@param numBits number 位数，默认 32 位
---@return number
function Bit.band(a, b, numBits)
    numBits = numBits or 32
    local aBits = Bit.intBits(a, numBits)
    local bBits = Bit.intBits(b, numBits)
    local bits = Bit.bitsAND(aBits, bBits, Bit.new(numBits))
    a = Bit.number(bits)
    Bit.cache(aBits, bBits, bits)
    return a
end
---或操作
---@type fun(a:number,b:number,numBits:number):number
---@param a number 源数值
---@param b number 源数值
---@param numBits number 位数，默认 32 位
---@return number
function Bit.bor(a, b, numBits)
    numBits = numBits or 32
    local aBits = Bit.intBits(a, numBits)
    local bBits = Bit.intBits(b, numBits)
    local bits = Bit.bitsOR(aBits, bBits, Bit.new(numBits))
    a = Bit.number(bits)
    Bit.cache(aBits, bBits, bits)
    return a
end
---异或操作
---@type fun(a:number,b:number,numBits:number):number
---@param a number 源数值
---@param b number 源数值
---@param numBits number 位数，默认 32 位
---@return number
function Bit.bxor(a, b, numBits)
    numBits = numBits or 32
    local aBits = Bit.intBits(a, numBits)
    local bBits = Bit.intBits(b, numBits)
    local bits = Bit.bitsXOR(aBits, bBits, Bit.new(numBits))
    a = Bit.number(bits)
    Bit.cache(aBits, bBits, bits)
    return a
end
---循环位移操作
---@type fun(value:number,offset:number,numBits:number):number
---@param value number 数值
---@param offset number 移动位数，负数左移，正数右移，默认 nil 或者 0 取整
---@param numBits number 位数，默认 32 位
---@return number
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
---逻辑位移操作（用 0 补位）
---@type fun(value:number,offset:number,numBits:number):number
---@param value number 数值
---@param offset number 移动位数，负数左移，正数右移，默认 nil 或者 0 取整
---@param numBits number 位数，默认 32 位
---@return number
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
---算术位移操作（保留符号位）
---@type fun(value:number,offset:number,numBits:number):number
---@param value number 数值
---@param offset number 移动位数，负数左移，正数右移，默认 nil 或者 0 取整
---@param numBits number 位数，默认 32 位
---@return number
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

return Bit
