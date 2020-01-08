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
---@alias Handler fun(...:any[]):any
---用于封装的 self Handler 回调
---@type fun(handler:Handler,caller:any|nil,...:any):Handler
---@param handler Handler 需要封装的回调函数
---@param caller any|nil 需要封装的监听函数所属对象
---@vararg any
---@return Handler 封装的回调函数
function xx.Handler(handler, caller, ...)
    local cache = {...}
    if 0 == xx.arrayCount(cache) then
        cache = nil
    end
    return function(...)
        if caller then
            if cache then
                return handler(caller, unpack(cache), ...)
            else
                return handler(caller, ...)
            end
        else
            if cache then
                return handler(unpack(cache), ...)
            else
                return handler(...)
            end
        end
    end
end
---解构数组
---@type fun(data:table):...
unpack = unpack or table.unpack
---是否是 nil
---@type fun(target:any):boolean
---@param target any 数据对象
---@return boolean
function xx.isNil(target)
    return nil == target
end
---是否是 boolean
---@type fun(target:any):boolean
---@param target any 数据对象
---@return boolean
function xx.isBoolean(target)
    return "boolean" == type(target)
end
---是否是 number
---@type fun(target:any):boolean
---@param target any 数据对象
---@return boolean
function xx.isNumber(target)
    return "number" == type(target)
end
---是否是 string
---@type fun(target:any):boolean
---@param target any 数据对象
---@return boolean
function xx.isString(target)
    return "string" == type(target)
end
---是否是 function
---@type fun(target:any):boolean
---@param target any 数据对象
---@return boolean
function xx.isFunction(target)
    return "function" == type(target)
end
---是否是 table
---@type fun(target:any):boolean
---@param target any 数据对象
---@return boolean
function xx.isTable(target)
    return "table" == type(target)
end
---是否是 userdata
---@type fun(target:any):boolean
---@param target any 数据对象
---@return boolean
function xx.isUserdata(target)
    return "userdata" == type(target)
end
---是否是 thread
---@type fun(target:any):boolean
---@param target any 数据对象
---@return boolean
function xx.isThread(target)
    return "thread" == type(target)
end
---清空表
---@type fun(map:table):table
---@param map table 表
---@return table map
function xx.tableClear(map)
    for key, _ in pairs(map) do
        map[key] = nil
    end
    return map
end
---拷贝表
---@type fun(map:table, recursive:boolean):table
---@param map table 表
---@param recursive boolean|nil true 表示需要深度拷贝，默认 false
---@return table 拷贝的表对象
function xx.tableClone(map, recursive)
    local copy = {}
    for key, value in pairs(map) do
        if "table" == type(value) and recursive then
            copy[key] = xx.tableClone(value, recursive)
        else
            copy[key] = value
        end
    end
    return copy
end
---合并表
---@type fun(map:table, ...:table):table
---@param map table 表
---@vararg table
---@return table map
function xx.tableMerge(map, ...)
    local mapList = {...}
    for i = 1, xx.arrayCount(mapList) do
        if xx.isTable(mapList[i]) then
            for k, v in pairs(mapList[i]) do
                map[k] = v
            end
        end
    end
    return map
end
---计算指定表键值对数量
---@type fun(map:table):number
---@param map table 表
---@return number 返回表数量
function xx.tableCount(map)
    local count = 0
    for _, __ in pairs(map) do
        count = count + 1
    end
    return count
end
---获取指定表的所有键
---@type fun(map:table):any[]
---@param map table 表
---@return any[] 键列表
function xx.tableKeys(map)
    local keys = {}
    for key, _ in pairs(map) do
        xx.arrayPush(keys, key)
    end
    return keys
end
---获取指定表的所有值
---@type fun(map:table):any[]
---@param map table 表
---@return any[] 值列表
function xx.tableValues(map)
    local values = {}
    for _, value in pairs(map) do
        xx.arrayPush(values, value)
    end
    return values
