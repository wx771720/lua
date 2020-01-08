---通知结果
---@class NoticeResult:ObjectEx by wx771720@outlook.com 2019-09-11 20:04:17
---@field stop boolean 是否停止后续模块的执行
---@field data any 通知直接返回的数据
local NoticeResult = xx.Class("xx.NoticeResult")

---@see NoticeResult
xx.NoticeResult = NoticeResult

---构造函数
function NoticeResult:ctor()
    self.stop = false
    self.data = nil
end
