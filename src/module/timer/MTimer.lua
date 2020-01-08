---@type Timer
local Timer = require "Timer"

---定时器模块
---@class MTimer:Module by wx771720@outlook.com 2019-09-03 08:50:01
---@field _isPaused boolean 是否已暂停定时器模块
---@field _timerList Timer[] 定时器列表
---@field _uidTimerMap table<string, Timer> id - 定时器
local MTimer = xx.Class("xx.MTimer", xx.Module)

---@see Timer
xx.MTimer = MTimer

---构造函数
function MTimer:ctor()
    self._isPaused = false
    self._timerList = {}
    self._uidTimerMap = {}

    self._noticeHandlerMap[GIdentifiers.nb_timer] = self.onAppTimer
    self._noticeHandlerMap[GIdentifiers.nb_pause] = self.onAppPause
    self._noticeHandlerMap[GIdentifiers.nb_resume] = self.onAppResume

    self._noticeHandlerMap[GIdentifiers.ni_timer_new] = self.onNew
    self._noticeHandlerMap[GIdentifiers.ni_timer_pause] = self.onPause
    self._noticeHandlerMap[GIdentifiers.ni_timer_resume] = self.onResume
    self._noticeHandlerMap[GIdentifiers.ni_timer_stop] = self.onStop
    self._noticeHandlerMap[GIdentifiers.ni_timer_rate] = self.onRate
end

---@param result NoticeResult 直接返回结果
---@param interval number 帧间隔（单位：毫秒）
function MTimer:onAppTimer(result, interval)
    -- 已暂停
    if self._isPaused then
        return
    end
    -- 有效帧
    if interval < 1000 then
        for i = xx.arrayCount(self._timerList), 1, -1 do
            local timer = self._timerList[i]
            -- 已停止
            if timer.isStopped then
                self._uidTimerMap[timer.uid] = nil
                xx.arrayRemoveAt(self._timerList, i)
                if timer.trigger and timer.onComplete then -- 触发回调
                    timer.onComplete()
                end
            elseif not timer.isPaused then -- 正常
                local time = interval * timer.rate
                timer.time = timer.time + time
                local count = timer.duration > 0 and math.floor(timer.time / timer.duration) - timer.counted or 1
                while count > 0 and not timer:isComplete() and not timer.isPaused and not timer.isStopped do
                    timer.counted = timer.counted + 1
                    if timer.onOnce then -- 触发回调
                        timer.onOnce(time, timer.counted)
                    end
                    time = 0
                    count = count - 1
                end
                -- 完成
                if timer:isComplete() and not timer.isPaused and not timer.isStopped then
                    self._uidTimerMap[timer.uid] = nil
                    xx.arrayRemoveAt(self._timerList, i)
                    if timer.onComplete then -- 触发回调
                        timer.onComplete()
                    end
                end
            end
        end
    end
    -- 异步
    xx.Promise.asyncLoop()
end

---@param result NoticeResult 直接返回结果
function MTimer:onAppPause(result)
    self._isPaused = true
end

---@param result NoticeResult 直接返回结果
function MTimer:onAppResume(result)
    self._isPaused = false
end

---@param result NoticeResult 直接返回结果
---@param durationOrTimer number|Timer 时间间隔（单位：毫秒）或者 Timer 对象
---@param countOrOnComplete number|Callback 执行次数或者完成回调、信号、异步
---@param onOnce Callback 执行回调、信号、异步
---@param onComplete Callback 完成回调、信号、异步
function MTimer:onNew(result, durationOrTimer, countOrOnComplete, onOnce, onComplete)
    ---@type Timer
    local timer
    if xx.instanceOf(durationOrTimer, Timer) then
        timer = durationOrTimer
        if xx.isNil(timer.onComplete) and xx.instanceOf(countOrOnComplete, xx.Callback) then
            timer.onComplete = countOrOnComplete
        end
    else
        timer = Timer(durationOrTimer, countOrOnComplete, 1, onOnce, onComplete)
    end
    xx.arrayPush(self._timerList, timer)
    self._uidTimerMap[timer.uid] = timer
    result.data = timer.uid