end
---获取数组最大索引
---@type fun(array:any[]):number
---@param array any[] 数组
---@return number 数组的最大索引
function xx.arrayCount(array)
    local index = 0
    for key, _ in pairs(array) do
        if xx.isNumber(key) and key > index then
            index = key
        end
    end
    return index
end
---清空数组
---@type fun(array:any[]):any[]
---@param array any[] 数组
---@return any[] array
function xx.arrayClear(array)
    for i = xx.arrayCount(array), 1, -1 do
        array[i] = nil
    end
    return array
end
---将指定数据插入数组中指定位置
---@type fun(array:any[],item:any,index:number|nil):any[]
---@param array any[] 数组
---@param item any 数据
---@param index number|nil 索引，默认 nil 表示插入数组末尾
---@return any[] array
function xx.arrayInsert(array, item, index)
    local count = xx.arrayCount(array)
    index = (not index or index > count) and count + 1 or (index < 1 and 1 or index)
    if index <= count then
        for i = count, index, -1 do
            array[i + 1] = array[i]
        end
    end
    array[index] = item
    return array
end
---将有大小区别的数据按升序插入有序数组
---@type fun(array:any[],value:any):any[]
---@param array any[] 数组
---@param value any 数据
---@return any[] array
function xx.arrayInsertASC(array, value)
    local index = 1
    for i = xx.arrayCount(array), 1, -1 do
        if array[i] <= value then
            index = i + 1
            break
        end
        array[i + 1] = array[i]
    end
    array[index] = value
    return array
end
---从数组中移除指定数据
---@type fun(array:any[], item:any):any[]
---@param array any[] 数组对象
---@param item any 需要移除的数据
---@return any[] array
function xx.arrayRemove(array, item)
    local iNew = 1
    for iOld = 1, xx.arrayCount(array) do
        if array[iOld] ~= item then
            if iNew ~= iOld then
                array[iNew] = array[iOld]
                array[iOld] = nil
            end
            iNew = iNew + 1
        else
            array[iOld] = nil
        end
    end
    return array
end
---删除数组中指定位置的数据并返回
---@type fun(array:any[],index:number):any|nil
---@param array any[] 数组
---@param index number 索引
---@return any|nil 删除的数据
function xx.arrayRemoveAt(array, index)
    local count = xx.arrayCount(array)
    if index and index >= 1 and index <= count then
        local item = array[index]
        if index < count then
            for i = index + 1, count do
                array[i - 1] = array[i]
            end
        end
        array[count] = nil
        return item
    end
end
---将多个数据插入数组末尾
---@type fun(array:any[],...:any):any[]
---@param array any[] 数组
---@vararg any
---@return any[] array
function xx.arrayPush(array, ...)
    local args = {...}
    local count = xx.arrayCount(array)
    for i = 1, xx.arrayCount(args) do
        array[count + i] = args[i]
    end
    return array
end
---删除数组最后一个数据并返回
---@type fun(array:any[]):any|nil
---@param array any[] 数组
---@return any|nil 返回删除的数据，如果失败则返回 nil
function xx.arrayPop(array)
    return xx.arrayRemoveAt(array, xx.arrayCount(array))
end
---将数据插入到最前面
---@type fun(array:any[],item:any):any[]
---@param array any[] 数组
---@param item any 数据
---@return any[] array
function xx.arrayUnshift(array, item)
    return xx.arrayInsert(array, item, 1)
end
---删除数组第一个数据并返回
---@type fun(array:any[]):any|nil
---@param array any[] 数组
---@return any|nil 返回删除的数据，如果失败则返回 nil
function xx.arrayShift(array)
    return xx.arrayRemoveAt(array, 1)
end
---查找数组中指定数据的索引
---@type fun(array:any[], item:any, from:number):number
---@param array any[] 数组对象
---@param item any 需要查找的数据
---@param from number|nil 从该索引开始查找（-1 表示最后一个元素），默认 1
---@return number 如果找到则返回对应索引（从 1 开始），否则返回 -1
function xx.arrayIndexOf(array, item, from)
    local count = xx.arrayCount(array)
    from = from and (from < 0 and count + from + 1 or from) or 1
    for index = from < 1 and 1 or from, count do
        if array[index] == item then
            return index
        end
    end
    return -1
