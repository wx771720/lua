---定时器
---@class Timer:ObjectEx by wx771720@outlook.com 2019-09-03 18:25:12
---@field duration number 间隔时长（单位：毫秒）
---@field count number 执行次数
---@field rate number 速率
---@field onOnce Callback 执行回调
---@field onComplete Callback 完成回调
---@field counted number 已执行次数
---@field time number 已运行时长（单位：毫秒）
---@field isPaused boolean 是否已暂停
---@field isStopped boolean 是否已停止
---@field trigger boolean 是否在主动停止时触发完成回调
local Timer = xx.Class("xx.Timer")

---构造函数
function Timer:ctor(duration, count, rate, onOnce, onComplete)
    self.duration = duration
    self.count = count
    self.rate = rate
    self.onOnce = onOnce
    self.onComplete = onComplete

    self.counted = 0
    self.time = 0
    self.isPaused = false
    self.isStopped = false
    self.trigger = false
end

---判断定时器是否已完成
---@type fun():boolean
---@return boolean 如果已完成则返回 true，否则返回 false
function Timer:isComplete()
    return self.count > 0 and self.counted >= self.count
end

return Timer
