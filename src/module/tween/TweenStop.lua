---停止缓动对象类
---@class TweenStop:ObjectEx by wx771720@outlook.com 2019-10-25 20:22:03
---@field target any 对象
---@field trigger boolean 是否在停止时触发回调
---@field toEnd boolean 是否在停止时设置属性为结束值
local TweenStop = xx.Class("TweenStop")
---构造函数
function TweenStop:ctor(target, trigger, toEnd)
    self.target = target
    self.trigger = trigger
    self.toEnd = toEnd
end

return TweenStop
