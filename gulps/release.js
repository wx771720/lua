const {
    argv, md5, fs,
    gulp, mergeStream, rename, concat, zip, ftp, xlsx, protobuf,
    mkdir, removedir, removefile, copydir, copyFile, renameFile, dateformat,
    parseIdentifiers, parseConfig, parseProto, parseExcel
} = require("./deps");

const { luaParser } = require("./luaParser");

/**
 * 发布
 * @param {string|undefined} name 输出文件名，默认 xx
 * @param {string|undefined} outPath 输出目录，默认 bin-release
 * @param {string[]} luaUrlList 需要导出的 lua 文件名地址列表
 */
exports.release = function (name, outPath, ...luaUrlList) {
    if (!name) name = "xx";

    if (!outPath) outPath = "bin-release/";
    else if (!/[\/\\]$/.test(outPath)) outPath += "/";

    let lines = luaParser(...luaUrlList);

    if (!fs.existsSync(outPath)) mkdir(outPath);
    // 正常，包含注解（---）
    fs.writeFileSync(`${outPath}${name}.lua`, lines.join("\n") + "\n");
    // 压缩（去掉注释）
    let minContent = "";
    for (let line of lines) {
        if (!/^-{2}/.test(line)) minContent += `${line}\n`;
    }
    fs.writeFileSync(`${outPath}${name}_min.lua`, minContent);
}