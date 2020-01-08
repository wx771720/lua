// const {
//     argv, md5, fs,
//     gulp, mergeStream, rename, concat, zip, ftp, xlsx, protobuf,
//     mkdir, removedir, removefile, copydir, copyFile, renameFile, dateformat,
//     parseIdentifiers, parseConfig, parseProto, parseExcel
// } = require("./deps");

// npm install --save-dev gulp
// npm install --save-dev merge-stream
// npm install --save-dev gulp-rename
// npm install --save-dev gulp-concat
// npm install --save-dev gulp-zip
// npm install --save-dev gulp-ftp
// npm install --save-dev node-xlsx
// npm install --save-dev protobufjs
//-----------------------------------------------------------------------------
//nodejs 原生工具
//-----------------------------------------------------------------------------
var minimist = require("minimist");
exports.argv = minimist(process.argv.slice(2));

var crypto = require("crypto");
exports.md5 = function (data) { return crypto.createHash("md5").update(data).digest("hex") };

var fs = require("fs");
exports.fs = fs;
//-----------------------------------------------------------------------------
//gulp 插件
//-----------------------------------------------------------------------------
var gulp = require("gulp");
exports.gulp = gulp;
exports.mergeStream = require("merge-stream");

exports.rename = require("gulp-rename");
exports.concat = require("gulp-concat");

exports.zip = require("gulp-zip");
exports.ftp = require("gulp-ftp");

var xlsx = require("node-xlsx");
exports.xlsx = xlsx;
var protobuf = require("protobufjs");
exports.protobuf = protobuf;
//-----------------------------------------------------------------------------
//自定义工具-文件及文件夹处理
//-----------------------------------------------------------------------------
/**
 * 创建目录
 * @param {string} path 目录
 */
var mkdir = function (path) {
    var dirNames = path.split(/[\/\\]+/g);
    var path = "";
    for (var dirName of dirNames) {
        path += `${dirName}/`;
        if (fs.existsSync(path)) continue;
        fs.mkdirSync(path);
    }
};
exports.mkdir = mkdir;



/**
 * 删除文件
 * @param {string} filePath 文件地址
 */
var removefile = function (filePath) { if (fs.existsSync(filePath)) fs.unlinkSync(filePath); }
exports.removefile = removefile;



/**
 * 删除目录
 * @param {string} path 目录
 */
var removedir = function (dir) {
    var reg = /[\/\\]$/;
    if (!reg.test(dir)) dir += "/";

    if (!fs.existsSync(dir)) return;
    removeRecursion(dir, "");
}
function removeRecursion(from, dir) {
    var files = fs.readdirSync(`${from}${dir}`);
    for (var fileIndex = 0; fileIndex < files.length; fileIndex++) {
        var fileName = files[fileIndex];
        if (fs.statSync(`${from}${dir}${fileName}`).isFile()) fs.unlinkSync(`${from}${dir}${fileName}`);
        else removeRecursion(from, `${dir}/${fileName}/`);
    }
    fs.rmdirSync(`${from}${dir}`);
}
exports.removedir = removedir;



/**
 * 拷贝目录
 * @param {string} fromDir 起始目录
 * @param {string} toDir 目标目录
 * @param {string} extensions 需要拷贝的文件后缀，不传入表示拷贝所有文件
 */
var copydir = function (fromDir, toDir, ...extensions) {
    var reg = /[\/\\]$/;
    if (!reg.test(fromDir)) fromDir += "/";
    if (!reg.test(toDir)) toDir += "/";

    copyRecursion(fromDir, toDir, extensions, "");
}
function copyRecursion(from, to, extensions, dir) {
    var files = fs.readdirSync(`${from}${dir}`);
    for (var fileIndex = 0; fileIndex < files.length; fileIndex++) {
        var fileName = files[fileIndex];
        if (fs.statSync(`${from}${dir}${fileName}`).isFile()) {
            var dotIndex = fileName.lastIndexOf(".");
            var extension = dotIndex < 0 ? "" : fileName.substring(dotIndex + 1);
            //不是指定的文件类型
            if (!hasExtension(extension, extensions)) continue;
            //拷贝文件
            var data = fs.readFileSync(`${from}${dir}${fileName}`);
            if (!fs.existsSync(`${to}${dir}`)) mkdir(`${to}${dir}`);
            fs.writeFileSync(`${to}${dir}${fileName}`, data);
        }
        else copyRecursion(from, to, extensions, `${dir}${fileName}/`);
    }
}
function hasExtension(extension, extensions) {
    if (0 == extensions.length) return true;

    for (let extensionLoop of extensions) {
        var index = extensionLoop.lastIndexOf(extension);
        if (index >= 0 && index == extensionLoop.length - extension.length) return true;
    }
    return false;
}
exports.copydir = copydir;



/**
 * 拷贝文件
 * @param {string} fromDir 起始目录
 * @param {string} toDir 目标目录
 * @param {string} filename 文件名
 */
function copyFile(fromDir, toDir, filename) {
    var reg = /[\/\\]$/;
    if (!reg.test(fromDir)) fromDir += "/";
    if (!reg.test(toDir)) toDir += "/";

    if (!fs.existsSync(`${fromDir}${filename}` || fromDir == toDir)) return;
    if (!fs.existsSync(toDir)) mkdir(toDir);
    fs.writeFileSync(`${toDir}${filename}`, fs.readFileSync(`${fromDir}${filename}`));
}
exports.copyFile = copyFile;



/**
 * 修改文件名
 * @param {string} dir 文件所在目录
 * @param {string} fromFilename 源文件名
 * @param {string} toFilename 目标文件名
 */
