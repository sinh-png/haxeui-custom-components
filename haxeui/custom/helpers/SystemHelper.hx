package haxeui.custom.helpers;

///////////////////////////////////////////////////////////////

class SystemHelper {
	
	public static inline var WINDOWS:String = "WINDOWS";
	public static inline var LINUX:String = "LINUX";
	public static inline var MAC:String = "MAC";
	
	private static var _hostPlatform:String;
	
	///////////////////////////////////////////////////////////////

	public static function getHostPlatform():String {
		if (_hostPlatform != null) {
			if (new EReg ("window", "i").match(Sys.systemName())) _hostPlatform = WINDOWS;
			else if (new EReg ("linux", "i").match(Sys.systemName())) _hostPlatform = LINUX;
			else if (new EReg ("mac", "i").match(Sys.systemName())) _hostPlatform = MAC;
		}
		
		return _hostPlatform;
	}
	
}

/*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
 *~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*/