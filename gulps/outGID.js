const {
    argv, md5, fs,
    gulp, mergeStream, rename, concat, zip, ftp, xlsx, protobuf,
    mkdir, removedir, removefile, copydir, copyFile, renameFile, dateformat,
    parseIdentifiers, parseConfig, parseProto, parseExcel
} = require("./deps");

/**
 * @param {string|undefined} name 输出文件名，默认 GIdentifiers
 * @param {number|undefined} indexBegin 第一个开始值，默认 770000
 * @param {string} outPath 输出目录
 * @param {Array<string>} inPathList 输入目录列表
 */
exports.outGID = function (name, indexBegin, outPath, ...inPathList) {
    //输出文件名
    if ("string" != typeof name) name = "GIdentifiers";
    //gid 第一个开始值
    if ("number" != typeof indexBegin || NaN == indexBegin) indexBegin = 770000;
    //输出目录
    if (!outPath) outPath = "/";
    else if (!/[\/\\]$/.test(outPath)) outPath += "/";

    //gid 元数据
    let nameMetaListMap = parseIdentifiers(...inPathList);
    //输出
    output(outPath, name, indexBegin, nameMetaListMap);
}
/**
 * 输出标识枚举
 * @param {string} path 输出目录
 * @param {{[filename:string]:Array<{name,type?,value?,notes:string[]}>}} nameMetaListMap 
 */
function output(path, name, indexBegin, nameMetaListMap) {
    //内容
    var content = ``;
    content += `---GID 类（由工具自动生成，请勿手动修改）\n`;
    content += `---@class ${name} author wx771720[outlook.com]\n`;// ${dateformat(undefined, "YYYY-MM-DD hh:mm:ss")}\n`;
    content += `${name} = ${name} or {}\n`;
    for (var filename in nameMetaListMap) {
        var gidMetaList = nameMetaListMap[filename];
        if (0 == gidMetaList.length) continue;

        content += `-- -----------------------------------------------------------------------------\n`;
        content += `-- ${filename}\n`;
        content += `-- -----------------------------------------------------------------------------\n`;

        for (var gidMeta of gidMetaList) {
            if (gidMeta.notes.length > 0) {
                for (var note of gidMeta.notes) {
                    content += `---${note}\n`;
                }
            }
            content += `${name}.${gidMeta.name} = ${gidMeta.value ? gidMeta.value : indexBegin++}\n`;
        }
    }
    content += `\n`;
    //合并输出
    if (!fs.existsSync(path)) mkdir(path);
    fs.writeFileSync(`${path}${name}.lua`, content);
};