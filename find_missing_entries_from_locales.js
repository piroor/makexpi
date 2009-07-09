// localeの未訳エントリを探す
// 使い方：
//  1. このスクリプトを実行する
//  2. en-USとそれ以外のロケールを含んでいるlocaleフォルダまたはその上位のフォルダを選択する
//  3. en-USにあってそれ以外のロケールで未定義となっているエンティティが列挙される

var separator1 = '--------------------';
var separator2 = '========================================';

function getItemsIn(aFolder, aTask)
{
	var items = aFolder.directoryEntries;
	var results = [];
	while (items.hasMoreElements())
	{
		let item = items.getNext().QueryInterface(Components.interfaces.nsILocalFile);
		if (item.leafName.indexOf('.') == 0) continue;
		results.push(item);
		if (item.isDirectory()) arguments.callee(item, aTask);
		if (aTask) aTask(item);
	}
	return results;
}

function readFrom(aFile)
{
	var fileContents;

	var stream = Components
					.classes['@mozilla.org/network/file-input-stream;1']
					.createInstance(Components.interfaces.nsIFileInputStream);
	try {
		stream.init(aFile, 1, 0, false); // open as "read only"

		var scriptableStream = Components
								.classes['@mozilla.org/scriptableinputstream;1']
								.createInstance(Components.interfaces.nsIScriptableInputStream);
		scriptableStream.init(stream);

		var fileSize = scriptableStream.available();
		fileContents = scriptableStream.read(fileSize);

		scriptableStream.close();
		stream.close();
	}
	catch(e) {
		dump(e+'\n');
		return null;
	}

	return fileContents;
}

function inspectLocale(aLocale) {
	var base;
	var locales = getItemsIn(aLocale, function(aFile) {
			if (aFile.leafName == 'en-US') base = aFile;
		});
	if (!base) return;

	var baseEntries = [];
	getItemsIn(base, function(aFile) {
		if (!/\.dtd$/i.test(aFile.leafName)) return;
		let contents = readFrom(aFile);
		let entries = contents.match(/<!ENTITY\s+[^\s]+/g);
		baseEntries = baseEntries.concat(entries.map(function(aEntry) {
				return aEntry.replace(/<!ENTITY\s+/, '');
			}));
	});
	baseEntries.sort();

	var currentEntries;
	var localeMissingEntries = {};
	locales.forEach(function(aLocale) {
		currentEntries = [];
		getItemsIn(aLocale, function(aFile) {
			if (!/\.dtd$/i.test(aFile.leafName)) return;
			let contents = readFrom(aFile);
			let entries = contents.match(/<!ENTITY\s+[^\s]+/g);
			currentEntries = currentEntries.concat(entries.map(function(aEntry) {
					return aEntry.replace(/<!ENTITY\s+/, '');
				}));
		});
		currentEntries.sort();

		if (currentEntries.join('\n') == baseEntries.join('\n')) return;

		localeMissingEntries[aLocale.leafName] = [];
		baseEntries.forEach(function(aEntry) {
			if (currentEntries.indexOf(aEntry) == -1)
				localeMissingEntries[aLocale.leafName].push(aEntry);
		});
	});

	var result = [];
	for (var i in localeMissingEntries) {
		if (!localeMissingEntries[i].length) continue;
		result.push(
			i+' \u306b\u4ee5\u4e0b\u306e\u30a8\u30f3\u30c8\u30ea\u304c\u3042\u308a\u307e\u305b\u3093\uff1a\n'+
			localeMissingEntries[i].join('\n')
		);
	}

	return result.length ? result.join('\n'+separator1+'\n') : null ;
}



var filePicker = Components
		.classes['@mozilla.org/filepicker;1']
		.createInstance(Components.interfaces.nsIFilePicker);
filePicker.init(
	window,
	'\u8abf\u67fb\u3059\u308b\u30c7\u30a3\u30ec\u30af\u30c8\u30ea\u3092\u9078\u629e\u3057\u3066\u4e0b\u3055\u3044',
	filePicker.modeGetFolder
);
if (filePicker.show() == filePicker.returnCancel) return;

var base = filePicker.file;
var results = [];
var taskForLocale = function(aFolder) {
		if (aFolder.leafName != 'locale') return;
		let result = inspectLocale(aFolder);
		if (result) results.push([aFolder, result]);
	};
taskForLocale(base);
getItemsIn(base, taskForLocale);

var report = (results.length) ?
		results
			.map(function(aResult) {
				return aResult[0].path+' \u306b\u554f\u984c\u304c\u898b\u3064\u304b\u308a\u307e\u3057\u305f\u3002\n'+
						separator1+'\n'+
						aResult[1];
			})
			.join('\n'+separator2+'\n') :
		'\u554f\u984c\u3042\u308a\u307e\u305b\u3093';

alert(report);
