---xx 命名空间
---@class xx
---@field CSEvent CSEvent
---@field Util Util
xx = xx or {}

---版本号
---@type string
xx.version = "1.0.0"
---打印版本号
print("xx(lua) version: " .. xx.version)

---id 种子
---@type number
local __uidSeed = 0
---获取一个新的 id
---@type fun():string
---@return string 返回新的 id
function xx.newUID()
    __uidSeed = __uidSeed + 1
    return string.format("xx_lua_%d", __uidSeed)
end
