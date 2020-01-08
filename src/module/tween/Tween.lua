---@type TweenStop
local TweenStop = require "TweenStop"
---@type TweenStep
local TweenStep = require "TweenStep"
---@type TweenSetStep
local TweenSetStep = require "TweenSetStep"
---@type TweenSleepStep
local TweenSleepStep = require "TweenSleepStep"
---@type TweenFrameStep
local TweenFrameStep = require "TweenFrameStep"
---@type TweenRateStep
local TweenRateStep = require "TweenRateStep"
---@type TweenLoopStep
local TweenLoopStep = require "TweenLoopStep"
---@type TweenCallbackStep
local TweenCallbackStep = require "TweenCallbackStep"

---缓动器
---@class Tween:Promise by wx771720@outlook.com 2019-10-25 18:17:58
---@field rate number 速率
---@field targets any[] 缓动对象列表
---@field curValueMap table<any,table<string,any>> 缓动对象 - 当前值[k-v]
---@field endValueMap table<any,table<string,any>> 缓动对象 - 结束值[k-v]
---@field stepIndex number 当前步骤索引
---@field stepList TweenStep[] 步骤列表
---@field stopList TweenStop[] 停止缓动对象列表
---@field isPaused boolean 是否已暂停
---@field isStopped boolean 是否已停止
---@field trigger boolean 是否在停止时触发回调
---@field toEnd boolean 是否在停止时设置属性为结束值
---@field isCompleted boolean 判断缓动器是否已结束
local Tween = xx.Class("xx.Tween", xx.Promise)
---构造函数
function Tween:ctor(...)
    self.rate = 1
    self.targets = {...}
    self.curValueMap = {}
    self.endValueMap = {}
    for _, target in ipairs(self.targets) do
        self.curValueMap[target] = {}
        self.endValueMap[target] = {}
    end
    self.stepIndex = 1
    self.stepList = {}
    self.stopList = {}
    self.isPaused = false
    self.isStopped = false
    self.trigger = false
    self.toEnd = false
    self.isCompleted = false
end

---获取属性值
---@type fun(key:string):any
---@param key string 属性名
---@return any 属性值
function Tween:getter(key)
    if "isCompleted" == key then
        return self.stepIndex > xx.arrayCount(self.stepList)
    end
    return xx.Class.getter(self, key)
end

---暂停
---@type fun()
function Tween:pause()
    self.isPaused = true
end

---继续
---@type fun()
function Tween:resume()
    self.isPaused = false
end

---停止
---@type fun(trigger:boolean,toEnd:boolean,...:any)
---@param trigger boolean 是否在停止时触发回调
---@param trigger boolean 是否在停止时设置属性为结束值
---@vararg any
function Tween:stop(trigger, toEnd, ...)
    local targets = {...}
    local count = xx.arrayCount(targets)
    if 0 == count then
        self.isStopped = true
        self.trigger = trigger
        self.toEnd = toEnd
    else
        for i = 1, count do
            xx.arrayPush(TweenStop(targets[i], trigger, toEnd))
        end
    end
end

---添加缓动属性值步骤
---@type fun(properties:table<string,number>,time:number,playback:boolean|nil,ease:Ease|nil,onPlayback:Callback|nil,onUpdate:Callback|nil):Tween
---@param properties table<string,number> 键值对，支持 number[] 值表表示贝塞尔缓动
---@param time number 缓动时长（单位：毫秒）
---@param playback boolean|nil 是否回播，默认 false
---@param ease Ease|nil 缓动函数，默认 nil 表示线性缓动
---@param onPlayback Callback 回播时回调，默认 nil
---@param onUpdate Callback 更新时回调，默认 nil
---@return Tween self
function Tween:to(properties, time, playback, ease, onPlayback, onUpdate)
    for _, target in ipairs(self.targets) do
        local curMap = self.curValueMap[target]
        local endMap = self.endValueMap[target]
        for k, v in pairs(properties) do
            if not curMap[k] then
                curMap[k] = target[k]
            end

            if not playback then
                endMap[k] = xx.isTable(v) and v[xx.arrayCount(v)] or v
            elseif not endMap[k] then
                endMap[k] = curMap[k]
            end
        end
    end
    xx.arrayPush(self.stepList, TweenStep(self, true, properties, time, playback, ease, onPlayback, onUpdate))
    return self
end

