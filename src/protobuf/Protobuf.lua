---@type PBField
local PBField = require "PBField"
---@type PBMessage
local PBMessage = require "PBMessage"
---@type PBEnum
local PBEnum = require "PBEnum"
---@type PBRoot
local PBRoot = require "PBRoot"
---@type PBReader
local PBReader = require "PBReader"
---@type PBWriter
local PBWriter = require "PBWriter"
---@type PBParser
local PBParser = require "PBParser"

---Protobu 编码解码
---@class Protobuf:ObjectEx by wx771720@outlook.com 2019-12-31 10:46:50
local Protobuf = xx.Class("Protobuf")

---@see Protobuf
xx.Protobuf = Protobuf

---构造函数
function Protobuf:ctor()
end
-- -----------------------------------------------------------------------------
-- 类型
-- -----------------------------------------------------------------------------
Protobuf.pb_int32 = "int32"
Protobuf.pb_uint32 = "uint32"
Protobuf.pb_sint32 = "sint32"
Protobuf.pb_int64 = "int64"
Protobuf.pb_uint64 = "uint64"
Protobuf.pb_sint64 = "sint64"
Protobuf.pb_bool = "bool"
Protobuf.pb_fixed64 = "fixed64"
Protobuf.pb_sfixed64 = "sfixed64"
Protobuf.pb_double = "double"
Protobuf.pb_string = "string"
Protobuf.pb_bytes = "bytes"
Protobuf.pb_fixed32 = "fixed32"
Protobuf.pb_sfixed32 = "sfixed32"
Protobuf.pb_float = "float"

---类型默认值
Protobuf.default = 0
---类型对应默认值
---@type table<string,any>
Protobuf.typeDefaultMap = {bool = false, string = "", bytes = ""}
---类型对应 wire 值
---@type table<string, number>
Protobuf.typeWireMap = {}
---wire 对应类型列表
---@type table<number,string[]>
Protobuf.wireTypesMap = {
    [0] = {
        Protobuf.pb_int32,
        Protobuf.pb_uint32,
        Protobuf.pb_sint32,
        Protobuf.pb_int64,
        Protobuf.pb_uint64,
        Protobuf.pb_sint64,
        Protobuf.pb_bool
    },
    [1] = {Protobuf.pb_fixed64, Protobuf.pb_sfixed64, Protobuf.pb_double},
    [2] = {Protobuf.pb_string, Protobuf.pb_bytes},
    [5] = {Protobuf.pb_fixed32, Protobuf.pb_sfixed32, Protobuf.pb_float}
}
---初始化 typeWireMap 表
for wire, types in pairs(Protobuf.wireTypesMap) do
    for _, type in ipairs(types) do
        Protobuf.typeWireMap[type] = wire
    end
end
---数组可使用 packed 编码的类型
---@type table<string, boolean>
Protobuf.typePackedMap = {
    [Protobuf.pb_int32] = true,
    [Protobuf.pb_uint32] = true,
    [Protobuf.pb_sint32] = true,
    [Protobuf.pb_int64] = true,
    [Protobuf.pb_uint64] = true,
    [Protobuf.pb_sint64] = true,
    [Protobuf.pb_bool] = true,
    [Protobuf.pb_fixed64] = true,
    [Protobuf.pb_sfixed64] = true,
    [Protobuf.pb_double] = true,
    [Protobuf.pb_fixed32] = true,
    [Protobuf.pb_sfixed32] = true,
    [Protobuf.pb_float] = true
}
-- -----------------------------------------------------------------------------
-- 解析
-- -----------------------------------------------------------------------------
---默认包名
---@type string
Protobuf.defaultPackageName = "xx_default_package"
---包名对应根
---@type table<string,PBRoot>
Protobuf.packageRootMap = {[Protobuf.defaultPackageName] = PBRoot()}

