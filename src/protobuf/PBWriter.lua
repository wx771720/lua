---Protobuf 写
---@class PBWriter:ObjectEx by wx771720@outlook.com 2019-12-31 11:31:53
---@field buffer number[] 字节数组
---@field length number 长度
local PBWriter = xx.Class("PBWriter")
---构造函数
function PBWriter:ctor()
    self.buffer = {}
    self.length = 0
end

---缓存池
---@type PBWriter[]
PBWriter._pool = {}
---@return PBWriter
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

---在末尾定入 Protobuf 写中的数据
---@type fun(writer:PBWriter):PBWriter
---@param writer PBWriter Protobuf 写
---@return PBWriter self
function PBWriter:write(writer)
    for i = 1, writer.length do
        self.length = self.length + 1
        self.buffer[self.length] = writer.buffer[i]
    end
    return self
end
-- -----------------------------------------------------------------------------
-- 字节写入
-- -----------------------------------------------------------------------------
---写入 varint 类型数值
---@type fun(value:number,numBits:number)
---@param value number 数值
---@param numBits number 位数，默认 32 位
function PBWriter:_varint(value, numBits)
    numBits = numBits or 32
    -- 写入非负数
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
---写入固定长度数值
---@type fun(bits:Bits)
---@param bits bits 位数组
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
-- -----------------------------------------------------------------------------
-- 数值写入
-- -----------------------------------------------------------------------------
---写入有符号 32 位整数
---@type fun(value:number):PBWriter
---@param value number
---@return PBWriter self
function PBWriter:int32(value)
    self:_varint(value)
    return self
end
---写入无符号 32 位整数
---@type fun(value:number):PBWriter
---@param value number
---@return PBWriter self
function PBWriter:uint32(value)
    self:_varint(value)
    return self
end
---写入 zigzag 编码的 32 位整数
---@type fun(value:number):PBWriter
---@param value number
---@return PBWriter self
function PBWriter:sint32(value)
    self:uint32(xx.Bit.bxor(xx.Bit.shift(value, -1), xx.Bit.ashift(value, 31)))
    return self
end
---写入有符号 64 位整数
---@type fun(value:number):PBWriter
---@param value number
---@return PBWriter self
function PBWriter:int64(value)
    self:_varint(value, 64)
    return self
end
---写入无符号 64 位整数
---@type fun(value:number):PBWriter
---@param value number
---@return PBWriter self
function PBWriter:uint64(value)
    self:_varint(value, 64)
    return self
end
---写入 zigzag 编码的 64 位整数
---@type fun(value:number):PBWriter
---@param value number
---@return PBWriter self
function PBWriter:sint64(value)
    self:uint64(xx.Bit.bxor(xx.Bit.shift(value, -1, 64), xx.Bit.ashift(value, 63, 64), 64))
    return self
end
---写入布尔值
---@type fun(value:boolean):PBWriter
---@param value boolean
---@return PBWriter self
function PBWriter:bool(value)
    self.length = self.length + 1
    self.buffer[self.length] = value and 1 or 0
    return self
end
---写入 32 位固定长度整数
---@type fun(value:number):PBWriter
---@param value number
---@return PBWriter self
function PBWriter:fixed32(value)
    local bits = xx.Bit.intBits(value)
    self:_fixed(bits)
    xx.Bit.cache(bits)
    return self
end
---写入 32 位固定长度整数
---@type fun(value:number):PBWriter
---@param value number
---@return PBWriter self
function PBWriter:sfixed32(value)
    self:fixed32(value)
    return self
end
---写入单精度浮点数
---@type fun(value:number):PBWriter
---@param value number
---@return PBWriter self
function PBWriter:float(value)
    local bits = xx.Bit.decimalBits(value)
    self:_fixed(bits)
    xx.Bit.cache(bits)
    return self
end
---写入 64 位固定长度整数
---@type fun(value:number):PBWriter
---@param value number
---@return PBWriter self
function PBWriter:fixed64(value)
    local bits = xx.Bit.intBits(value, 64)
    self:_fixed(bits)
    xx.Bit.cache(bits)
    return self
end
---写入 64 位固定长度整数
---@type fun(value:number):PBWriter
---@param value number
---@return PBWriter self
function PBWriter:sfixed64(value)
    self:fixed64(value)
    return self
end
---写入双精度浮点数
---@type fun(value:number):PBWriter
---@param value number
---@return PBWriter self
function PBWriter:double(value)
    local bits = xx.Bit.decimalBits(value, 64)
    self:_fixed(bits)
    xx.Bit.cache(bits)
    return self
end
---写入 utf8 编码的字符串
---@type fun(value:string):PBWriter
---@param value string
---@return PBWriter self
function PBWriter:string(value)
    self:uint32(#value)
    for i = 1, #value do
        self.length = self.length + 1
        self.buffer[self.length] = string.byte(value, i)
    end
    return self
end
---写入 utf8 编码的字符串
---@type fun(value:string):PBWriter
---@param value string
---@return PBWriter self
function PBWriter:bytes(value)
    return self:string(value)
end

return PBWriter
