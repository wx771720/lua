---@type xx
require "bin-release.xx"
-- ---@type Promise
-- require "bin-release.promise"
-- ---@type Protobuf
-- require "bin-release.protobuf"

---入口类
---@class main:ObjectEx by wx771720@outlook.com 2019-10-08 10:17:41
local main = xx.Class("main")
---构造函数
function main:ctor()
    -- self._noticeHandlerMap["init"] = self.onInit
    self:onInit()
end

function main:onInit()
    print("--------on Init")

    -- -----------------------------------------------------------------------------
    -- Promise
    -- -----------------------------------------------------------------------------
    -- local promise = xx.Promise()
    -- promise:next(
    --     function(...)
    --         print(...)
    --         return ...
    --     end,
    --     function(err)
    --         print(err)
    --         error(err)
    --     end
    -- )
    -- promise:resolve(1, "22", true)
    -- -- promise:reject("canceled")
    -- xx.Promise.asyncLoop()
    -- xx.Promise.asyncLoop()
    -- xx.Promise.asyncLoop()
    -- -----------------------------------------------------------------------------
    -- Bit
    -- -----------------------------------------------------------------------------
    -- local bits, value

    -- bits = xx.Bit.decimalBits(8.25, 64)
    -- print(unpack(bits))
    -- value = xx.Bit.decimal(bits)
    -- print(value)

    -- bits = xx.Bit.decimalBits(1.25, 64)
    -- print(unpack(bits))
    -- value = xx.Bit.decimal(bits)
    -- print(value)

    -- bits = xx.Bit.decimalBits(0.0625, 64)
    -- print(unpack(bits))
    -- value = xx.Bit.decimal(bits)
    -- print(value)

    -- bits = xx.Bit.decimalBits(0)
    -- print(unpack(bits))
    -- value = xx.Bit.decimal(bits)
    -- print(value)
    -- -----------------------------------------------------------------------------
    -- Protobuf
    -- -----------------------------------------------------------------------------
    -- local proto = self:readFile("bin-release/excel.proto")
    -- print(proto)
    -- xx.Protobuf.parse(proto)

    -- local bytes = self:readFile("bin-release/TestMessage.bytes")
    -- local value = xx.Protobuf.decode("xx", "TestMessageAry", bytes)

    -- if value then
    --     print(xx.JSON.toString(value))

    --     bytes = xx.Protobuf.encode("xx", "TestMessageAry", value)
    --     self:writeFile("bin-release/TestMessage2.bytes", bytes)
    -- else
    --     print("decode error")
    -- end
end

function main:readFile(path)
    local file = io.open(path, "rb")
    local content = file:read("*all")
    file:close()
    return content
end
function main:writeFile(path, value)
    local file = io.open(path, "wb")
    file:write(value)
    file:close()
end

main()
