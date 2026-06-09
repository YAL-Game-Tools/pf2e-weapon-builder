package data;

class WeaponTraitTools {
	static var isMelee_map = {
		var m = new Map();
		for (trait in WeaponTraitSets.melee) m[trait] = true;
		m; 
	}
	static var isRanged_map = {
		var m = new Map();
		for (trait in WeaponTraitSets.ranged) m[trait] = true;
		m; 
	}
	static var isEither_map = {
		var m = new Map();
		for (trait in WeaponTraitSets.either) m[trait] = true;
		m; 
	}
	static var isWeapon_map = {
		var m = new Map();
		for (trait in WeaponTraitSets.melee) m[trait] = true;
		for (trait in WeaponTraitSets.ranged) m[trait] = true;
		for (trait in WeaponTraitSets.either) m[trait] = true;
		m; 
	}
	static var isFlavor_map = {
		var m = new Map();
		for (trait in WeaponTraitSets.flavor) m[trait] = true;
		m; 
	}
	public static inline function isWeapon(trait:WeaponTrait) {
		return isWeapon_map.exists(trait);
	}
	public static inline function isFlavor(trait:WeaponTrait) {
		return isFlavor_map.exists(trait);
	}
	public static function toLabel(trait:WeaponTrait) {
		var tuple = WeaponTrait.map[trait];
		return tuple != null ? tuple.label : null;
	}
	public static function isVersatile(trait:WeaponTrait) {
		return switch (trait) {
			case VersatileB: true;
			case VersatileS: true;
			case VersatileP: true;
			case Modular: true;
			default: false;
		}
	}
}