end
---查找数组中指定数据的索引
---@type fun(array:any[], item:any, from:number):number
---@param array any[] 数组对象
---@param item any 需要查找的数据
---@param from number|nil 从该索引开始查找（-1 表示最后一个元素），默认 -1
---@return number 如果找到则返回对应索引（从 1 开始），否则返回 -1
function xx.arrayLastIndexOf(array, item, from)
    local count = xx.arrayCount(array)
    from = from and (from < 0 and count + from + 1 or from) or count
    for i = from > count and count or from, 1, -1 do
        if array[i] == item then
            return i
        end
    end
    return -1
end
---判断指定数组中是否存在指定数据
---@type fun(array:any[],item:any):boolean
---@param array any[] 数组
---@param item any 数据
---@return boolean 如果存在则返回 true，否则返回 false
function xx.arrayContains(array, item)
    for i = 1, xx.arrayCount(array) do
        if item == array[i] then
            return true
        end
    end
    return false
end
---从数组中构建指定范围的一个新数组
---@type fun(array:any[],start:number|nil,stop:number|nil):any[]
---@param array any[] 数组
---@param start number|nil 起始索引（-1 表示最后一个元素），默认 1
---@param stop number|nil 结束索引（-1 表示最后一个元素，新构建的数组包含该索引数据），默认 -1
---@return anyp[] 新数组
function xx.arraySlice(array, start, stop)
    local count = xx.arrayCount(array)
    start = start and (start < 0 and count + start + 1 or start) or 1
    stop = stop and (stop < 0 and count + stop + 1 or stop) or count
    local j = 1
    local result = {}
    for i = start < 1 and 1 or start, stop > count and count or stop do
        result[j] = array[i]
        j = j + 1
    end
    return result
end
---合并数组
---@type fun(array:any[], ...:any[]):any[]
---@param array 数组
---@vararg any[]
---@return any[] array
function xx.arrayMerge(array, ...)
    local index = xx.arrayCount(array) + 1
    local arrayList = {...}
    for i = 1, xx.arrayCount(arrayList) do
        if xx.isTable(arrayList[i]) then
            for j = 1, xx.arrayCount(arrayList[i]) do
                array[index] = arrayList[i][j]
                index = index + 1
            end
        end
    end
    return array
end
---判断当前协程是否可 yield
---@type fun():boolean
---@return boolean
coroutine.isyieldable = function()
    local _, isMain = coroutine.running()
    return not isMain
end
---自定义类
---@class SubClass
---@field __className 类名
---@field __superClass 基类
---@field __metatable 元数据
---类定义
---@class Class by wx771720@outlook.com 2019-08-07 15:04:24
---@param name string 类名
---@param super SubClass|nil 基类，如果不指定默认为 ObjectEx
---@return SubClass 返回类
local Class = {__nameClassMap = {}}
---@see Class
xx.Class = Class
---getter 取值
---@type fun(instance:ObjectEx, key:string):any
---@param instance ObjectEx 对象
---@param key string 属性键
---@return any
function Class.getter(instance, key)
    if not xx.isNil(instance.__proxy[key]) then
        return instance.__proxy[key]
    end
    if not xx.isNil(instance.__class) and not xx.isNil(instance.__class[key]) then
        return instance.__class[key]
    end
end
---setter 设置值
---@type fun(instance:ObjectEx, key:string, value:any)
---@param instance ObjectEx 对象
---@param key string 属性键
---@param value any 属性值
function Class.setter(instance, key, value)
    instance.__proxy[key] = value
end
---判断指定表是否是类
---@type fun(class:SubClass):boolean
---@param class SubClass 表
---@return boolean 如果是类则返回 true，否则返回 false
function Class.isClass(class)
    return xx.isTable(class) and xx.isString(class.__className) and xx.isTable(class.__metatable)
