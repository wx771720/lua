---启动模块
---@class MLauncher:Module by wx771720@outlook.com 2019-10-12 16:42:43
local MLauncher = xx.Class("xx.MLauncher", xx.Module)
---构造函数
function MLauncher:ctor()
    self._noticeHandlerMap[GIdentifiers.nb_lauch] = self.onLaunch
end

---@param result NoticeResult
---@param root GameObject
function MLauncher:onLaunch(result)
    ---@type Root
    xx.root = xx.Root(xx.Util.GetRootCVS(), xx.Util.GetRootGO())
    xx.addInstance(xx.root)
end

xx.getInstance("xx.MLauncher")
