package haxeui.custom.helpers;

///////////////////////////////////////////////////////////////

class FileSystemHelper {

	public static function getTempDirectory():String {
		var dir:String;
		
		if (SystemHelper.getHostPlatform() == SystemHelper.WINDOWS) dir = Sys.getEnv("temp");
		else {
			dir = Sys.getEnv("TMPDIR");
			if (dir == null) dir = "/tmp";
		}
		
		return dir;
	}
	
}

/*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
 *~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*/