end
---指定表是否是实例
---@type fun(instance:ObjectEx):boolean
---@param instance ObjectEx 表
---@return boolean 如果是实例则返回 true，否则返回 false
function Class.isInstance(instance)
    return xx.isTable(instance) and Class.isClass(instance.__class)
end
---获取指定类名的类
---@type fun(name:string):SubClass
---@param name string 类名
---@return SubClass|nil 如果找到则返回类，否则返回 nil
function Class.getClass(name)
    return Class.__nameClassMap[name]
end
---判断对象是否是指定类的实例
---@type fun(instance:ObjectEx, class:SubClass):boolean
---@param instance ObjectEx 实例对象
---@param class SubClass 类
---@return boolean 如果 instance 对象是 class 的实例则返回 true，否则返回 false
function Class.instanceOf(instance, class)
    if Class.isInstance(instance) then
        local loopClass = instance.__class
        while loopClass do
            if loopClass == class then
                return true
            end
            loopClass = loopClass.__superClass
        end
    end
    return false
end
---@see Class#instanceOf
xx.instanceOf = Class.instanceOf
---[ctor]: 构造函数（从上往下），参数：...
---[ctored]: 构造函数（从下往上），参数：...
---[getter]: 获取属性值，参数：key, return 透传
---[setter]: 设置属性值，参数：key, value
---[call]: 对象执行函数，参数：...，return 透传
---[add]: 相加函数，参数：target，return 透传
---[sub]: 想减函数，参数：target，return 透传
---[equalTo]: 比较函数，参数：target，return boolean
---[lessThan]: 小于函数，参数：target，return boolean
---[lessEqual]: 小于等于函数，参数：target，return boolean
---[toString]: 转换为字符串，return string
local __instanceMetatable = {
    __index = function(instance, key)
        local getter = Class.getter(instance, "getter")
        if xx.isFunction(getter) then
            return getter(instance, key)
        end
        return Class.getter(instance, key)
    end,
    __newindex = function(instance, key, value)
        local setter = Class.getter(instance, "setter")
        if xx.isFunction(setter) then
            setter(instance, key, value)
        else
            Class.setter(instance, key, value)
        end
    end,
    __call = function(instance, ...)
        local callFunc = instance.call
        if xx.isFunction(callFunc) then
            return callFunc(instance, ...)
        end
    end,
    __add = function(instance, target)
        local addFunc = instance.add
        if xx.isFunction(addFunc) then
            return addFunc(instance, target)
        end
    end,
    __sub = function(instance, target)
        local subFunc = instance.sub
        if xx.isFunction(subFunc) then
            return subFunc(instance, target)
        end
    end,
    __eq = function(instance, target)
        local equalToFunc = instance.equalTo
        if xx.isFunction(equalToFunc) then
            return equalToFunc(instance, target)
        end
    end,
    __lt = function(instance, target)
        local lessThanFunc = instance.lessThan
        if xx.isFunction(lessThanFunc) then
            return lessThanFunc(instance, target)
        end
    end,
    __le = function(instance, target)
        local lessEqualFunc = instance.lessEqual
        if xx.isFunction(lessEqualFunc) then
            return lessEqualFunc(instance, target)
        end
    end,
    __tostring = function(instance)
        local toStringFunc = instance.toString
        if xx.isFunction(toStringFunc) then
            return toStringFunc(instance)
        end
    end
}
---新建类
---@type fun(name:string, super:SubClass):SubClass
---@param name string 类名，会覆盖已存在的同名类
---@param super SubClass|nil 基类
---@return SubClass 返回新建的类
function Class.newClass(name, super)
    local class =
        setmetatable(
        {__className = name, __superClass = super, __metatable = __instanceMetatable},
        {
            __index = super,
            __call = function(class, ...)
                local instance =
                    setmetatable({__class = class, __proxy = {}, __isConstructed = false}, class.__metatable)
                local ctorList = {}
                local ctoredList = {}
                local loopClass = class
                while loopClass do
                    local ctor = rawget(loopClass, "ctor")
                    if xx.isFunction(ctor) then
                        xx.arrayPush(ctorList, ctor)
                    end
                    local ctored = rawget(loopClass, "ctored")
                    if xx.isFunction(ctored) then
                        xx.arrayPush(ctoredList, ctored)
                    end
                    loopClass = loopClass.__superClass
                end
                for index = xx.arrayCount(ctorList), 1, -1 do
                    ctorList[index](instance, ...)
                end
                for index = 1, xx.arrayCount(ctoredList) do
                    ctoredList[index](instance, ...)
                end
                instance.__isConstructed = true
                return instance
            end
        }
    )
    Class.__nameClassMap[name] = class
    return class
