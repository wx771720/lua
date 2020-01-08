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
    -- 启动协程
    for promise, handler in pairs(Promise.promiseAsyncMap) do
        Promise.promiseAsyncMap[promise] = nil
        local result = {
            coroutine.resume(
                coroutine.create(
                    function()
                        -- 回调
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
    -- 遍历所有异步对象：结束后回调
    for i = xx.arrayCount(Promise.queue), 1, -1 do
        local promise = Promise.queue[i]
        -- 异步对象已结束
        if promise:isFulfilled() or promise:isRejected() then
            xx.arrayRemoveAt(Promise.queue, i)
            -- 遍历回调
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
            -- 拒绝并且未吃掉错误
            if promise:isRejected() and 0 == xx.arrayCount(promise._queue) then
                error(promise.reason)
            end
        end
    end
end

---异步调用方法(会在方法末尾添加 onresolve, onreject 参数用于结束该异步，如果未调用其中任何一个方法，则在函数结束后结束异步)
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

---等待异步完成，返回数据最后一个参数为 boolean 值，true 表示 resolved，false 表示 rejected
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

---启动新协程
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
