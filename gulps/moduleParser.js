const {
    argv, md5, fs,
    gulp, mergeStream, rename, concat, zip, ftp, xlsx, protobuf,
    mkdir, removedir, removefile, copydir, copyFile, renameFile, dateformat,
    parseIdentifiers, parseConfig, parseProto, parseExcel
} = require("./deps");

// 自动加载模块注释
const moduleautoload = "moduleautoload"

/**
 * 解析 lua 模块文件
 * @param {string} outName 输出文件名
 * @param {string} loadPrefix 加载路径
 * @param {string} outPath 输出路径
 * @param {string[]} inPathList 输入路径列表
 */
exports.moduleParser = function (outName, loadPrefix, outPath, ...inPathList) {
    if (!loadPrefix) loadPrefix = "";
    else {
        loadPrefix = loadPrefix.replace(/[\/\\]+/, ".");
        if (/^[\.]$/.test(loadPrefix)) loadPrefix = loadPrefix.substr(1);
        if (!/[\.]$/.test(loadPrefix)) loadPrefix += ".";
    }

    if (!/[\/\\]$/.test(outPath)) outPath += "/";

    let nameMetaMap = {};
    for (let inPath of inPathList) {
        if (!/[\/\\]$/.test(inPath)) inPath += "/";

        let filenameList = fs.readdirSync(inPath)
        for (let fileName of filenameList) {
            let stat = fs.statSync(`${inPath}${fileName}`)
            if (stat.isDirectory()) parseDir(`${inPath}${fileName}/`, `${loadPrefix}${fileName}.`, nameMetaMap);
            else if (stat.isFile() && /\.lua$/.test(fileName)) parseFile(`${inPath}${fileName}`, `${loadPrefix}${fileName.substr(0, fileName.length - 4)}`, nameMetaMap);
        }
    }

    if (!fs.existsSync(outPath)) mkdir(outPath);
    let content = "";
    for (let name in nameMetaMap) {
        content += `require "${nameMetaMap[name]}"\n`;
    }
    for (let name in nameMetaMap) {
        content += `xx.getInstance("${name}")\n`;
    }
    fs.writeFileSync(`${outPath}${outName}.lua`, content);
}

/**
 * 解析目录
 * @param {string} inDir 输入目录
 * @param {string} loadPrefix 加载目录
 * @param {{[name:string]:string}} nameMetaMap 模块名 - 文件加载地址
 */
function parseDir(inDir, loadPrefix, nameMetaMap) {
    let filenameList = fs.readdirSync(inDir)
    for (let fileName of filenameList) {
        let stat = fs.statSync(`${inDir}${fileName}/`)
        if (stat.isDirectory()) parseDir(`${inDir}${fileName}/`, `${loadPrefix}${fileName}.`, nameMetaMap);
        else if (stat.isFile() && /\.lua$/.test(fileName)) parseFile(`${inDir}${fileName}`, `${loadPrefix}${fileName.substr(0, fileName.length - 4)}`, nameMetaMap);
    }
}

/**
 * 解析文件
 * @param {string} fileURL 文件地址
 * @param {string} loadURL 文件加载地址
 * @param {{[name:string]:string}} nameMetaMap 模块名 - 文件加载地址
 */
function parseFile(fileURL, loadURL, nameMetaMap) {
    let content = fs.readFileSync(fileURL, "utf8");
    let index = 0;
    let lines = content.split(/[\r\n]+/g);
    while (index < lines.length) {
        let line = lines[index];
        // 判断是否是自己加载模块注释
        if (/^-{3,}/.test(line)) {
            line = line.substr(3).trim();
            // 判断是否是自己加载模块注释
            if (line == moduleautoload) {
                // 循环查找模块名
                while (++index < lines.length) {
                    line = lines[index].trim();
                    // 注释 或者 空行
                    if (/^-{2,}/.test(line) || 0 == line.length) continue;

                    // = Class("MTimer", Module)
                    /\s*(local )?/

                    let from = line.indexOf("Class(");
                    let end = line.lastIndexOf(")");
                    // 类声明行
                    if (from >= 0 && end > from) {
                        line = line.substring(from + 6, end);
                        end = line.indexOf(",");
                        // 有继承
                        if (end > 0) {
                            line = line.substring(0, end).trim();
                            // 有正确的类名
                            if (/"[0-9a-zA-Z_.]+"/.test(line) || /'[0-9a-zA-Z_.]+'/.test(line)) {
                                nameMetaMap[line.substr(1, line.length - 2).trim()] = loadURL;
                            }
                        }
                    }
                }
            }
        }
        index++;
    }
}