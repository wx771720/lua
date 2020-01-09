---run cmd:
---cd bin-release
---lua test_class.lua
require "bin.class"

---类
---@class User:ObjectEx by wx771720@outlook.com 2020-01-09 15:54:44
---@field name string 名字
---@field gender number 性别，0 未知，1 男性，-1 女性
---@field age number 年龄
local User = xx.Class("User")
---构造函数
function User:ctor(name, gender, age)
    self.name = name
    self.gender = gender
    self.age = age
end

function User:toString()
    local gender = 1 == self.gender and "boy" or (-1 == self.gender and "girl" or "unkown")
    return string.format("user[%s] : name = %s, gender = %s, age = %d", self.uid, self.name, gender, self.age)
end

---XiaoMing
---@type User
local XiaoMing = User("XiaoMing", 1, 22)
---HanMeiMei
---@type User
local HanMeiMei = User("HanMeiMei", -1, 18)

print(XiaoMing)
-- user[xx_lua_1] : name = XiaoMing, gender = boy, age = 22
print(HanMeiMei)
-- user[xx_lua_2] : name = HanMeiMei, gender = girl, age = 18

