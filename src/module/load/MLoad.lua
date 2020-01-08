---资源加载模块
---@class MLoad:Module by wx771720@outlook.com 2019-12-19 17:57:42
local MLoad = xx.Class("xx.MLoad", xx.Module)
---构造函数
function MLoad:ctor()
    self._noticeHandlerMap[GIdentifiers.ni_load] = self.onLoad
    self._noticeHandlerMap[GIdentifiers.ni_load_stop] = self.onStop
end

---@param result NoticeResult
---@param url string 资源地址
---@param type string 资源类型
---@param tryCount number 加载超时后的重试次数，小于 0 表示无限次数，等于 0 表示不重试
---@param tryDelay number 加载超时后重试间隔时长（单位：毫秒）
---@param timeout number 加载超时时长（单位：毫秒）
---@param onRetry Callback 重试时回调
---@param onComplete Callback 加载完成后回调，参数：string|byte[]|null
function MLoad:onLoad(result, url, type, tryCount, tryDelay, timeout, onRetry, onComplete)
    result.data =
        xx.Util.Load(
        url,
        function(...)
            if onComplete then
                onComplete(...)
            end
        end,
        function(...)
            if onRetry then
                onRetry(...)
            end
        end,
        type,
        tryCount or 0,
        tryDelay or 1000,
        timeout or 0
    )
end

---@param result NoticeResult
---@param id string 加载 id
function MLoad:onStop(result, id)
    xx.Util.LoadStop(id)
end

---加载资源
---@type fun(url:string,onComplete:nil|Handler,onRetry:nil|Handler,type:nil|string,tryCount:nil|number,tryDelay:nil|number,timeout:nil|number):string
---@param url string 资源地址
---@param onComplete Handler 加载完成后回调，参数：string|byte[]|null
---@param onRetry Handler 重试时回调
---@param type string 资源类型
---@param tryCount number 加载超时后的重试次数，小于 0 表示无限次数，等于 0 表示不重试
---@param tryDelay number 加载超时后重试间隔时长（单位：毫秒）
---@param timeout number 加载超时时长（单位：毫秒）
---@return string 返回加载 id
function xx.load(url, onComplete, onRetry, type, tryCount, tryDelay, timeout)
    xx.notify(
        GIdentifiers.ni_load,
        url,
        type,
        tryCount,
        tryDelay,
        timeout,
        xx.Callback(onRetry),
        xx.Callback(onComplete)
    )
end
---加载资源
---@type fun(url:string,onComplete:nil|Handler,onRetry:nil|Handler,tryCount:nil|number,tryDelay:nil|number,timeout:nil|number):string
---@param url string 资源地址
---@param onComplete Handler 加载完成后回调，参数：string|byte[]|null
---@param onRetry Handler 重试时回调
---@param tryCount number 加载超时后的重试次数，小于 0 表示无限次数，等于 0 表示不重试
---@param tryDelay number 加载超时后重试间隔时长（单位：毫秒）
---@param timeout number 加载超时时长（单位：毫秒）
---@return string 返回加载 id
function xx.loadBinary(url, onComplete, onRetry, tryCount, tryDelay, timeout)
    xx.load(url, onComplete, onRetry, GIdentifiers.load_type_binary, tryCount, tryDelay, timeout)
end
---加载资源
---@type fun(url:string,onComplete:nil|Handler,onRetry:nil|Handler,tryCount:nil|number,tryDelay:nil|number,timeout:nil|number):string
---@param url string 资源地址
---@param onComplete Handler 加载完成后回调，参数：string|byte[]|null
---@param onRetry Handler 重试时回调
---@param tryCount number 加载超时后的重试次数，小于 0 表示无限次数，等于 0 表示不重试
---@param tryDelay number 加载超时后重试间隔时长（单位：毫秒）
---@param timeout number 加载超时时长（单位：毫秒）
---@return string 返回加载 id
function xx.loadString(url, onComplete, onRetry, tryCount, tryDelay, timeout)
    xx.load(url, onComplete, onRetry, GIdentifiers.load_type_string, tryCount, tryDelay, timeout)
