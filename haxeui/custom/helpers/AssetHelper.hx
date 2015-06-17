package haxeui.custom.helpers;

#if !macro

import openfl.Assets;
import openfl.display.BitmapData;
import openfl.Lib;
import openfl.media.Sound;
import openfl.text.Font;

///////////////////////////////////////////////////////////////

class AssetHelper {

	inline static var tempAssetPrefix:String = "temp";
	inline static var separator:String = ":::";
	
	static var _createdAssetCount:Int = 0;
	
	///////////////////////////////////////////////////////////////
	
	public static function cacheTempAsset(asset:Dynamic):String {
		_createdAssetCount++;
		var id:String = null;
		
		if (Std.is(asset, BitmapData)) {
			id = tempAssetPrefix + separator + "BitmapData" + separator + _createdAssetCount;
			Assets.cache.setBitmapData(id, asset);
		} else if (Std.is(asset, Font)) {
			id = tempAssetPrefix + separator + "Font" + separator + _createdAssetCount;
			Assets.cache.setFont(id, asset);
		} else if (Std.is(asset, Sound)) {
			id = tempAssetPrefix + separator + "Sound" + separator + _createdAssetCount;
			Assets.cache.setSound(id, asset);
		}

		return id;
	}
	
	public static function uncacheTempAsset(id:String):Bool {
		var tokens = id.split(separator);
		
		if (tokens[0] == tempAssetPrefix) {
			switch(tokens[1]) {
				case "BitmapData": return Assets.cache.removeBitmapData(id);
				case "Font": return Assets.cache.removeFont(id);
				case "Sound": return Assets.cache.removeSound(id);
			}
		}
		
		return false;
	}
	
}

/*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
 *~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*/

//@:build(haxeui.custom.helpers.AssetHelper.AssetPathBuilder.buildFileReferences("assets/img", true))
//class IMG {}

@:build(haxeui.custom.helpers.AssetHelper.AssetPathBuilder.buildFileReferences("data/layouts", true))
class UIL { }

@:build(haxeui.custom.helpers.AssetHelper.AssetPathBuilder.buildFileReferences("styles/gradient/custom", true))
class UII {}

/*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
 *~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*/

#else
 
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
using StringTools;

/**
 * Copied from HaxeFlixel - flixel.system.FlxAssets
 */

class AssetPathBuilder {

	macro public static function buildFileReferences(directory:String = "assets/", subDirectories:Bool = false, ?filterExtensions:Array<String>):Array<Field> {
		if (!directory.endsWith("/"))
			directory += "/";
			
		var fileReferences:Array<FileReference> = getFileReferences(directory, subDirectories, filterExtensions);
		
		var fields:Array<Field> = Context.getBuildFields();
			
		for (fileRef in fileReferences) {
			// create new field based on file references!
			fields.push({
				name: fileRef.name,
				doc: fileRef.documentation,
				access: [Access.APublic, Access.AStatic, Access.AInline],
				kind: FieldType.FVar(macro:String, macro $v{ fileRef.value }),
				pos: Context.currentPos()
			});
		}
		return fields;
	}
	
	private static function getFileReferences(directory:String, subDirectories:Bool = false, ?filterExtensions:Array<String>):Array<FileReference> {
		var fileReferences:Array<FileReference> = [];
		var resolvedPath = #if ios Context.resolvePath(directory) #else directory #end;
		var directoryInfo = FileSystem.readDirectory(resolvedPath);
		for (name in directoryInfo) {
			if (!FileSystem.isDirectory(resolvedPath + name)) {
				// ignore invisible files
				if (name.startsWith("."))
					continue;
				
				if (filterExtensions != null) {
					var extension:String = name.split(".")[1]; // get the string after the dot
					if (filterExtensions.indexOf(extension) == -1)
						continue;
				}
				
				fileReferences.push(new FileReference(directory + name));
			}
			else if (subDirectories) {
				fileReferences = fileReferences.concat(getFileReferences(directory + name + "/", true, filterExtensions));
			}
		}
		
		return fileReferences;
	}

}

private class FileReference {
	public var name:String;
	public var value:String;
	public var documentation:String;
	
	public function new(value:String) {
		this.value = value;
		
		this.name = value.split("-").join("_").split(".").join("__");
		var split:Array<String> = name.split("/");
		this.name = split[split.length - 1];
		
		this.documentation = "\"" + value + "\" (auto generated).";
	}
}

#end