---解析 proto 配置文件
---@type fun(source:string)
---@param source string proto 配置文件内容
function Protobuf.parse(source)
    ---@type PBRoot
    local root = Protobuf.packageRootMap[Protobuf.defaultPackageName]
    ---@type table<string,PBMessage[]>
    local packageMessagesMap = {[Protobuf.defaultPackageName] = {}}
    -- 解析
    local parser = PBParser(source)
    while parser.index <= parser.numLines do
        local line = parser:readLine()
        if parser:isMessageLine(line) then -- 消息
            local message = PBMessage(root, parser:getMessageName(line))
            if not parser:isClosureLine(line) then
                Protobuf._parseMessage(parser, message)
            end
            root.messageMap[message.name] = message
            table.insert(packageMessagesMap[root.package or Protobuf.defaultPackageName], message)
        elseif parser:isEnumLine(line) then -- 枚举
            local enum = PBEnum(root, parser:getEnumName(line))
            if not parser:isClosureLine(line) then
                Protobuf._parseEnum(parser, enum)
            end
            root.enumMap[enum.name] = enum
        elseif parser:isPackageLine(line) then -- 包名
            local packageName = parser:getPackageName(line)
            if Protobuf.packageRootMap[packageName] then
                root = Protobuf.packageRootMap[packageName]
            else
                root = PBRoot(packageName)
                Protobuf.packageRootMap[packageName] = root
            end

            if not packageMessagesMap[packageName] then
                packageMessagesMap[packageName] = {}
            end
        end
    end
    -- 字段消息、枚举赋值
    for package, messages in pairs(packageMessagesMap) do
        if package == Protobuf.defaultPackageName then
            package = nil
        end
        for _, message in ipairs(messages) do
            for _, field in pairs(message.fieldIDMap) do
                if not Protobuf.typeWireMap[field.type] then
                    field.message = Protobuf.getMessage(field.package or package, field.type)
                    if not field.message then
                        field.enum = Protobuf.getEnum(field.package or package, field.type)
                    end
                end
                if field.map and not Protobuf.typeWireMap[field.keyType] then
                    field.keyMessage = Protobuf.getMessage(field.keyPackage or package, field.keyType)
                    if not field.keyMessage then
                        field.keyEnum = Protobuf.getEnum(field.keyPackage or package, field.keyType)
                    end
                end
            end
        end
    end
end
---解析消息信息
---@type fun(parser:PBParser,message:PBMessage)
---@param parser PBParser Protobuf 解析器
---@param message PBMessage 消息信息
function Protobuf._parseMessage(parser, message)
    ---@type string
    local line
    ---@type PBField
    local field
    repeat
        line = parser:readLine()
        field = parser:getMessageField(line)
        if field then
            field.parent = message
            table.insert(message.fieldIDs, field.id)
            message.fieldIDMap[field.id] = field
        end
        -- 结束
        if parser:isClosureLine(line) then
            return
        end
    until false
end
---解析枚举信息
---@type fun(parser:PBParser,enum:PBEnum)
---@param parser PBParser Protobuf 解析器
---@param enum PBEnum 枚举信息
function Protobuf._parseEnum(parser, enum)
    local line, name, id
    repeat
        line = parser:readLine()
        name, id = parser:getEnumItem(line)
        if name and id then
            enum.idNameMap[id] = name
            enum.nameIDMap[name] = id
        end
        -- 结束
        if parser:isClosureLine(line) then
            return
        end
    until false
end

---获取指定消息信息
---@type fun(packageName:string,messageName:string,value:any):PBMessage
---@param packageName string 包名
---@param messageName string 消息名
---@return PBMessage
function Protobuf.getMessage(packageName, messageName)
    if packageName then
        if Protobuf.packageRootMap[packageName] then
            return Protobuf.packageRootMap[packageName].messageMap[messageName]
        end
    else
        for packageName, root in pairs(Protobuf.packageRootMap) do
            if root.messageMap[messageName] then
                return root.messageMap[messageName]
            end
        end
    end
end
---获取指定枚举信息
---@type fun(packageName:string,enumName:string,value:any):PBEnum
---@param packageName string 包名
---@param enumName string 枚举名
---@return PBEnum
function Protobuf.getEnum(packageName, enumName)
    if packageName then
        if Protobuf.packageRootMap[packageName] then
            return Protobuf.packageRootMap[packageName].enumMap[enumName]
        end
    else
        for packageName, root in pairs(Protobuf.packageRootMap) do
            if root.enumMap[enumName] then
                return root.enumMap[enumName]
            end
        end
    end
