---@type PBField
local PBField = require "PBField"

---Protobuf 解析器
---@class PBParser:ObjectEx by wx771720@outlook.com 2020-01-01 17:22:48
---@field lines string[] 行列表
---@field index number 当前读取行数
---@field numLines number 行数
local PBParser = xx.Class("PBParser")
---构造函数
function PBParser:ctor(content)
    self.index = 1
    self.lines = {}
    self.numLines = 0
    for line in string.gmatch(content, "[^\r\n]+") do
        if #string.gsub(line, "%s+", "") > 0 then
            self.numLines = self.numLines + 1
            -- print(self.numLines, line, self:isClosureLine(line))
            self.lines[self.numLines] = line
        end
    end
end

-- -----------------------------------------------------------------------------
-- 其它
-- -----------------------------------------------------------------------------
---读取行
---@type fun():string
---@return string
function PBParser:readLine()
    self.index = self.index + 1
    return self.lines[self.index - 1]
end
---判断是否是结束行
---@type fun(line:string):boolean
---@param line string 行
---@return boolean
function PBParser:isClosureLine(line)
    return nil ~= string.match(line, "}")
end
-- -----------------------------------------------------------------------------
-- 包名
-- -----------------------------------------------------------------------------
---判断是否是包名行
---@type fun(line:string):boolean
---@param line string 行
---@return boolean
function PBParser:isPackageLine(line)
    return nil ~= string.match(line, "^package ")
end
---获取包名
---@type fun(line:string):string
---@param line string 行
---@return string 返回包名
function PBParser:getPackageName(line)
    return string.gsub(string.match(line, "[^;]+", #"package " + 1), "%s+", "")
end
-- -----------------------------------------------------------------------------
-- 消息
-- -----------------------------------------------------------------------------
---判断是否是消息行
---@type fun(line:string):boolean
---@param line string 行
---@return boolean
function PBParser:isMessageLine(line)
    return nil ~= string.match(line, "^message ")
end
---获取消息名
---@type fun(line:string):string
---@param line string 行
---@return string 返回消息名
function PBParser:getMessageName(line)
    return string.gsub(string.match(line, "[^%s{]+", #"message " + 1), "%s+", "")
end
---获取消息字段
---@type fun(line:string):PBField
---@param line string 行
---@return PBField 字段信息
function PBParser:getMessageField(line)
    local before = string.match(line, "[^=]+")
    if not before then
        return
    end
    local after = string.match(line, "=[^;]+")
    if not after then
        return
    end

    -- 去掉末尾空格
    before = string.gsub(before, "%s+$", "")
    -- name
    local name = string.match(before, "[^%s]+$")
    -- 去掉 name
    before = string.gsub(before, "%s*" .. name .. "%s*$", "")
    -- repeated
    local repeated = nil ~= string.match(before, "repeated")
    if repeated then
        before = string.gsub(before, "%s*repeated%s*", "")
    end
    -- required
    local required = nil ~= string.match(before, "required")
    if required then
        before = string.gsub(before, "%s*required%s*", "")
    end
    -- optional
    local optional = nil ~= string.match(before, "optional") or not required
    if optional then
        before = string.gsub(before, "%s*optional%s*", "")
    end
    -- type
    local package, type, keyPackage, keyType
    local map = string.match(before, "map%s*<%s*[^%s]+%s*,%s*[^%s]+%s*>")
    if map then -- map
        map = string.gsub(string.gsub(map, "map%s*<", ""), "[%s>]", "")
        keyType = string.match(map, "[^,]+")
        type = string.match(map, "[^,]+$")
        map = true

        keyPackage = string.match(keyType, "[^\\.]+$")
        if keyPackage == keyType then
            keyPackage = nil
        else
            keyType, keyPackage = keyPackage, string.gsub(keyType, "." .. keyPackage .. "$", "")
        end
    else -- 基础类型，消息，枚举
        type = string.match(before, "[^%s]+$")
        if not type then
            return
        end
        map = false
    end

    package = string.match(type, "[^\\.]+$")
    if package == type then
        package = nil
    else
        type, package = package, string.gsub(type, "." .. package .. "$", "")
    end

    -- id
    local id = string.match(after, "%d+")
    if not id then
        return
    end
    id = tonumber(id)
    -- packed
    local packed = nil == string.match(line, "packed%s*=%s*false")

    -- print("field : ", name, repeated, required, optional, map, package, type, keyPackage, keyType, id, packed)

    local field = PBField(name, package, type, id)
    field.optional = optional
    field.required = required
    field.repeated = repeated
    field.packed = packed
    field.map = map
    if map then
        field.keyPackage = keyPackage
        field.keyType = keyType
    end
    return field
end
-- -----------------------------------------------------------------------------
-- 枚举
-- -----------------------------------------------------------------------------
---判断是否是枚举行
---@type fun(line:string):boolean
---@param line string 行
---@return boolean
function PBParser:isEnumLine(line)
    return nil ~= string.match(line, "^enum ")
end
---获取枚举名
---@type fun(line:string):string
---@param line string 行
---@return string 返回枚举名
function PBParser:getEnumName(line)
    return string.gsub(string.match(line, "[^%s{]+", #"enum " + 1), "%s+", "")
end
---获取枚举项
---@type fun(line:string):string,id
---@param line string 行
---@return string,id 名字, id
function PBParser:getEnumItem(line)
    local name = string.match(line, "[^=]+")
    if not name then
        return
    end
    local id = string.match(line, "=[^;]+")
    if not id then
        return
    end
    name = string.gsub(name, "%s+", "")
    id = string.gsub(id, "[=%s]+", "")
    return name, tonumber(id)
end

return PBParser
