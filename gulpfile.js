const {
    argv, md5, fs,
    gulp, mergeStream, rename, concat, zip, ftp, xlsx, protobuf,
    mkdir, removedir, removefile, copydir, copyFile, renameFile, dateformat,
    parseIdentifiers, parseConfig, parseProto, parseExcel
} = require("./gulps/deps");

const { outGID } = require("./gulps/outGID");
const { moduleParser } = require("./gulps/moduleParser");
const { release } = require("./gulps/release");



//gid 输出文件名
const gidName = "GIdentifiers";
// gid 输入目录列表
const gidInPathList = [
    "src/"
]
//gid 输出目录
const gidOutPath = "src/"
//gid 任务
gulp.task("outGID", function (done) {
    outGID(gidName, 10000, gidOutPath, ...gidInPathList);
    done();
});



const moduleName = "modules";
//模块任务
gulp.task("outModule", function (done) {
    moduleParser(moduleName, "", "src/", "src/");
    done();
});

//需要发布的 Class 相关文件地址列表
const classURLList = [
];
//Promise 发布文件名
const classReleaseName = "class";

//需要发布的 Promise 相关文件地址列表
const promiseURLList = [
    "src/Promise.lua",
];
//Promise 发布文件名
const promiseReleaseName = "promise";

//需要发布的 Protobuf 相关文件地址列表
const protobufURLList = [,
    "src/protobuf/Bit.lua",
    "src/protobuf/PBField.lua",
    "src/protobuf/PBMessage.lua",
    "src/protobuf/PBEnum.lua",
    "src/protobuf/PBRoot.lua",
    "src/protobuf/PBWriter.lua",
    "src/protobuf/PBReader.lua",
    "src/protobuf/PBParser.lua",
    "src/protobuf/Protobuf.lua",
];
//Protobuf 发布文件名
const protobufReleaseName = "protobuf";

//需要发布的 lua 文件地址列表（注意顺序，不需要指定 src/core 目录下的 lua 文件）
const urlList = [
    `${gidOutPath}${gidName}.lua`,

    "src/common/JSON.lua",
    "src/common/Util.lua",

    "src/protobuf/Bit.lua",
    "src/protobuf/PBField.lua",
    "src/protobuf/PBMessage.lua",
    "src/protobuf/PBEnum.lua",
    "src/protobuf/PBRoot.lua",
    "src/protobuf/PBWriter.lua",
    "src/protobuf/PBReader.lua",
    "src/protobuf/PBParser.lua",
    "src/protobuf/Protobuf.lua",

    "src/Callback.lua",
    "src/Promise.lua",
    "src/Signal.lua",
    "src/Event.lua",
    "src/EventDispatcher.lua",
    "src/NoticeResult.lua",
    "src/Framework.lua",
    "src/Module.lua",
    "src/State.lua",
    "src/Node.lua",

    "src/unity/CSUtil.lua",
    "src/unity/UnityDefines.lua",
    "src/unity/Sprite.lua",
    "src/unity/Root.lua",

    "src/module/timer/Timer.lua",
    "src/module/timer/MTimer.lua",

    "src/module/tween/step/TweenCallbackStep.lua",
    "src/module/tween/step/TweenFrameStep.lua",
    "src/module/tween/step/TweenLoopStep.lua",
    "src/module/tween/step/TweenRateStep.lua",
    "src/module/tween/step/TweenSetStep.lua",
    "src/module/tween/step/TweenSleepStep.lua",
    "src/module/tween/step/TweenStep.lua",
    "src/module/tween/TweenStop.lua",
    "src/module/tween/TweenEase.lua",
    "src/module/tween/Tween.lua",
    "src/module/tween/MTween.lua",

    "src/module/launch/MLauncher.lua",
    "src/module/load/MLoad.lua",
];
//发布文件名
const releaseName = "xx";
//发布输出目录
const releaseOutPath = "bin-release/";
//发布任务
gulp.task("release", gulp.series(
    "outGID",
    function (done) {
        release(classReleaseName, `${releaseOutPath}bin/`, ...classURLList);//Class
        release(promiseReleaseName, `${releaseOutPath}bin/`, ...promiseURLList);//Promise
        release(protobufReleaseName, `${releaseOutPath}bin/`, ...protobufURLList);//Protobuf
        release(releaseName, `${releaseOutPath}bin/`, ...urlList);//all for unity
        done();
    }
));
