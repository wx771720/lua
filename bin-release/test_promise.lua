---run cmd:
---cd bin-release
---lua test_promise.lua
require "bin.promise"

---入口类
---@class Main:ObjectEx by wx771720@outlook.com 2020-01-09 16:35:23
local Main = xx.Class("Main")
---构造函数
function Main:ctor()
end

---测试 Promise
function Main:test()
    -- 异步对象：先缓存实例，然后可在任意地方结束或者拒绝异步
    local promise = xx.Promise()
    -- 测试异步完成回调
    promise:next(
        function(...)
            print("promise resolved : ", ...)
            return ...
        end,
        function(err)
            print("promise rejected : ", err)
            error(err)
        end
    )
    -- 异步等待测试
    async {self.asyncTest, self, promise} -- 等价于 async(self.asyncTest, self, promise)

    -- resolve
    promise:resolve(1, "22", true)
    -- reject
    -- promise:reject("canceled")
end
---测试 Promise
function Main:test2()
    -- 异步对象：使用异步对象运行方法，缓存 resolve 和 reject 回调，然后可在任意地方结束或者拒绝异步
    local promise =
        xx.Promise(
        function(resolve, reject)
            -- resolve
            resolve(1, "22", true)
            -- reject
            -- reject("canceled")
        end
    )
    -- 测试异步完成回调
    promise:next(
        function(...)
            print("promise resolved : ", ...)
            return ...
        end,
        function(err)
            print("promise rejected : ", err)
            error(err)
        end
    )
    -- 异步等待测试
    async {self.asyncTest, self, promise} -- 等价于 async(self.asyncTest, self, promise)
end

---测试异步等待
function Main:asyncTest(promise)
    print("before await")
    local result = {await {promise}} -- 等价于 local result = {await(promise)}
    print("after await : ", unpack(result))
end

---执行测试
Main():test()
-- Main():test2()

---xx.Promise.asyncLoop 该方法应该由帧循环调用，这里就连续调用多次查看 promise 状态
---如果想查看真正的效果，可以在有定时器功能的环境运行
xx.Promise.asyncLoop()
xx.Promise.asyncLoop()
xx.Promise.asyncLoop()
xx.Promise.asyncLoop()

--[[打印结果：
    resolve print:
        before await
        promise resolved :      1       22      true
        after await :   1       22      true

    reject print :
        before await
        promise rejected :      canceled
        lua.exe: .\bin\promise.lua:893: .\bin\promise.lua:929: canceled
        stack traceback:
                [C]: in function 'error'
                .\bin\promise.lua:893: in field 'asyncLoop'
                test_promise.lua:52: in method 'test'
                test_promise.lua:64: in main chunk
                [C]: in ?
--]]
