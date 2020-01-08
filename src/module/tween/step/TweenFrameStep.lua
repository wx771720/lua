---缓动帧步骤
---@class TweenFrameStep:ObjectEx by wx771720@outlook.com 2019-10-28 17:05:37
---@field _tween Tween 缓动器
---@field _count number 帧数（触发后开始计数）
---
---@field _counted number 已经过帧数
local TweenFrameStep = xx.Class("xx.TweenFrameStep")
---构造函数
function TweenFrameStep:ctor(tween, count)
    self._tween = tween
    self._count = count

    self._counted = 0
end

---更新
---type fun(interval:number):number
---@param interval number 帧间隔（单位：毫秒）
---@return number 剩余时长（单位：毫秒）
function TweenFrameStep:update(interval)
    if self._counted >= self._count then
        self._counted = 0
        self._tween.stepIndex = self._tween.stepIndex + 1
    else
        self._counted = self._counted + 1
        interval = 0
    end
    return interval
end

return TweenFrameStep
