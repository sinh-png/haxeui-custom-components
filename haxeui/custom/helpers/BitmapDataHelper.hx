package haxeui.custom.helpers;

import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.utils.ByteArray;

#if desktop
import sys.FileSystem;
#end

///////////////////////////////////////////////////////////////

class BitmapDataHelper {

	public static function createResizedBitmapData(source:BitmapData, scale_x:Float, scale_y:Float):BitmapData {
		var bmd = new BitmapData(Std.int(source.width * scale_x), Std.int(source.height * scale_y), source.transparent, 0x0);
		var matrix = new Matrix();
		matrix.scale(scale_x, scale_y);
		bmd.draw(source, matrix);
		return bmd;
	}
	
	#if desktop
	public static function loadFromFiles(files:Array<String>):Array<BitmapData> {
		var bmds = new Array<BitmapData>();
		for (file in files) {
			if (!FileSystem.exists(file)) bmds.push(null);
			else {
				var bytes = ByteArray.readFile(file);
				var bmd = BitmapData.loadFromBytes(bytes);
				bmds.push(bmd.width == 0 ? null : bmd);
			}
		}
		return bmds;
	}
	#end
	
}

/*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
 *~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*/