end
---基类（所有通过 Class 定义的类都默认继承自该类）
---@class ObjectEx by wx771720@outlook.com 2019-08-07 14:33:35
---@field uid string 唯一标识
---@field __class SubClass 类型
---@field __proxy table 属性
---@field __isConstructed boolean 是否已构造完成
xx.ObjectEx = Class.newClass("ObjectEx")
---构造函数
function xx.ObjectEx:ctor()
    self.uid = xx.newUID()
end
---转换成字符串
---@return string
function xx.ObjectEx:toString()
    return self.uid
end
---setter
---@type fun(key:string|number, value:any)
---@param key string|number 属性键
---@param value any 属性值
function xx.ObjectEx:setter(key, value)
    local oldValue = self[key]
    if oldValue == value then
        return
    end
    Class.setter(self, key, value)
    if self.__isConstructed and xx.isFunction(self.onDynamicChanged) then
        self:onDynamicChanged(key, value, oldValue)
    end
end
setmetatable(
    Class,
    {
        __call = function(_, name, super)
            return Class.newClass(name, super or xx.ObjectEx)
        end
    }
)
---@class PromiseNext
---@field promise Promise 异步对象
---@field onFulfilled Handler 完成回调
---@field onRejected Handler 拒绝回调
local PromiseNext
---异步类
---@class Promise:ObjectEx by wx771720@outlook.com 2019-12-24 14:21:47
---
---@field value any[] 结果
---@field reason string 拒因
---
---@field _state string 当前状态
---@field _queue PromiseNext[] 结束后依赖的异步列表
local Promise = xx.Class("xx.Promise")
---@see Promise
xx.Promise = Promise
---异步状态：等待态
Promise.state_pending = "pending"
---异步状态：完成态
Promise.state_fulfilled = "fulfilled"
---异步状态：拒绝态
Promise.state_rejected = "rejected"
---异步对象列表
---@type Promise[]
Promise.queue = {}
---异步对象 - 回调函数
---@type table<Promise,Handler>
Promise.promiseAsyncMap = {}
---构造函数
function Promise:ctor(handler)
    self._state = Promise.state_pending
    self._queue = {}
    xx.arrayPush(Promise.queue, self)
    if handler then
        local result = {pcall(handler, xx.Handler(self.resolve, self), xx.Handler(self.reject, self))}
        if not result[1] then
            self:reject(result[2])
        end
    end
end
---异步是否是等待态
---@type fun():boolean
---@return boolean
function Promise:isPending()
    return Promise.state_pending == self._state
end
---异步是否是完成态
---@type fun():boolean
---@return boolean
function Promise:isFulfilled()
    return Promise.state_fulfilled == self._state
end
---异步是否是拒绝态
---@type fun():boolean
---@return boolean
function Promise:isRejected()
    return Promise.state_rejected == self._state
end
---完成
---@type fun(...:any)
---@vararg any
function Promise:resolve(...)
    if self:isPending() then
        self._state, self.value = Promise.state_fulfilled, xx.arrayPush({}, ...)
    end
end
---拒绝
---@type fun(reason:string)
---@param reason string 拒因
function Promise:reject(reason)
    if self:isPending() then
        self._state, self.reason = Promise.state_rejected, reason
    end
