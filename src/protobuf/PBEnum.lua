---Protobuf 枚举信息
---@class PBEnum:ObjectEx by wx771720@outlook.com 2019-12-31 16:01:10
---@field root PBRoot 根
---@field name string 枚举名
---@field idNameMap table<number,string> id 对应名字
---@field nameIDMap table<string,number> 名字对应 id
local PBEnum = xx.Class("PBEnum")
---构造函数
function PBEnum:ctor(root, name)
    self.idNameMap = {}
    self.nameIDMap = {}

    self.root = root
    self.name = name
end

return PBEnum
