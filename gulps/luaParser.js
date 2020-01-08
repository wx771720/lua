const {
    argv, md5, fs,
    gulp, mergeStream, rename, concat, zip, ftp, xlsx, protobuf,
    mkdir, removedir, removefile, copydir, copyFile, renameFile, dateformat,
    parseIdentifiers, parseConfig, parseProto, parseExcel
} = require("./deps");

const coreLuaUrlList = [
    "src/core/xx.lua",
    "src/core/Extensions.lua",
    "src/core/Class.lua"
];

/**
 * 解析 lua 文件
 * @param {string[]} luaUrlList lua 文件地址列表
 * @returns {string[]}} 代码行列表
 */
exports.luaParser = function (...luaUrlList) {
    let lines = [];
    //核心 lua
    for (let luaUrl of coreLuaUrlList) {
        if (/\.lua$/.test(luaUrl)) {
            let fileLines = parseFile(luaUrl);
            for (let line of fileLines) { lines.push(line); }
        }
    }
    //其它 lua
    for (let luaUrl of luaUrlList) {
        if (/\.lua$/.test(luaUrl) && coreLuaUrlList.indexOf(luaUrl) < 0) {
            let fileLines = parseFile(luaUrl);
            for (let line of fileLines) { lines.push(line); }
        }
    }
    return lines;
}

/**
 * 解析 lua 文件
 * @param {string} url lua 文件地址
 * @returns {string[]}
 */
function parseFile(url) {
    let lines = [];
    let content = fs.readFileSync(url, "utf8");
    let fileLines = content.split(/[\r\n]+/g);

    for (let lineIndex = 0; lineIndex < fileLines.length; lineIndex++) {
        let line = fileLines[lineIndex].trimRight();
        //空行
        if (0 == line.length) continue;
        //注释行（--），但不是注解行（---）
        if ((/^\s*-{2}/.test(line) && !/^\s*-{3}/.test(line))) continue;
        //依赖行
        if (/^(local\s+[0-9a-zA-Z_]+\s*=\s*)?require/.test(line)) {
            for (let index = lines.length - 1; index >= 0; index--) {
                let metaLine = lines[index];
                if (/^-{2,}/.test(metaLine)) lines.pop();
                else break;
            }
            continue;
        }
        //结束代码
        if (/^return /.test(line)) break;
        //普通代码
        lines.push(line);
    }
    return lines;
}