function renameFile(dir, fromFilename, toFilename) {
    if (fromFilename == toFilename) return;
    if (!/[\/\\]$/.test(dir)) dir += "/";
    if (!fs.existsSync(`${dir}${fromFilename}`)) return;

    if (fs.existsSync(`${dir}${toFilename}`)) fs.unlinkSync(`${dir}${toFilename}`);
    fs.writeFileSync(`${dir}${toFilename}`, fs.readFileSync(`${dir}${fromFilename}`));
    fs.unlinkSync(`${dir}${fromFilename}`);
}
exports.renameFile = renameFile;
//-----------------------------------------------------------------------------
//自定义工具-日期格式化
//-----------------------------------------------------------------------------
/** 日期格式元素集 */
const dateFormatElems = ["Y", "M", "D", "h", "m", "s", "S"];
/** 日期格式元素对应方法名 */
const dateFormatElemFuncs = ["getFullYear", "getMonth", "getDate", "getHours", "getMinutes", "getSeconds", "getMilliseconds"];
/**
 * 格式化日期
 * @param {Date|undefined} date 日期，如果未指定，则格式化当前日期
 * @param {string|undefined} format 格式：Y 表示年，M 表示月，D 表示日，h 表示时，m 表示分，s 表示秒，S 表示毫秒（重复数量表示显示位数），其它字符原样输出，默认：YYYY-MM-DD hh:mm:ss:SSS
 * @returns {string} 格式化后的日期字符串
 */
var dateformat = function (date, format) {
    if (!date) date = new Date();
    if (!format) format = "YYYY-MM-DD hh:mm:ss:SSS";

    for (let index = 0; index < dateFormatElems.length; index++) {
        let elem = dateFormatElems[index];
        let regExpArr = format.match(new RegExp(`${elem}+`, "g"));
        if (!regExpArr) continue;
        for (let regExp of regExpArr) {
            let result = date[dateFormatElemFuncs[index]].apply(date);
            if ("M" === elem) result += 1;
            format = format.replace(regExp, numPad(result, regExp.length));
        }
    }
    return format;
};
/**
 * 将数字转换为指定格式的字符串
 * @param {number} value 数字
 * @param {number|undefined} leftLength 整数部分长度，默认 undefined 不处理，0 表示保留 0 作为整数部分，-1 表示删除整数部分
 * @param {number|undefined} rightLength 小数部分长度，默认 undefined 不处理，0 表示删除小数部分
 * @param {string} pad 填充字符，默认 "0"
 * @param {boolean} thousands 是否插入千位符（不计数），默认 false
 * @returns {string}
 */
function numPad(value, leftLength, rightLength, pad = "0", thousands = false) {
    let left = value.toString();
    if (value < 0) left = left.substr(1);
    let dotIndex = left.indexOf(".");
    let right = dotIndex > 0 ? left.substr(dotIndex + 1) : "";
    if (dotIndex > 0) left = left.substring(0, dotIndex);

    if ("number" == typeof leftLength) {
        if (leftLength > 0) left = strPad(left, leftLength, true, pad);
        else if (0 == leftLength) left = "0";
        else left = "";
    }
    if (thousands && left.length > 3) {
        dotIndex = left.length - 3;
        while (dotIndex > 0) {
            left = `${left.substring(0, dotIndex)},${left.substr(dotIndex)}`;
            dotIndex -= 3;
        }
    }
    if (value < 0 && ("number" != typeof leftLength || leftLength > 0)) left = `-${left}`;
    if ("number" == typeof rightLength) {
        if (rightLength > 0) right = strPad(right, rightLength, false, pad);
        else right = "";
    }
    return `${left}${left.length > 0 && right.length > 0 ? "." : ""}${right}`;
}
/**
 * 将字符串填充到指定长度
 * @param {string} value 源字符串
 * @param {number} length 目标字符串长度
 * @param {boolean} pre 是否在左边填充
 * @param {string} pad 填充字符，默认空格字符
 * @returns {string}
 */
function strPad(value, length, pre = true, pad = " ") {
    if (length <= value.length) return pre ? value.substr(value.length - length) : value.substr(0, length);
    length -= value.length;
    let padStr = pad;
    while (padStr.length < length) { padStr += pad; }
    if (padStr.length > length) padStr = padStr.substr(0, length);
    return pre ? `${padStr}${value}` : `${value}${padStr}`;
}
exports.dateformat = dateformat;
//-----------------------------------------------------------------------------
//自定义工具-解析 gid 格式
//-----------------------------------------------------------------------------
/**
 * 解析 gid 配置文件
 * @param {Array<string>} inPathList 输入路径列表
 * @returns {{[filename:string]:Array<{name,type?,value?,notes:string[]}>}}
 */
exports.parseIdentifiers = function (...inPathList) {
    var nameMetaListMap = {};//gid 元数据
    //解析标识配置
    for (var inPath of inPathList) {
        //标识配置文件目录
        if (!/[\/\\]$/.test(inPath)) inPath += "/";
        parseIdentifiersDir(inPath, nameMetaListMap);
    }
    return nameMetaListMap;
}
/**
 * 将指定目录下标识配置解析为元数据列表，并存入 nameMetaListMap
 * @param {string} path 目录地址
 * @param {{[filename:string]:Array<{name,type?,value?,notes:string[]}>}} nameMetaListMap 标识元数据列表
 */
function parseIdentifiersDir(path, nameMetaListMap) {
    var filenameList = fs.readdirSync(path);
    for (var filename of filenameList) {
        if (fs.statSync(`${path}${filename}`).isDirectory()) parseIdentifiersDir(`${path}${filename}/`, nameMetaListMap);
        else if (new RegExp(`gid$`).test(filename) && fs.statSync(`${path}${filename}`).isFile())
            nameMetaListMap[`${path}${filename}`] = parseIdentifiersFile(fs.readFileSync(`${path}${filename}`, "utf8"));
    }
}
/**
 * 将标识配置文件解析成对应元数据
 * @param {string} gidContent 标识内容
 * @returns {Array<{name,type?,value?,notes:string[]}>} 标识元数据列表
 */
