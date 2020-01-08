---Protobuf 消息信息
---@class PBMessage:ObjectEx by wx771720@outlook.com 2019-12-31 16:00:40
---@field root PBRoot 根
---@field name string 消息名
---@field fieldIDs number[] 字段 id 列表
---@field fieldIDMap table<number,PBField> 字段 id对应信息
local PBMessage = xx.Class("PBMessage")
---构造函数
function PBMessage:ctor(root, name)
    self.fieldIDs = {}
    self.fieldIDMap = {}

    self.root = root
    self.name = name
end

return PBMessage
