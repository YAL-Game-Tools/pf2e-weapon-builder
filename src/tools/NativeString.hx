package tools;

class NativeString {
	public static function capitalize(s:String) {
		return s.charAt(0).toUpperCase() + s.substring(1);
	}
}