end
-- -----------------------------------------------------------------------------
-- 编码
-- -----------------------------------------------------------------------------
---解码
---@type fun(packageName:string,messageName:string,buffer:string):any
---@param packageName string 包名
---@param messageName string 消息名
---@param buffer string 编码后的数据
---@return any 解码后的数据
function Protobuf.decode(packageName, messageName, buffer)
    ---@type PBReader
    local reader = PBReader(buffer)
    local message = Protobuf.getMessage(packageName, messageName)
    if message then
        return Protobuf._decode(message, reader, reader.length)
    end
end
---解码数据
---@type fun(message:PBMessage,reader:PBReader,length:number):any
---@param message PBMessage 消息信息
---@param reader PBReader 读
---@param length number 读取的长度
---@return any 解码后的数据
function Protobuf._decode(message, reader, length)
    local value = {}
    ---@type number
    local id
    ---@type number
    local to = reader.position + length
    repeat
        id = Protobuf._decodeTag(reader:uint32()) -- 读 tag
        local field = message.fieldIDMap[id]
        if field.map then -- 表
            if not value[field.name] then
                value[field.name] = {}
            end
            local fieldTo = reader:uint32() + reader.position -- 表结束位置
            local mapID, k, v
            repeat
                mapID = Protobuf._decodeTag(reader:uint32())
                if 1 == mapID then
                    k = Protobuf._readFrom(reader, field.keyType, field.keyMessage, field.enum)
                elseif 2 == mapID then
                    v = Protobuf._readFrom(reader, field.type, field.message, field.enum)
                end
                if k and v then
                    value[field.name][k] = v
                    k, v = nil, nil
                end
            until reader.position >= fieldTo
        elseif field.repeated then --数组
            if not value[field.name] then
                value[field.name] = {}
            end
            local length = #value[field.name]
            if field.packed and (Protobuf.typePackedMap[field.type] or field.enum) then -- packed 格式
                local fieldTo = reader:uint32() + reader.position -- 数组结束位置
                repeat
                    length = length + 1
                    value[field.name][length] = Protobuf._readFrom(reader, field.type, field.message, field.enum)
                until reader.position >= fieldTo
            else
                length = length + 1
                value[field.name][length] = Protobuf._readFrom(reader, field.type, field.message, field.enum)
            end
        else
            value[field.name] = Protobuf._readFrom(reader, field.type, field.message, field.enum)
        end
    until reader.position >= to
    return value
end
---从 PBReader 中读取数据
---@type fun(reader:PBReader,type:string,message:PBMessage,enum:PBEnum):any
---@param reader PBReader Protobuf 读
---@param type string 字段类型
---@param message PBMessage 消息信息
---@param enum PBEnum 枚举信息
---@return any 解码后的数据
function Protobuf._readFrom(reader, type, message, enum)
    if Protobuf.typeWireMap[type] then -- 基础类型
        return reader[type](reader)
    elseif message then -- 自定义类型
        return Protobuf._decode(message, reader, reader:uint32())
    elseif enum then -- 枚举
        return reader:int32()
    else -- 错误的类型
        error("protobuf decode can not find the type : " .. type)
    end
end
---解码 tag
---@type fun(tag:number):number,number
---@param tag number tag
---@return number,id id,wireType
function Protobuf._decodeTag(tag)
    return xx.Bit.uint(xx.Bit.shift(tag, 3)), xx.Bit.uint(xx.Bit.band(tag, 3))
end
-- -----------------------------------------------------------------------------
-- 编码
-- -----------------------------------------------------------------------------
---编码
---@type fun(packageName:string,messageName:string,value:any):string
---@param packageName string 包名
---@param messageName string 消息名
---@param value any 数据
---@return string 编码后的数据
function Protobuf.encode(packageName, messageName, value)
    ---@type PBWriter
    local writer = PBWriter.instance()
    local message = Protobuf.getMessage(packageName, messageName)
    if message then
        Protobuf._encode(message, value, writer)
    end

    for i = writer.length + 1, #writer.buffer do
        writer.buffer[i] = nil
    end
    local result = string.char(unpack(writer.buffer))
    writer:destory()
    return result