end
---加载资源
---@type fun(url:string,onComplete:nil|Handler,onRetry:nil|Handler,tryCount:nil|number,tryDelay:nil|number,timeout:nil|number):string
---@param url string 资源地址
---@param onComplete Handler 加载完成后回调，参数：string|byte[]|null
---@param onRetry Handler 重试时回调
---@param tryCount number 加载超时后的重试次数，小于 0 表示无限次数，等于 0 表示不重试
---@param tryDelay number 加载超时后重试间隔时长（单位：毫秒）
---@param timeout number 加载超时时长（单位：毫秒）
---@return string 返回加载 id
function xx.loadTexture(url, onComplete, onRetry, tryCount, tryDelay, timeout)
    xx.load(url, onComplete, onRetry, GIdentifiers.load_type_texture, tryCount, tryDelay, timeout)
end
---加载资源
---@type fun(url:string,onComplete:nil|Handler,onRetry:nil|Handler,tryCount:nil|number,tryDelay:nil|number,timeout:nil|number):string
---@param url string 资源地址
---@param onComplete Handler 加载完成后回调，参数：string|byte[]|null
---@param onRetry Handler 重试时回调
---@param tryCount number 加载超时后的重试次数，小于 0 表示无限次数，等于 0 表示不重试
---@param tryDelay number 加载超时后重试间隔时长（单位：毫秒）
---@param timeout number 加载超时时长（单位：毫秒）
---@return string 返回加载 id
function xx.loadSprite(url, onComplete, onRetry, tryCount, tryDelay, timeout)
    xx.load(url, onComplete, onRetry, GIdentifiers.load_type_sprite, tryCount, tryDelay, timeout)
end
---加载资源
---@type fun(url:string,onComplete:nil|Handler,onRetry:nil|Handler,tryCount:nil|number,tryDelay:nil|number,timeout:nil|number):string
---@param url string 资源地址
---@param onComplete Handler 加载完成后回调，参数：string|byte[]|null
---@param onRetry Handler 重试时回调
---@param tryCount number 加载超时后的重试次数，小于 0 表示无限次数，等于 0 表示不重试
---@param tryDelay number 加载超时后重试间隔时长（单位：毫秒）
---@param timeout number 加载超时时长（单位：毫秒）
---@return string 返回加载 id
function xx.loadAudio(url, onComplete, onRetry, tryCount, tryDelay, timeout)
    xx.load(url, onComplete, onRetry, GIdentifiers.load_type_audioclip, tryCount, tryDelay, timeout)
end
---加载资源
---@type fun(url:string,onComplete:nil|Handler,onRetry:nil|Handler,tryCount:nil|number,tryDelay:nil|number,timeout:nil|number):string
---@param url string 资源地址
---@param onComplete Handler 加载完成后回调，参数：string|byte[]|null
---@param onRetry Handler 重试时回调
---@param tryCount number 加载超时后的重试次数，小于 0 表示无限次数，等于 0 表示不重试
---@param tryDelay number 加载超时后重试间隔时长（单位：毫秒）
---@param timeout number 加载超时时长（单位：毫秒）
---@return string 返回加载 id
function xx.loadAssetBundle(url, onComplete, onRetry, tryCount, tryDelay, timeout)
    xx.load(url, onComplete, onRetry, GIdentifiers.load_type_assetbundle, tryCount, tryDelay, timeout)
end

---异步加载资源
---@type fun(url:string,onRetry:nil|Handler,type:nil|string,tryCount:nil|number,tryDelay:nil|number,timeout:nil|number):Promise
---@param url string 资源地址
---@param onRetry Handler 重试时回调
---@param type string 资源类型
---@param tryCount number 加载超时后的重试次数，小于 0 表示无限次数，等于 0 表示不重试
---@param tryDelay number 加载超时后重试间隔时长（单位：毫秒）
---@param timeout number 加载超时时长（单位：毫秒）
---@return Promise 异步对象
function xx.loadAsync(url, onRetry, type, tryCount, tryDelay, timeout)
    local promise = xx.Promise()
    return promise, xx.load(
        url,
        function(...)
            promise:resolve(...)
        end,
        onRetry,
        type,
        tryCount,
        tryDelay,
        timeout
    )