end
---拒绝并吃掉错误
function Promise:cancel()
    if self:isPending() then
        ---@type fun(promise:Promise)
        local catchNext
        catchNext = function(promise)
            if 0 == xx.arrayCount(promise._queue) then
                promise:catch()
            else
                for _, promiseNext in ipairs(promise._queue) do
                    catchNext(promiseNext.promise)
                end
            end
        end
        catchNext(self)
        self:reject("promise canceled")
    end
end
---异步结束后回调
---@type fun(onFulfilled:function,onRejected:function):Promise
---@param onFulfilled function 完成态回调
---@param onRejected function 拒绝态回调
---@return Promise 返回一个新的异步对象
function Promise:next(onFulfilled, onRejected)
    local promise = Promise()
    xx.arrayPush(self._queue, {promise = promise, onFulfilled = onFulfilled, onRejected = onRejected})
    return promise
end
---异步拒绝后回调
---@type fun(onRejected:function):Promise
---@param onRejected function|nil 拒绝态回调，nil 表示吃掉错误
---@return Promise 返回一个新的异步对象
function Promise:catch(onRejected)
    return self:next(
        nil,
        onRejected or function(reason)
            end
    )
end
---异步结束后回调
---@type fun(callback:function):Promise
---@param callback function 回调函数
---@return Promise 返回一个新的异步对象
function Promise:finally(callback)
    return self:next(
        function(...)
            callback()
            return ...
        end,
        function(reason)
            pcall(callback)
            error(reason)
        end
    )
end
---指定异步对象全部变成完成态，或者其中一个变成拒绝态时结束
---@type fun(...:Promise):Promise
---@vararg Promise
---@return Promise 返回一个新的异步对象
function Promise.all(...)
    local promises = xx.arrayPush({}, ...)
    return Promise(
        function(resolve, reject)
            local count = xx.arrayCount(promises)
            if count > 0 then
                local values = {}
                for i = 1, count do
                    promises[i]:next(
                        function(...)
                            values[i] = xx.arrayPush({}, ...)
                            count = count - 1
                            if 0 == count then
                                resolve(unpack(values))
                            end
                            return ...
                        end,
                        function(reason)
                            reject(reason)
                            error(reason)
                        end
                    )
                end
            else
                resolve()
            end
        end
    )
end
---指定异步对象其中一个变成完成态或者拒绝态时结束
---@type fun(...:Promise):Promise
---@vararg Promise
---@return Promise 返回一个新的异步对象
function Promise.race(...)
    local promises = xx.arrayPush({}, ...)
    return Promise(
        function(resolve, reject)
            for i = 1, xx.arrayCount(promises) do
                promises[i]:next(
                    function(...)
                        resolve(...)
                        return ...
                    end,
                    function(reason)
                        reject(reason)
                        error(reason)
                    end
                )
            end
        end
    )
