---Protobuf 读
---@class PBReader:ObjectEx by wx771720@outlook.com 2020-01-01 11:26:25
---@field buffer string 数据
---@field length number 长度
---@field position number 当前读取位置
local PBReader = xx.Class("PBReader")
---构造函数
function PBReader:ctor(buffer)
    self.buffer = buffer
    self.length = #buffer
    self.position = 1
end
-- -----------------------------------------------------------------------------
-- 字节读取
-- -----------------------------------------------------------------------------
---读取 varint 数值，并写入 bits
---@type fun(bits:Bits):Bits
---@param bits Bits 位数组
---@return Bits bits
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
---读取固定长度字节，并写入 bits
---@type fun(bits:Bits):Bits
---@param bits Bits 位数组
---@return Bits bits
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
-- -----------------------------------------------------------------------------
-- 数值读取
-- -----------------------------------------------------------------------------
---读取有符号 32 位整数
---@type fun():number
---@return number
function PBReader:int32()
    local bits = self:_varint(xx.Bit.new(64))
    local value = xx.Bit.int(xx.Bit.number(bits))
    xx.Bit.cache(bits)
    return value
end
---读取无符号 32 位整数
---@type fun():number
---@return number
function PBReader:uint32()
    local bits = self:_varint(xx.Bit.new(32))
    local value = xx.Bit.uint(xx.Bit.number(bits))
    xx.Bit.cache(bits)
    return value
end
---读取 zigzag 编码的 32 位整数
---@type fun():number
---@return number
function PBReader:sint32()
    local value = self:uint32()
    return xx.Bit.int(xx.Bit.bxor(xx.Bit.shift(value, 1), -xx.Bit.band(value, 1)))
end
---读取有符号 64 位整数
---@type fun():number
---@return number
function PBReader:int64()
    local bits = self:_varint(xx.Bit.new(64))
    local value = xx.Bit.number(bits)
    xx.Bit.cache(bits)
    return value
end
---读取无符号 64 位整数
---@type fun():number
---@return number
function PBReader:uint64()
    local bits = self:_varint(xx.Bit.new(64))
    local value = xx.Bit.uint(xx.Bit.number(bits), 64)
    xx.Bit.cache(bits)
    return value
end
---读取 zigzag 编码的 64 位整数
---@type fun():number
---@return number
function PBReader:sint64()
    local value = self:uint64()
    return xx.Bit.bxor(xx.Bit.shift(value, 1, 64), -xx.Bit.band(value, 1, 64), 64)
end
---读取布尔值
---@type fun():boolean
---@return boolean
function PBReader:bool()
    local value = string.byte(self.buffer, self.position)
    self.position = self.position + 1
    return 0 ~= value
end
---读取 32 位固定长度整数
---@type fun():number
---@return number
function PBReader:fixed32()
    local bits = self:_fixed(xx.Bit.new(32))
    local value = xx.Bit.uint(xx.Bit.number(bits))
    xx.Bit.cache(bits)
    return value
end
---读取 zigzag 编码的 32 位固定长度整数
---@type fun():number
---@return number
function PBReader:sfixed32()
    return self:fixed32()
end
---读取单精度浮点数
---@type fun():number
---@return number
function PBReader:float()
    local bits = self:_fixed(xx.Bit.new(32))
    local value = xx.Bit.decimal(bits)
    xx.Bit.cache(bits)
    return value
end
---读取 64 位固定长度整数
---@type fun():number
---@return number
function PBReader:fixed64()
    local bits = self:_fixed(xx.Bit.new(64))
    local value = xx.Bit.uint(xx.Bit.number(bits), 64)
    xx.Bit.cache(bits)
    return value
end
---读取 zigzag 编码的 64 位固定长度整数
---@type fun():number
---@return number
function PBReader:sfixed64()
    return self:fixed64()
end
---读取双精度浮点数
---@type fun():number
---@return number
function PBReader:double()
    local bits = self:_fixed(xx.Bit.new(64))
    local value = xx.Bit.decimal(bits, 64)
    xx.Bit.cache(bits)
    return value
end
---读取 utf8 编码的字符串
---@type fun():string
---@return string
function PBReader:string()
    local length = self:uint32()
    local value = string.sub(self.buffer, self.position, self.position + length - 1)
    self.position = self.position + length
    return value
end
---读取 utf8 编码的字符串
---@type fun():string
---@return string
function PBReader:bytes()
    return self:string()
end

return PBReader