function parseIdentifiersFile(gidContent) {
    var gidMeta = { "name": undefined, "type": undefined, "value": undefined, "notes": [] };
    var gidMetaList = [];
    var lines = gidContent.split(/[\r\n]+/g);
    for (var line of lines) {
        line = line.trim();
        //注释
        if (/^\/\//.test(line)) gidMeta.notes.push(line.replace(/^\/+/, "").trim())
        //内容
        else if (/^[$_A-Za-z0-9]+/.test(line)) {
            //value
            var equalIndex = line.indexOf("=");
            if (equalIndex > 0) {
                gidMeta.value = line.substr(equalIndex + 1).trim();
                line = line.substring(0, equalIndex).trim();
            }
            //type
            var colonIndex = line.indexOf(":");
            if (colonIndex > 0) {
                gidMeta.type = line.substr(colonIndex + 1).trim();
                line = line.substring(0, colonIndex).trim();
            }
            //name
            gidMeta.name = line;
            gidMetaList.push(gidMeta);

            gidMeta = { "name": undefined, "type": undefined, "value": undefined, "notes": [] };
        }
    }
    return gidMetaList;
}
//-----------------------------------------------------------------------------
//自定义工具-配置
//-----------------------------------------------------------------------------
const config_langs = ["zh-cn", "en-us"];
/**
 * 解析配置并整理
 * @param {string} inPathOrList 单个或者多个源目录
 * @param {string} jsonOutPath 配置文件输出目录
 * @param {string} tsOutPath 类文件输出目录
 * @param {string} jsonName 配置文件名
 * @param {string} tsName 配置类文件名
 * @param {string} namespace 配置类命名空间
 * @param {{[key:string]:any}} replaceJson 需要替换的配置
 * @param {Array<string>} langs 语言列表，默认：zh-ch, en-us
 */
exports.parseConfig = function (inPathOrList, jsonOutPath, tsOutPath, jsonName, tsName, namespace, replaceJson, langs) {
    if (!(inPathOrList instanceof Array)) inPathOrList = [inPathOrList];
    if (!/[\/\\]$/.test(jsonOutPath)) jsonOutPath += "/";
    if (!/[\/\\]$/.test(tsOutPath)) tsOutPath += "/";
    if (!jsonName) jsonName = "config";
    if (!tsName) tsName = "GConfig";
    if (!replaceJson) replaceJson = {};
    if (!langs) langs = [];
    for (let lang of config_langs) { if (langs.indexOf(lang) < 0) langs.push(lang); }

    var configMap = {};
    var keysMap = {};
    for (let inPath of inPathOrList) {
        if (!/[\/\\]$/.test(inPath)) inPath += "/";

        var filenameList = fs.readdirSync(inPath);
        for (var filename of filenameList) {
            if (fs.statSync(`${inPath}${filename}`).isDirectory()) parseConfigDir(`${inPath}${filename}/`, configMap, keysMap, langs);
            else if (/\.json$/.test(filename) && fs.statSync(`${inPath}${filename}`).isFile()) parseConfigFile(filename, fs.readFileSync(`${inPath}${filename}`, "utf8"), configMap, keysMap, langs);
        }
    }
    //输出
    if (!fs.existsSync(jsonOutPath)) mkdir(jsonOutPath);
    for (let lang of langs) {
        if (lang in configMap) {
            fs.writeFileSync(`${jsonOutPath}${jsonName}_${lang}.json`, JSON.stringify(configMap[lang]));
            delete configMap[lang];
        }
        else fs.writeFileSync(`${jsonOutPath}${jsonName}_${lang}.json`, JSON.stringify({}));
    }
    fs.writeFileSync(`${jsonOutPath}${jsonName}.json`, JSON.stringify(configMap));

    outConfigEnum(keysMap, tsOutPath, tsName, namespace);
}
/**
 * 输出配置键枚举
 * @param {{[filename:string]:Array<string>}} keysMap 配置键数据
 * @param {string} outPath 输出路径
 * @param {string} name 文件名
 * @param {string} namespace 配置类命名空间
 */
function outConfigEnum(keysMap, outPath, name, namespace) {
    var hasNamespace = "string" == typeof namespace && namespace.trim().length > 0;
    //命名空间段
    var namespaceSegment = "{content}";
    if (hasNamespace) {
        namespaceSegment = `declare namespace ${namespace.trim()} {\n`;
        namespaceSegment += `{content}\n`;
        namespaceSegment += `}`;
    }
    //枚举段
    var indent = hasNamespace ? "\t" : "";
    var enumSegment = "";
    enumSegment += `${indent}/**\n`;
    enumSegment += `${indent} * 配置键枚举（由工具自动生成，请勿手动修改）\n`;
    enumSegment += `${indent} * @author wx771720[outlook.com]\n`;// ${dateformat(undefined, "YYYY-MM-DD hh:mm:ss")}\n`;
    enumSegment += `${indent} */\n`;
    enumSegment += `${indent}${hasNamespace ? "" : "declare "}const enum ${name} {\n`;
    enumSegment += `{content}\n`;
    enumSegment += `${indent}}`;
    //枚举内容
    indent += "\t";
    var enumContent = "";
    var keyMap = {}
    for (let filename in keysMap) {
        enumContent += `${indent}//-----------------------------------------------------------------------------\n`;
        enumContent += `${indent}//${filename}\n`;
        enumContent += `${indent}//-----------------------------------------------------------------------------\n`;

        for (let key of keysMap[filename]) {
            if (key in keyMap) continue;
            keyMap[key] = true;

            enumContent += `${indent}${key} = "${key}",\n`;
        }
    }
    if (/,?\n$/.test(enumContent)) enumContent = enumContent.substr(0, enumContent.length - 2);
    //合并输出
    if (!fs.existsSync(outPath)) mkdir(outPath);
    fs.writeFileSync(`${outPath}${name}.d.ts`, namespaceSegment.replace("{content}", enumSegment.replace("{content}", enumContent)));
}
/**
 * 解析配置目录
 * @param {string} dir 配置目录
 * @param {{[key:string]:any}} configMap 配置数据
 * @param {{[filename:string]:Array<string>}} keysMap 配置键数据
 * @param {Array<string>} langs 语言集
 */
function parseConfigDir(dir, configMap, keysMap, langs) {
    var filenameList = fs.readdirSync(dir);
    for (let filename of filenameList) {
        if (fs.statSync(`${dir}${filename}`).isDirectory()) parseConfigDir(`${dir}${filename}/`, configMap, keysMap, langs);
        else if (/\.json$/.test(filename) && fs.statSync(`${dir}${filename}`).isFile()) parseConfigFile(filename, fs.readFileSync(`${dir}${filename}`, "utf8"), configMap, keysMap, langs);
    }
}
/**
 * 解析配置文件
 * @param {string} filename 配置文件名
 * @param {string} data 配置文件字符串
 * @param {{[key:string]:any}} configMap 配置数据
 * @param {{[filename:string]:Array<string>}} keysMap 配置键数据
 * @param {Array<string>} langs 语言集
 */
function parseConfigFile(filename, data, configMap, keysMap, langs) {
    keysMap[filename] = [];
    var config = JSON.parse(data);
    for (let key in config) {
        //多语言
        if (langs.indexOf(key) >= 0) {
            if (!(key in configMap)) configMap[key] = {};
            for (let langKey in config[key]) {
                configMap[key][langKey] = config[key][langKey];
                //配置键
                keysMap[filename].push(langKey);
            }
        }
        //普通配置
        else {
            configMap[key] = config[key];
            //配置键
            keysMap[filename].push(key);
        }
    }
}
//-----------------------------------------------------------------------------
//自定义工具-Protobuf
//-----------------------------------------------------------------------------
// 第一行表示注释，第二行表示类型，第三行表示字段名
// 真实数据（其它格子中的数据会直接忽略）：
//     列：从第1列开妈连续的 类型和字段名
//     行：从第1行连续非空行
const pbRepeated = "[]";
const pbRepeatedSeparator = ",";//数组分隔符（数组中元素需要使用逗号时，使用双逗号 ,, 表示一个逗号）
const pbRepeatedHolder = "<x-_-x>";//双逗号占位符
//字符串类型
const pbString = "string";
//日期类型
const pbDate = "date";
const pbDateType = "uint64";//日期对应的类型
//布尔类型
const pbBool = "bool";
const pbBoolTrue = "true";//布尔值：true
const pbBoolFalse = "false";//布尔值：false
//proto 可配置的类型列表（不包含 bytes）
const pbTypeList = ["double", "float", "int32", "int64", "uint32", "uint64", "sint32", "sint64", "fixed32", "fixed64", "sfixed32", "sfixed64", pbBool, pbString, pbDate];
//添加可配置类型的数组形式
for (var index = pbTypeList.length - 1; index >= 0; index--) {
    pbTypeList.push(`${pbTypeList[index]}${pbRepeated}`);
}
//类型对应数组后缀
const messageAry = "Ary";
//类型对应数组字段名
const messageAryField = "Data";

/**
 * 解析 excel 表
 * @param {string} packageName 包名
 * @param {string[]} inPathList excel 文件所在路径列表
 * @returns {{"meta":{[name:string]:{names:string[],metaMap:{[name:string]:{"id":number,"repeated":bool,"type":string,"name":string,"note":string}}}},"proto":string,"bytes":{[name:string]:Uint8Array}}}
 */
exports.parseExcel = function (packageName, ...inPathList) {
    var excelObjList = [];
    for (var inPath of inPathList) {
        //标识配置文件目录
        if (!/[\/\\]$/.test(inPath)) inPath += "/";
        parseExcelDir(inPath, excelObjList);
    }

    var meta = getProtoMeta(...excelObjList);
    var proto = getProtoStr(packageName, meta);
    var root = protobuf.parse(proto, { "keepCase": true }).root;
    var bytes = getProtoBytes(root, packageName, meta, ...excelObjList);
    return { "meta": meta, "proto": proto, "bytes": bytes };
}
/**
 * 解析 excel 目录
 * @param {string} inPath excel 目录
 * @param {{"name":string,"data":any[][]}[][]} excelObjList excel 数据列表
 */
function parseExcelDir(inPath, excelObjList) {
    let fileNames = fs.readdirSync(inPath);
    for (let fileName of fileNames) {
        if (fs.statSync(`${inPath}${fileName}`).isDirectory()) {
            parseExcelDir(`${inPath}${fileName}/`);
            continue;
        }
        if (!(/.xlsx$/.test(fileName))) continue;
        var excelObj = xlsx.parse(`${inPath}${fileName}`);
        if (excelObj) excelObjList.push(excelObj);
    }
}
/**
 * 将 excel 转换成 proto 信息
 * @param {{"name":string,"data":any[][]}[][]} excelObjList excel 表读取的数据（第一行表示注释，第二行表示类型，第三行表示字段名）
 * @returns {{[name:string]:{names:string[],metaMap:{[name:string]:{"id":number,"repeated":bool,"type":string,"name":string,"note":string}}}}} 返回 proto 信息
 */
function getProtoMeta(...excelObjList) {
    var protoMeta = {};
    for (var excelObj of excelObjList) {
        for (var table of excelObj) {
            //没有类型行和字段名行
            if (table.data.length < 3) continue;
            var pbNoteRow = table.data[0];//注释行
            var pbTypeNameRow = table.data[1];//类型行
            var pbFieldNameRow = table.data[2];//字段名行

            protoMeta[table.name] = { "names": [], "metaMap": {} };
            for (var colomnIndex = 0; colomnIndex < pbTypeNameRow.length && null != pbTypeNameRow[colomnIndex] && null != pbFieldNameRow[colomnIndex]; colomnIndex++) {
                //类型
                var pbType = pbTypeNameRow[colomnIndex];
                //字段名
                var pbFieldName = pbFieldNameRow[colomnIndex];
                //非法类型
                if (pbTypeList.indexOf(pbType) < 0) {
                    console.error(`${pbFieldName}:${table.name}.${pbType} is not an effective proto type, you can set type like:\n${JSON.stringify(pbTypeList)}`);
                    break;
                }
                //是否数组
                var repeated = pbType.indexOf(pbRepeated) > 0;
                if (repeated) pbType = pbType.replace(pbRepeated, "");
                //注释
                var note = colomnIndex < pbNoteRow.length ? pbNoteRow[colomnIndex] : null;

                protoMeta[table.name]["names"].push(pbFieldName);
                protoMeta[table.name]["metaMap"][pbFieldName] = { "id": colomnIndex + 1, "repeated": repeated, "type": pbType, "name": pbFieldName, "note": note };
            }
        }
    }
    return protoMeta;
}
/**
 * 将 proto 信息转换为 proto 格式字符串
 * @param {string} packageName 包名
 * @param {{[name:string]:{names:string[],metaMap:{[name:string]:{"id":number,"repeated":bool,"type":string,"name":string,"note":string}}}}[]} protoMetaList proto 信息
 * @returns {string}
 */
function getProtoStr(packageName, ...protoMetaList) {
    var protoStr = `syntax = "proto3";\n`;
    if (packageName) protoStr += `package ${packageName};\n`;
    for (var protoMeta of protoMetaList) {
        for (var messageName in protoMeta) {
            var messageMeta = protoMeta[messageName];
            //消息类型
            protoStr += `message ${messageName} {\n`;
            {
                for (var fieldName of messageMeta.names) {
                    var fieldMeta = messageMeta.metaMap[fieldName];

                    var repeatedStr = fieldMeta.repeated ? "repeated " : "";//是否是数组
                    var typeStr = pbDate == fieldMeta.type ? pbDateType : fieldMeta.type;//类型转换
                    var noteStr = fieldMeta.note ? `//${fieldMeta.note}` : "";//注释

                    protoStr += `\t${repeatedStr}${typeStr} ${fieldMeta.name} = ${fieldMeta.id};${noteStr}\n`;
                }
            }
            protoStr += `}\n`;
            //消息数组类型
            protoStr += `message ${messageName}${messageAry} {\n`;
            {
                protoStr += `\trepeated ${messageName} ${messageAryField} = 1;\n`;
            }
            protoStr += `}\n`;
        }
    }
    return protoStr;
}
/**
 * 获取 excel 表格的 pb 编码数据
 * @param {protobuf.Root} root 
 * @param {string} packageName 包名
 * @param {{"name":string,"data":any[][]}[][]} excelObjList excel 表读取的数据（第一行表示注释，第二行表示类型，第三行表示字段名）
 * @param {{[name:string]:{names:string[],metaMap:{[name:string]:{"id":number,"repeated":bool,"type":string,"name":string,"note":string}}}}} protoMeta proto 信息
 * @returns {{[name:string]:Uint8Array}}
 */
function getProtoBytes(root, packageName, protoMeta, ...excelObjList) {
    var bytesMap = {};
    packageName = packageName ? `${packageName}.` : "";
    for (var excelObj of excelObjList) {
        for (var table of excelObj) {
            if (table.data.length < 4) continue;
            var messageMeta = protoMeta[table.name];
            if (!messageMeta) {
                console.log(`can not find message ${table.name}`);
                continue;
            }
            var pbAryType = root.lookupType(`${packageName}${table.name}${messageAry}`);
            if (!pbAryType) {
                console.log(`can not find proto ${packageName}${table.name}${messageAry}`);
                continue;
            }

            var aryObj = {};
            aryObj[messageAryField] = [];
            for (var rowIndex = 3; rowIndex < table.data.length; rowIndex++) {
                var dataRow = table.data[rowIndex];
                if (0 == dataRow.length) break;
                var dataObj = {};
                for (var colomnIndex = 0; colomnIndex < messageMeta.names.length; colomnIndex++) {
                    if (colomnIndex >= dataRow.length) break;
                    var fieldName = messageMeta.names[colomnIndex];
                    var fieldValue = dataRow[colomnIndex];
                    if (null == fieldValue) continue;
                    var fieldMeta = messageMeta.metaMap[fieldName];
                    fieldValue = getProtoValue(fieldMeta, fieldValue);
                    if (null == fieldValue) continue;
                    dataObj[fieldName] = fieldValue;
                }

                aryObj[messageAryField].push(dataObj);
            }

            bytesMap[table.name] = pbAryType.encode(aryObj).finish();
        }
    }
    return bytesMap;
}
/**
 * 转换 proto 数据
 * @param {{"id":number,"repeated":bool,"type":string,"name":string,"note":string}} meta 元数据
 * @param {any} value 数据
 */
function getProtoValue(meta, value) {
    var valueType = typeof value;
    if (meta.repeated) {
        if ("string" != valueType) value = `${value}`;
        value = value.replace(`${pbRepeatedSeparator}${pbRepeatedSeparator}`, pbRepeatedHolder);
        var valueStrs = value.split(pbRepeatedSeparator);

        var valueMeta = {};
        for (var fieldName in meta) { valueMeta[fieldName] = meta[fieldName]; }
        valueMeta.repeated = false;

        var values = [];
        for (var valueStr of valueStrs) { values.push(getProtoValue(valueMeta, valueStr.replace(pbRepeatedHolder, pbRepeatedSeparator))); }
        return values;
    }
    else {
        switch (meta.type) {
            case pbBool:
                switch (valueType) {
                    case "boolean":
                        return value;
                    case "string":
                        return value.toLowerCase() == pbBoolTrue;
                    case "number":
                        return 0 != value;
                }
                break;
            case pbString:
                switch (valueType) {
                    case "boolean":
                        return value ? pbBoolTrue : pbBoolFalse;
                    case "string":
                        return value;
                    case "number":
                        return value.toString();
                }
                break;
            case pbDate:
                switch (valueType) {
                    case "string":
                        return new Date(value).getTime();
                    case "number":
                        return value;
                }
                break;
            case "double": case "float":
                switch (valueType) {
                    case "boolean":
                        return value ? 1 : 0;
                    case "string":
                        return parseFloat(value);
                    case "number":
                        return value;
                }
                break;
            case "int32": case "int64": case "uint32": case "uint64": case "sint32": case "sint64": case "fixed32": case "fixed64": case "sfixed32": case "sfixed64":
                switch (valueType) {
                    case "boolean":
                        return value ? 1 : 0;
                    case "string":
                        return parseInt(value);
                    case "number":
                        return value;
                }
                break;
        }
    }
}
//-----------------------------------------------------------------------------
//自定义工具-Protobuf
//-----------------------------------------------------------------------------
/**
 * 解析 protobuf 文件
 * @param {Array<string>} inPathList 输入路径列表
 * @returns {{[packageName:string]:{enumMap:{[enumName:string]:{notes:string[],meta:{[name:string]:{notes:string[],value:number}}}},messageMap:{[messageName:string]:{notes:string[],meta:{[name:string]:{notes:string[],required:boolean,optional:boolean,repeated:boolean,type:string,id:number,optionMap:{[option:string]:string}}}}}}}}
 */
exports.parseProto = function (...inPathList) {
    let packageMetaMap = {};//protobuf 元数据
    //解析标识配置
    for (var inPath of inPathList) {
        //标识配置文件目录
        if (!/[\/\\]$/.test(inPath)) inPath += "/";
        parseProtobufDir(inPath, packageMetaMap);
    }
    return packageMetaMap;
}

/**
 * 解析 proto 文件目录
 * @param {string} inPath proto 文件目录
 * @param {{[packageName:string]:{enumMap:{[enumName:string]:{notes:string[],meta:{[name:string]:{notes:string[],value:number}}}},messageMap:{[messageName:string]:{notes:string[],meta:{[name:string]:{notes:string[],required:boolean,optional:boolean,repeated:boolean,type:string,id:number,optionMap:{[option:string]:string}}}}}}}} packageMetaMap 输出配置
 */
function parseProtobufDir(inPath, packageMetaMap) {
    let fileNames = fs.readdirSync(inPath);
    for (let fileName of fileNames) {
        if (fs.statSync(`${inPath}${fileName}`).isDirectory()) {
            parseProtobufDir(`${inPath}${fileName}/`, packageMetaMap);
            continue;
        }
        if (!(/.proto$/.test(fileName))) continue;
        // 包名
        let packageName = undefined;
        // 枚举
        let enumMap = {};
        // 消息
        let messageMap = {};

        let data = fs.readFileSync(`${inPath}${fileName}`, "utf8");
        // let lines = data.replace(/ {2,}/g, " ").split(/[\r\n]+/);
        let lines = data.split(/[\r\n]+/);
        // 解析文件
        for (let index = 0; index < lines.length; index++) {
            // let line = lines[index].replace(";", "").trim();
            let line = lines[index].trim();
            // 包名
            if (/^package /.test(line)) {
                if (packageName) console.error(`there are multiple package define in ${inPath}${fileName}`);
                let endIndex = line.indexOf(line_end_char, "package ".length);
                if (endIndex < 0) endIndex = line.length - 1;
                packageName = line.substring("package ".length, endIndex).trim();
            }
            // 枚举
            else if (/^enum /.test(line)) {
                let enumResult = parseEnum(lines, index);
                if (enumResult.enumName) {
                    index = enumResult.nextIndex;
                    if (enumMap[enumResult.enumName]) console.error(`there are multiple enum defined : ${enumResult.enumName}`);
                    enumMap[enumResult.enumName] = { notes: enumResult.notes, meta: enumResult.meta };
                }
                else console.error(`parse enum error of ${line} in ${inPath}${fileName}`);
            }
            // 消息
            else if (/^message /.test(line)) {
                let messageResult = parseMessage(lines, index, enumMap, messageMap);
                if (messageResult.messageName) {
                    index = messageResult.nextIndex;
                    if (messageMap[messageResult.messageName]) console.error(`there are multiple message defined : ${messageResult.messageName}`);
                    messageMap[messageResult.messageName] = { notes: messageResult.notes, meta: messageResult.meta };
                }
                else console.error(`parse message error of ${line} in ${inPath}${fileName}`);
            }
        }
        // 缓存枚举
        if (!packageMetaMap[packageName]) packageMetaMap[packageName] = { enumMap: {}, messageMap: {} };
        for (let name in enumMap) {
            if (packageMetaMap[packageName].enumMap[name]) console.error(`there are multiple enum defined : ${name}`);
            packageMetaMap[packageName].enumMap[name] = enumMap[name];
        }
        // 缓存消息
        for (let name in messageMap) {
            if (packageMetaMap[packageName].messageMap[name]) console.error(`there are multiple message defined : ${name}`);
            packageMetaMap[packageName].messageMap[name] = messageMap[name];
        }
    }
}

// 元数据分隔符
const meta_seperator = " ";
// 字段分隔符
const field_seperator = "=";
// 行结束符
const line_end_char = ";";
// 内容开始符
const content_begin_char = "{";
// 内容结束符
const content_end_char = "}";
// 选项开始符
const option_begin_char = "[";
// 选项结束符
const option_end_char = "]";
// 选项分隔符
const option_seperator = ",";
/**
 * 解析枚举
 * @param {string[]} lines 文件行列表
 * @param {number} index 当前行索引
 * @returns {{nextIndex:number,enumName?:string,notes:string[],meta?:{[name:string]:{notes:string[],value:number}}}} 当前行索引，枚举名，枚举元数据
 */
function parseEnum(lines, index) {
    let result = { nextIndex: index, enumName: undefined, notes: [], meta: {} };
    let line = lines[index];
    // 名字
    let beginIndex = line.indexOf("enum ", 0);
    if (beginIndex < 0) return result;
    beginIndex += "enum ".length;
    let endIndex = line.indexOf(meta_seperator, beginIndex);
    if (endIndex < 0) endIndex = line.indexOf(content_begin_char, beginIndex);
    if (endIndex < 0) endIndex = line.length;
    result.enumName = line.substring(beginIndex, endIndex).trim();
    // 查找注释
    let note;
    {
        // 查找行内注释
        beginIndex = line.indexOf("//", endIndex + 1);
        if (beginIndex > 0) {
            note = line.substring(beginIndex).replace(/^\/+/, "").trim();
            if (note.length > 0) result.notes.unshift(note);
            // 更新行
            line = line.substring(0, beginIndex);
        }
        // 查找行上注释
        let noteIndex = index - 1;
        while (noteIndex >= 0) {
            let noteLine = lines[noteIndex].trimLeft();
            if (/^\/{2,}/.test(noteLine)) {
                note = noteLine.replace(/^\/+/, "").trim();
                if (note.length > 0) result.notes.unshift(note);
                noteIndex--;
            }
            else break;
        }
    }
    // 枚举结束
    if (line.indexOf(content_end_char) >= 0) return result;
    // 字段
    index++;
    while (index < lines.length) {
        line = lines[index].trimLeft();
        // 注释行
        if (/^\/{2,}/.test(line)) {
            index++;
            continue;
        }
        // 字段行
        endIndex = line.indexOf(field_seperator, 0);
        if (endIndex > 0) {
            let fieldMap = { notes: [], value: 0 };
            // 查找注释
            {
                // 查找行内注释
                beginIndex = line.indexOf("//", endIndex + 1);
                if (beginIndex > 0) {
                    note = line.substring(beginIndex).replace(/^\/+/, "").trim();
                    if (note.length > 0) fieldMap.notes.unshift(note);
                    // 更新行
                    line = line.substring(0, beginIndex);
                }
                // 查找行上注释
                let noteIndex = index - 1;
                while (noteIndex >= 0) {
                    let noteLine = lines[noteIndex].trimLeft();
                    if (/^\/{2,}/.test(noteLine)) {
                        note = noteLine.replace(/^\/+/, "").trim();
                        if (note.length > 0) fieldMap.notes.unshift(note);
                        noteIndex--;
                    }
                    else break;
                }
            }
            // 字段名
            let fieldName = line.substring(0, endIndex).trim();
            // 字段值
            beginIndex = endIndex + 1;
            endIndex = line.indexOf(line_end_char, beginIndex);
            if (endIndex < 0) endIndex = line.length;
            fieldMap.value = parseInt(line.substring(beginIndex, endIndex));

            result.meta[fieldName] = fieldMap;
        }
        // 枚举结束
        if (line.indexOf(content_end_char) >= 0) {
            result.nextIndex = index;
            return result;
        }

        index++;
    }
    return result;
}
/**
 * 解析消息
 * @param {string[]} lines 文件行列表
 * @param {number} index 当前行索引
 * @param {{[enumName:string]:{notes:string[],meta:{[fieldName:string]:{notes:string[],value:number}}}}} enumMap 枚举元数据
 * @param {{[messageName:string]:{notes:string[],meta:{[fieldName:string]:{notes:string[],required:boolean,optional:boolean,repeated:boolean,type:string,id:number,optionMap:{[option:string]:string}}}}}} messageMap 消息元数据
 * @returns {{nextIndex:number,messageName?:string,notes:string[],meta:{[name:string]:{notes:string[],required:boolean,optional:boolean,repeated:boolean,type:string,id:number,optionMap:{[option:string]:string}}}}}
 * 当前行索引，消息名，注释，元数据{字段名 - 注释，required, optional, repeated, 类型，id，选项{选项-值}}
 */
function parseMessage(lines, index, enumMap, messageMap) {
    let result = { nextIndex: index, messageName: undefined, notes: [], meta: {} };
    let line = lines[index];
    // 名字
    let beginIndex = line.indexOf("message ", 0);
    if (beginIndex < 0) return result;
    beginIndex += "message ".length;
    let endIndex = line.indexOf(meta_seperator, beginIndex);
    if (endIndex < 0) endIndex = line.indexOf(content_begin_char, beginIndex);
    if (endIndex < 0) endIndex = line.length;
    result.messageName = line.substring(beginIndex, endIndex).trim();
    // 查找注释
    let note;
    {
        // 查找行内注释
        beginIndex = line.indexOf("//", endIndex + 1);
        if (beginIndex > 0) {
            note = line.substring(beginIndex).replace(/^\/+/, "").trim();
            if (note.length > 0) result.notes.unshift(note);
            // 更新行
            line = line.substring(0, beginIndex);
        }
        // 查找行上注释
        let noteIndex = index - 1;
        while (noteIndex >= 0) {
            let noteLine = lines[noteIndex].trimLeft();
            if (/^\/{2,}/.test(noteLine)) {
                note = noteLine.replace(/^\/+/, "").trim();
                if (note.length > 0) result.notes.unshift(note);
                noteIndex--;
            }
            else break;
        }
    }
    // 消息结束
    if (line.indexOf(content_end_char) >= 0) return result;
    // 字段
    index++;
    while (index < lines.length) {
        line = lines[index].trimLeft();
        // 注释行
        if (/^\/{2,}/.test(line)) {
            index++;
            continue;
        }
        // 消息行
        if (/^message /.test(line)) {
            console.log(`inner message in ${result.messageName}`);
            let innerResult = parseMessage(lines, index, enumMap, messageMap);
            if (innerResult.messageName) {
                index = innerResult.nextIndex;
                messageMap[innerResult.messageName] = { notes: innerResult.notes, meta: innerResult.meta };
            }
            index++;
            continue;
        }
        // 枚举行
        if (/^enum /.test(line)) {
            console.log(`inner enum in ${result.messageName}`);
            let innerResult = parseEnum(lines, index);
            if (innerResult.enumName) {
                index = innerResult.nextIndex;
                enumMap[innerResult.enumName] = { notes: innerResult.notes, meta: innerResult.meta };
            }
            index++;
            continue;
        }
        // 字段行
        endIndex = line.indexOf(field_seperator, 0);
        if (endIndex > 0) {
            let fieldMap = { notes: [], required: false, optional: false, repeated: false, type: undefined, id: 0, optionMap: {} };
            // 查找注释
            {
                // 查找行内注释
                beginIndex = line.indexOf("//", endIndex + 1);
                if (beginIndex > 0) {
                    note = line.substring(beginIndex).replace(/^\/+/, "").trim();
                    if (note.length > 0) fieldMap.notes.unshift(note);
                    // 更新行
                    line = line.substring(0, beginIndex);
                }
                // 查找行上注释
                let noteIndex = index - 1;
                while (noteIndex >= 0) {
                    let noteLine = lines[noteIndex].trimLeft();
                    if (/^\/{2,}/.test(noteLine)) {
                        note = noteLine.replace(/^\/+/, "").trim();
                        if (note.length > 0) fieldMap.notes.unshift(note);
                        noteIndex--;
                    }
                    else break;
                }
            }
            // 声明部分
            let before = line.substring(0, endIndex).trim();
            // 赋值部分
            let after = line.substring(endIndex + 1).trim();

            let words = before.split(meta_seperator);
            // 字段名
            let fieldName = words[words.length - 1];
            for (let i = 0; i < words.length - 1; i++) {
                let word = words[i];
                if (0 == word.length) continue;
                switch (word) {
                    case "required":
                        fieldMap.required = true;
                        break;
                    case "optional":
                        fieldMap.optional = true;
                        break;
                    case "repeated":
                        fieldMap.repeated = true;
                        break;
                    case "double": case "float": case "int32": case "int64": case "uint32": case "uint64": case "sint32": case "sint64": case "fixed32": case "fixed64": case "sfixed32": case "sfixed64": case "bool": case "string": case "bytes":
                    default:
                        if (fieldMap.type) console.error(`message field parse error : ${result.messageName}.${fieldName}`);
                        fieldMap.type = word;
                        // map 类型特殊处理
                        if (0 == word.indexOf("map") && word.indexOf(">") < 0) {
                            for (i++; i < words.length - 1; i++) {
                                word = words[i];
                                fieldMap.type += word;
                                if (word.indexOf(">") >= 0) break;
                            }
                        }
                        break;
                }
            }
            // 查找选项
            beginIndex = after.indexOf(option_begin_char);
            if (beginIndex > 0) {
                endIndex = after.indexOf(option_end_char, beginIndex + 1);
                if (endIndex > beginIndex) {
                    // 解析选项
                    let optionStrs = after.substring(beginIndex + 1, endIndex).split(option_seperator);
                    console.log(`options[${optionStrs}] in ${result.messageName}.${fieldName}`);
                    for (let optionStr of optionStrs) {
                        let optionIndex = optionStr.indexOf(field_seperator);
                        if (optionIndex > 0) {
                            let optionKey = optionStr.substring(0, optionIndex).trim();
                            let optionValue = optionStr.substring(optionIndex + 1).trim();
                            if (0 == optionKey.length || 0 == optionValue.length) console.error(`message field option parse error : ${result.messageName}.${fieldName}`);
                            fieldMap.optionMap[optionKey] = optionValue;
                        }
                    }
                    // 更新行
                    after = after.substring(0, beginIndex);
                }
            }
            // id
            endIndex = after.indexOf(line_end_char);
            if (endIndex < 0) endIndex = after.length;
            fieldMap.id = parseInt(after.substring(0, endIndex).trim());

            result.meta[fieldName] = fieldMap;
        }
        // 消息结束
        if (line.indexOf(content_end_char) >= 0) {
            result.nextIndex = index;
            return result;
        }

        index++;
    }
    return result;
}