end
---帧循环驱动异步
---@type fun()
function Promise.asyncLoop()
    for promise, handler in pairs(Promise.promiseAsyncMap) do
        Promise.promiseAsyncMap[promise] = nil
        local result = {
            coroutine.resume(
                coroutine.create(
                    function()
                        local result = {pcall(handler)}
                        if result[1] then -- 回调成功
                            if xx.instanceOf(result[2], Promise) then -- 返回异步
                                ---@type Promise
                                local promiseResult = result[2]
                                promiseResult:next(
                                    function(...) -- 异步完成
                                        promise:resolve(...)
                                        return ...
                                    end,
                                    function(reason) -- 异步拒绝
                                        promise:reject(reason)
                                        error(reason)
                                    end
                                )
                            else -- 返回值
                                xx.arrayRemoveAt(result, 1)
                                promise:resolve(unpack(result))
                            end
                        else -- 回调失败
                            promise:reject(result[2])
                        end
                    end
                )
            )
        }
        if not result[1] then
            promise:reject(result[2])
        end
    end
    for i = xx.arrayCount(Promise.queue), 1, -1 do
        local promise = Promise.queue[i]
        if promise:isFulfilled() or promise:isRejected() then
            xx.arrayRemoveAt(Promise.queue, i)
            for _, promiseNext in ipairs(promise._queue) do
                local result
                if promise:isFulfilled() then -- 完成回调
                    if promiseNext.onFulfilled then
                        result = {pcall(promiseNext.onFulfilled, unpack(promise.value))}
                    else
                        promiseNext.promise:resolve(unpack(promise.value))
                    end
                elseif promise:isRejected() then -- 拒绝回调
                    if promiseNext.onRejected then
                        result = {pcall(promiseNext.onRejected, promise.reason)}
                    else
                        promiseNext.promise:reject(promise.reason)
                    end
                end
                if result then -- 已回调
                    if result[1] then -- 回调成功
                        if xx.instanceOf(result[2], Promise) then -- 返回异步
                            ---@type Promise
                            local promiseResult = result[2]
                            promiseResult:next(
                                function(...) -- 异步完成
                                    promiseNext.promise:resolve(...)
                                    return ...
                                end,
                                function(reason) -- 异步拒绝
                                    promiseNext.promise:reject(reason)
                                    error(reason)
                                end
                            )
                        else -- 返回值
                            xx.arrayRemoveAt(result, 1)
                            promiseNext.promise:resolve(unpack(result))
                        end
                    else -- 回调失败
                        promiseNext.promise:reject(result[2])
                    end
                end
            end
            if promise:isRejected() and 0 == xx.arrayCount(promise._queue) then
                error(promise.reason)
            end
        end
    end
end
---在新协程中调用指定方法
---@type fun(handler:Handler,caller:any,...:any):Promise
---@param handler Handler 需要异步调用的函数
---@param caller any 需要异步调用的函数所属对象
---@vararg any
---@return Promise 异步对象
function Promise.async(handler, caller, ...)
    local promise = Promise()
    Promise.promiseAsyncMap[promise] = xx.Handler(handler, caller, ...)
    return promise
end
---等待异步完成，返回数据最后一个参数为 boolean 值，true 表示 resolved，false 表示 rejected（不能在主线程中调用）
---@type fun(promise:Promise):any
---@param promise Promise 异步对象
---@return any 异步完成返回的数据
function Promise.await(promise)
    assert(coroutine.isyieldable(), "can not yield")
    local co = coroutine.running()
    promise:next(
        function(...) -- 完成
            local result = {coroutine.resume(co, true, ...)}
            if not result[1] then
                error(result[2])
            end
            return ...
        end,
        function(reason) -- 拒绝
            local result = {coroutine.resume(co, false, reason)}
            if not result[1] then
                error(result[2])
            end
            error(reason)
        end
    )
    local result = {coroutine.yield()}
    if not result[1] then -- 拒绝后直接结束协程
        error(result[2])
    end
    xx.arrayRemoveAt(result, 1)
    return unpack(result)
end
---@see Promise#async
xx.async = Promise.async
---@see Promise#await
xx.await = Promise.await
---在新协程中调用指定方法
---@type fun(handler:function|function[],caller:any,...:any):Promise
---@param handler function|function[] 协程函数，或者用表封装的函数（只关心表中第一个元素）
---@param caller any 需要异步调用的函数所属对象
---@vararg any
---@return Promise 返回异步对象
async = function(handler, caller, ...)
    if xx.isFunction(handler) then
        return Promise.async(handler, caller, ...)
    elseif xx.isTable(handler) and xx.isFunction(handler[1]) then
        return Promise.async(handler[1], unpack(xx.arraySlice(handler, 2)))
    end
    error "async only support function"
end
---暂停当前协程，等待异步结束（不能在主线程中调用）
---@type fun(promise:Promise|Promise[]):...
---@param promise Promise|Promise[] 异步对象，或者用表封装的异步对象（只关心表中第一个元素）
---@return ... 返回异步对象结果（unpack(Promise.value)）
await = function(promise)
    if xx.instanceOf(promise, Promise) then
        return Promise.await(promise)
    elseif xx.isTable(promise) and xx.instanceOf(promise[1], Promise) then
        return Promise.await(promise[1])
    end
    error "await only support Promise"
end
