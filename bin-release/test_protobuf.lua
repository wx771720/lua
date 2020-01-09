---run cmd:
---cd bin-release
---lua test_protobuf.lua
require "bin.protobuf"

---入口类
---@class Main:ObjectEx by wx771720@outlook.com 2020-01-09 16:11:05
local Main = xx.Class("Main")
---构造函数
function Main:ctor()
end

---测试 Protobuf
function Main:test()
    local proto = self:readFile("protobuf.proto")
    -- 解析 proto
    xx.Protobuf.parse(proto)

    ---@class UserProto
    local user = {
        ID = 1,
        Name = "wx771720",
        Gender = 1,
        Age = 30,
        Titles = {"Coder", "Father"}
    }
    -- 编码
    local bytes = xx.Protobuf.encode("xx", "User", user)
    self:writeFile("protobuf_user.bytes", bytes)
    -- 解码
    ---@type UserProto
    local userDecoded = xx.Protobuf.decode("xx", "User", bytes)
    -- 打印
    local titleStr = userDecoded.Titles[1]
    for i = 2, #userDecoded.Titles do
        titleStr = titleStr .. "," .. userDecoded.Titles[i]
    end
    print(
        string.format(
            "user decoded : ID = %s, Name = %s, Gender = %d, Age = %d, Titles = %s",
            userDecoded.ID,
            userDecoded.Name,
            userDecoded.Gender,
            userDecoded.Age,
            titleStr
        )
    )
    -- user decoded : ID = 1, Name = wx771720, Gender = 1, Age = 30, Titles = Coder,Father
end

function Main:readFile(path)
    local file = io.open(path, "rb")
    local content = file:read("*all")
    file:close()
    return content
end
function Main:writeFile(path, value)
    local file = io.open(path, "wb")
    file:write(value)
    file:close()
end

---执行测试
Main():test()
