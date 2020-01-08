---Protobuf 根信息
---@class PBRoot:ObjectEx by wx771720@outlook.com 2019-12-31 16:04:40
---@field package string 包名
---@field enumMap table<string,PBEnum> 枚举名对应信息
---@field messageMap table<string,PBMessage> 消息名对应信息
local PBRoot = xx.Class("PBRoot")
---构造函数
function PBRoot:ctor(package)
    self.enumMap = {}
    self.messageMap = {}

    self.package = package
end

return PBRoot