end

---@param result NoticeResult 直接返回结果
---@param id string 定时器 id
function MTimer:onPause(result, id)
    if self._uidTimerMap[id] then
        self._uidTimerMap[id].isPaused = true
    end
end

---@param result NoticeResult 直接返回结果
---@param id string 定时器 id
function MTimer:onResume(result, id)
    if self._uidTimerMap[id] then
        self._uidTimerMap[id].isPaused = false
    end
end

---@param result NoticeResult 直接返回结果
---@param id string 定时器 id
---@param trigger boolean 是否触发回调
function MTimer:onStop(result, id, trigger)
    if self._uidTimerMap[id] then
        self._uidTimerMap[id].isStopped = true
        self._uidTimerMap[id].trigger = trigger
    end
end

---@param result NoticeResult 直接返回结果
---@param id string 定时器 id
---@param rate number 速率
function MTimer:onRate(result, id, rate)
    local id, rate = unpack(args)
    if self._uidTimerMap[id] then
        self._uidTimerMap[id].rate = rate
    end
end

---下一帧执行回调
---@type fun(handler:Handler,caller:any,...:any):string
---@param handler Handler 回调函数
---@param caller any 回调函数所属对象
---@vararg any
---@return string 定时器 id
function xx.later(handler, caller, ...)
    return xx.notify(GIdentifiers.ni_timer_new, 0, 1, nil, xx.Callback(handler, caller, ...))
end

---延迟指定时长执行回调
---@type fun(time:number,handler:Handler,caller:any,...:any):string
---@param time number 延迟时长（单位：毫秒）
---@param handler Handler 回调函数
---@param caller any 回调函数所属对象
---@vararg any
---@return string 定时器 id
function xx.delay(time, handler, caller, ...)
    return xx.notify(GIdentifiers.ni_timer_new, time, 1, nil, xx.Callback(handler, caller, ...))
end

---按指定间隔调用指定次数回调
---@type fun(interval:number,count:number,onOnce:Handler,caller:any,onComplete:Handler,...:any):string
---@param interval number 间隔时长（单位：毫秒）
---@param count number 调用次数
---@param onOnce Handler 单次回调函数
---@param caller any 回调函数所属对象
---@param onComplete Handler 所有次数完成回调函数
---@vararg any
---@return string 定时器 id
function xx.loop(interval, count, onOnce, caller, onComplete, ...)
    onOnce = xx.isFunction(onOnce) and xx.Callback(onOnce, caller, ...) or nil
    onComplete = xx.isFunction(onComplete) and xx.Callback(onComplete, caller, ...) or nil
    return xx.notify(GIdentifiers.ni_timer_new, interval, count, onOnce, onComplete)
end

---睡眠指定时长
---@type fun(time:number):Promise
---@param time number 等待时长（单位：毫秒）
---@return Promise 返回异步对象
function xx.sleep(time)
    local promise = xx.Promise()
    return promise, xx.delay(
        time,
        function()
            promise:resolve()
        end
    )
end

---暂停定时器
---@type fun(id:string)
---@param id string 定时器 id
function xx.timerPause(id)
    xx.notify(GIdentifiers.ni_timer_pause, id)
end

---继续定时器
---@type fun(id:string)
---@param id string 定时器 id
function xx.timerResume(id)
    xx.notify(GIdentifiers.ni_timer_resume, id)
end

---停止定时器
---@type fun(id:string,trigger:boolean)
---@param id string 定时器 id
---@param trigger boolean 是否触发完成回调，默认 false
function xx.timerStop(id, trigger)
    if not xx.isBoolean(trigger) then
        trigger = false
    end
    xx.notify(GIdentifiers.ni_timer_stop, id, trigger)
end

---修改定时器速率
---@type fun(id:string,rate:number)
---@param id string 定时器 id
---@param rate number 定时器速率，默认 1 表示恢复正常速率
function xx.timerRate(id, rate)
    if not xx.isNumber(rate) then
        rate = 1
    end
    xx.notify(GIdentifiers.ni_timer_rate, id, rate)
end

xx.getInstance("xx.MTimer")