---添加缓动属性值步骤
---@type fun(properties:table<string,number>,time:number,playback:boolean|nil,ease:Ease|nil,onPlayback:Callback|nil,onUpdate:Callback|nil):Tween
---@param properties table<string,number> 键值对，支持 number[] 值表表示贝塞尔缓动
---@param time number 缓动时长（单位：毫秒）
---@param playback boolean|nil 是否回播，默认 false
---@param ease Ease|nil 缓动函数，默认 nil 表示线性缓动
---@param onPlayback Callback|nil 回播时回调，默认 nil
---@param onUpdate Callback|nil 更新时回调，默认 nil
---@return Tween self
function Tween:by(properties, time, playback, ease, onPlayback, onUpdate)
    for _, target in ipairs(self.targets) do
        local curMap = self.curValueMap[target]
        local endMap = self.endValueMap[target]
        for k, v in pairs(properties) do
            if not curMap[k] then
                curMap[k] = target[k]
            end

            if not playback then
                if xx.isTable(v) then
                    v = v[xx.arrayCount(v)]
                end
                endMap[k] = (endMap[k] or curMap[k]) + v
            elseif not endMap[k] then
                endMap[k] = curMap[k]
            end
        end
    end
    xx.arrayPush(self.stepList, TweenStep(self, false, properties, time, playback, ease, onPlayback, onUpdate))
    return self
end

---添加设置属性值步骤
---@type fun(properties:table<string,number>):Tween
---@param properties table<string,number> 键值对，支持 number[] 值表表示贝塞尔缓动
---@return Tween self
function Tween:setTo(properties)
    for _, target in ipairs(self.targets) do
        local curMap = self.curValueMap[target]
        local endMap = self.endValueMap[target]
        for k, v in pairs(properties) do
            if not curMap[k] then
                curMap[k] = target[k]
            end
            endMap[k] = v
        end
    end
    xx.arrayPush(self.stepList, TweenSetStep(self, true, properties))
    return self
end

---添加设置属性值步骤
---@type fun(properties:table<string,number>):Tween
---@param properties table<string,number> 键值对，支持 number[] 值表表示贝塞尔缓动
---@return Tween self
function Tween:setBy(properties)
    for _, target in ipairs(self.targets) do
        local curMap = self.curValueMap[target]
        local endMap = self.endValueMap[target]
        for k, v in pairs(properties) do
            if not curMap[k] then
                curMap[k] = target[k]
            end
            endMap[k] = (endMap[k] or curMap[k]) + v
        end
    end
    xx.arrayPush(self.stepList, TweenSetStep(self, false, properties))
    return self
end

---添加设置速率步骤
---@type fun(rate:number|nil):Tween
---@param rate number|nil 速率
---@return Tween self
function Tween:rateTo(rate)
    xx.arrayPush(self.stepList, TweenRateStep(self, true, rate))
    return self
end

---添加设置速率步骤
---@type fun(rate:number|nil):Tween
---@param rate number|nil 速率
---@return Tween self
function Tween:rateBy(rate)
    xx.arrayPush(self.stepList, TweenRateStep(self, false, rate))
    return self
end

---添加睡眠步骤
---@type fun(time:number):Tween
---@param time number 睡眠时长（单位：毫秒）
---@return Tween self
function Tween:sleep(time)
    xx.arrayPush(self.stepList, TweenSleepStep(self, time))
    return self
end

---添加帧步骤
---@type fun(count:number):Tween
---@param count number 帧数（触发后开始计数）
---@return Tween self
function Tween:frame(count)
    xx.arrayPush(self.stepList, TweenFrameStep(self, count))
    return self
end

---添加循环步骤
---@type fun(count:number|nil,preCount:number|nil,onOnce:Callback|nil):Tween
---@param count number|nil 循环次数（触发后开始计数），默认 0 表示无限循环
---@param preCount number|nil 循环之前的步骤数量，默认 0 表示循环之前所有步骤
---@param onOnce Callback|nil 单次执行时回调
---@return Tween self
function Tween:loop(count, preCount, onOnce)
    xx.arrayPush(self.stepList, TweenLoopStep(self, count, preCount, onOnce))
    return self
end

---添加回调步骤
---@type fun(callback:Callback):Tween
---@param callback Callback 回调
---@return Tween self
function Tween:callback(callback)
    xx.arrayPush(self.stepList, TweenCallbackStep(self, callback))
    return self
end

return Tween