end
---异步加载资源
---@type fun(url:string,onRetry:nil|Handler,tryCount:nil|number,tryDelay:nil|number,timeout:nil|number):Promise
---@param url string 资源地址
---@param onRetry Handler 重试时回调
---@param tryCount number 加载超时后的重试次数，小于 0 表示无限次数，等于 0 表示不重试
---@param tryDelay number 加载超时后重试间隔时长（单位：毫秒）
---@param timeout number 加载超时时长（单位：毫秒）
---@return Promise 异步对象
function xx.loadBinaryAsync(url, onRetry, tryCount, tryDelay, timeout)
    return xx.loadAsync(url, onRetry, GIdentifiers.load_type_binary, tryCount, tryDelay, timeout)
end
---异步加载资源
---@type fun(url:string,onRetry:nil|Handler,tryCount:nil|number,tryDelay:nil|number,timeout:nil|number):Promise
---@param url string 资源地址
---@param onRetry Handler 重试时回调
---@param tryCount number 加载超时后的重试次数，小于 0 表示无限次数，等于 0 表示不重试
---@param tryDelay number 加载超时后重试间隔时长（单位：毫秒）
---@param timeout number 加载超时时长（单位：毫秒）
---@return Promise 异步对象
function xx.loadStringAsync(url, onRetry, tryCount, tryDelay, timeout)
    return xx.loadAsync(url, onRetry, GIdentifiers.load_type_string, tryCount, tryDelay, timeout)
end
---异步加载资源
---@type fun(url:string,onRetry:nil|Handler,tryCount:nil|number,tryDelay:nil|number,timeout:nil|number):Promise
---@param url string 资源地址
---@param onRetry Handler 重试时回调
---@param tryCount number 加载超时后的重试次数，小于 0 表示无限次数，等于 0 表示不重试
---@param tryDelay number 加载超时后重试间隔时长（单位：毫秒）
---@param timeout number 加载超时时长（单位：毫秒）
---@return Promise 异步对象
function xx.loadTextureAsync(url, onRetry, tryCount, tryDelay, timeout)
    return xx.loadAsync(url, onRetry, GIdentifiers.load_type_texture, tryCount, tryDelay, timeout)
end
---异步加载资源
---@type fun(url:string,onRetry:nil|Handler,tryCount:nil|number,tryDelay:nil|number,timeout:nil|number):Promise
---@param url string 资源地址
---@param onRetry Handler 重试时回调
---@param tryCount number 加载超时后的重试次数，小于 0 表示无限次数，等于 0 表示不重试
---@param tryDelay number 加载超时后重试间隔时长（单位：毫秒）
---@param timeout number 加载超时时长（单位：毫秒）
---@return Promise 异步对象
function xx.loadSpriteAsync(url, onRetry, tryCount, tryDelay, timeout)
    return xx.loadAsync(url, onRetry, GIdentifiers.load_type_sprite, tryCount, tryDelay, timeout)
end
---异步加载资源
---@type fun(url:string,onRetry:nil|Handler,tryCount:nil|number,tryDelay:nil|number,timeout:nil|number):Promise
---@param url string 资源地址
---@param onRetry Handler 重试时回调
---@param tryCount number 加载超时后的重试次数，小于 0 表示无限次数，等于 0 表示不重试
---@param tryDelay number 加载超时后重试间隔时长（单位：毫秒）
---@param timeout number 加载超时时长（单位：毫秒）
---@return Promise 异步对象
function xx.loadAudioAsync(url, onRetry, tryCount, tryDelay, timeout)
    return xx.loadAsync(url, onRetry, GIdentifiers.load_type_audioclip, tryCount, tryDelay, timeout)
end
---异步加载资源
---@type fun(url:string,onRetry:nil|Handler,tryCount:nil|number,tryDelay:nil|number,timeout:nil|number):Promise
---@param url string 资源地址
---@param onRetry Handler 重试时回调
---@param tryCount number 加载超时后的重试次数，小于 0 表示无限次数，等于 0 表示不重试
---@param tryDelay number 加载超时后重试间隔时长（单位：毫秒）
---@param timeout number 加载超时时长（单位：毫秒）
---@return Promise 异步对象
function xx.loadAssetBundleAsync(url, onRetry, tryCount, tryDelay, timeout)
    return xx.loadAsync(url, onRetry, GIdentifiers.load_type_assetbundle, tryCount, tryDelay, timeout)
end

---停止加载资源
---@type fun(id:string)
---@param id string 加载 id
function xx.loadStop(id)
    xx.notify(GIdentifiers.ni_load_stop, id)
end

xx.getInstance("xx.MLoad")
