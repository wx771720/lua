---缓动循环步骤
---@class TweenLoopStep:ObjectEx by wx771720@outlook.com 2019-10-26 18:43:59
---@field _tween Tween 缓动器
---@field _count number 缓动次数（触发后开始计数）
---@field _preCount number 循环之前的步骤数量，0 表示循环之前所有的步骤
---@field _onOnce Callback 单次执行时回调
---
---@field _counted number 已执行次数
local TweenLoopStep = xx.Class("xx.TweenLoopStep")
---构造函数
function TweenLoopStep:ctor(tween, count, preCount, onOnce)
    self._tween = tween
    self._count = count or 0
    self._preCount = preCount or 0
    self._onOnce = onOnce

    self._counted = 0
end

---更新
---type fun(interval:number):number
---@param interval number 帧间隔（单位：毫秒）
---@return number 剩余时长（单位：毫秒）
function TweenLoopStep:update(interval)
    if self._counted > 0 and self._onOnce then
        self._onOnce()
    end
    if self._count <= 0 or self._counted < self._count then
        self._counted = self._counted + 1
        if self._preCount <= 0 or self._preCount >= self._tween.stepIndex then
            self._tween.stepIndex = 1
        else
            self._tween.stepIndex = self._tween.stepIndex - self._preCount
        end
    else
        self._counted = 0
        self._tween.stepIndex = self._tween.stepIndex + 1
    end
    return interval
end

return TweenLoopStep
