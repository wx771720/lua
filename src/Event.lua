---事件
---@class Event:ObjectEx by wx771720@outlook.com 2019-09-11 16:55:47
---@field target any 事件派发对象
---@field type string 事件类型
---@field args any[] 携带数据
---@field currentTarget any 当前触发对象
---@field isStopBubble boolean 是否停止冒泡，默认 false
---@field isStopImmediate boolean 是否立即停止后续监听，默认 false
local Event = xx.Class("xx.Event")

---@see Event
xx.Event = Event

---构造函数
function Event:ctor(target, type, args)
    self.target = target
    self.type = type
    self.args = args
    self.isStopBubble = false
    self.isStopImmediate = false
end

---停止事件冒泡
function Event:stopBubble()
    self.isStopBubble = true
end
---立即停止后续执行（会停止事件冒泡）
function Event:stopImmediate()
    self.isStopImmediate = true
    self.isStopBubble = true
end