end
---编码消息
---@type fun(message:PBMessage,value:any,writer:PBWriter)
---@param message PBMessage 消息信息
---@param value any 数据
---@param writer PBWriter Protobuf 写
function Protobuf._encode(message, value, writer)
    for fieldID, field in pairs(message.fieldIDMap) do
        if nil ~= value[field.name] then
            if field.map then -- 表
                for k, v in pairs(value[field.name]) do
                    if nil ~= v then
                        ---@type PBWriter
                        local fieldWriter = PBWriter.instance()
                        Protobuf._writeTo(fieldWriter, 1, field.keyType, field.keyMessage, field.keyEnum, k) -- 写入键
                        Protobuf._writeTo(fieldWriter, 2, field.type, field.message, field.enum, v) -- 写入值
                        writer:uint32(Protobuf._encodeTag(field.id, 2)) -- 写入 tag
                        writer:uint32(fieldWriter.length) -- 写入长度
                        writer:write(fieldWriter) -- 写入值
                        fieldWriter:destory()
                    end
                end
            elseif field.repeated then -- 数组
                if #value[field.name] > 0 then
                    if field.packed and (Protobuf.typePackedMap[field.type] or field.enum) then -- packed 格式
                        ---@type PBWriter
                        local fieldWriter = PBWriter.instance()
                        for _, v in ipairs(value[field.name]) do
                            if field.enum then
                                fieldWriter:int32(v) -- 写入值
                            else
                                fieldWriter[field.type](fieldWriter, v) -- 写入值
                            end
                        end
                        writer:uint32(Protobuf._encodeTag(field.id, 2)) -- 写入 tag
                        writer:uint32(fieldWriter.length) -- 写入长度
                        writer:write(fieldWriter) -- 写入值
                        fieldWriter:destory()
                    else
                        for _, v in ipairs(value[field.name]) do
                            Protobuf._writeTo(writer, field.id, field.type, field.message, field.enum, v)
                        end
                    end
                end
            else
                Protobuf._writeTo(writer, field.id, field.type, field.message, field.enum, value[field.name])
            end
        end
    end
end
---将 value 写入 PBWriter
---@type fun(writer:PBWriter,id:number,type:string,message:PBMessage,enum:PBEnum,value:any)
---@param writer PBWriter
---@param id number 字段 id
---@param type string 字段类型
---@param message PBMessage 消息信息
---@param enum PBEnum 枚举信息
---@param value any 值
function Protobuf._writeTo(writer, id, type, message, enum, value)
    if Protobuf.typeWireMap[type] then -- 基础类型
        writer:uint32(Protobuf._encodeTag(id, Protobuf.typeWireMap[type])) -- 写入 tag
        writer[type](writer, value) -- 写入值
    elseif message then -- 自定义类型
        ---@type PBWriter
        local fieldWriter = PBWriter.instance()
        Protobuf._encode(message, value, fieldWriter)
        writer:uint32(Protobuf._encodeTag(id, 2)) -- 写入 tag
        writer:uint32(fieldWriter.length) -- 写入长度
        writer:write(fieldWriter) -- 定入值
        fieldWriter:destory()
    elseif enum then -- 枚举
        writer:uint32(Protobuf._encodeTag(id, 0)) -- 写入 tag
        writer:int32(value) -- 写入值
    else -- 错误的类型
        error("protobuf encode can not find the type : " .. type)
    end
end
---编码 tag
---@type fun(id:number,wireType:number):number
---@param id number 字段 id
---@param wireType number 编码类型
---@return number tag
function Protobuf._encodeTag(id, wireType)
    return xx.Bit.uint(xx.Bit.bor(xx.Bit.shift(id, -3), wireType))
end

return Protobuf
