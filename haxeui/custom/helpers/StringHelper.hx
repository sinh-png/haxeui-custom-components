package haxeui.custom.helpers;

///////////////////////////////////////////////////////////////

class StringHelper {

	public static function compare(a:String, b:String, case_sensitive:Bool = true):Int {
		if (!case_sensitive) {
			a = a.toLowerCase();
			b = b.toLowerCase();
		}
		
		if (a < b) return -1;
		if (a > b) return 1;
		return 0;
	}
	
	public static function equal(a:String, b:String, case_sensitive:Bool = true):Bool {
		if (compare(a, b, case_sensitive) == 0) return true;
		return false;
	}
	
}

/*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
 *~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*/