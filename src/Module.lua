---模块类
---@class Module:Framework by wx771720@outlook.com 2019-09-03 08:55:51
---@field _noticeHandlerMap table<string, Handler>
local Module = xx.Class("xx.Module", xx.Framework)

---@see Module
xx.Module = Module

---构造函数
function Module:ctor()
    self._noticeHandlerMap = {}
end

---构造完成函数
function Module:ctored()
    local notices = xx.tableKeys(self._noticeHandlerMap)
    if xx.arrayCount(notices) > 0 then
        self:register(unpack(notices))
    end
end

---@type fun(notice:string,result:NoticeResult,...:any): any, boolean
---@param notice strting 通知
---@param result NoticeResult 直接返回结果
---@vararg any
---@return any, boolean 返回数据，是否停止该通知的后续监听
function Module:onNotice(notice, result, ...)
    if self._noticeHandlerMap[notice] then
        return self._noticeHandlerMap[notice](self, result, ...)
    end
end
