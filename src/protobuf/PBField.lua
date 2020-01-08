---Protobuf 字段信息
---@class PBField:ObjectEx by wx771720@outlook.com 2019-12-31 10:51:14
---@field parent PBMessage 所属的消息信息
---@field name string 字段名
---@field id number 字段 id
---@field package string 值的类型所在包名
---@field type string 值的类型
---@field message PBMessage 值消息信息
---@field enum PBEnum 值枚举信息
---
---@field optional boolean 是否是可选的
---@field required boolean 是否是必须的
---@field repeated boolean 是否是数组
---@field packed boolean 是否使用 Length-delimited 格式编码数组
---@field map boolean 是否是表
---
---@field keyPackage string 键的类型所在包名
---@field keyType string 键的类型
---@field keyMessage PBMessage 键消息信息
---@field keyEnum PBEnum 键枚举信息
local PBField = xx.Class("PBField")
---构造函数
function PBField:ctor(name, package, type, id)
    self.optional, self.required, self.repeated, self.packed, self.map = true, false, false, true, false
    self.name, self.package, self.type, self.id, self.wireType = name, package, type, id
end

return PBField
