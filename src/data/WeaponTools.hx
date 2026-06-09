package data;
using StringTools;
using js.lib.RegExp;

class WeaponTools {
	public static function getDieSize(wep:Weapon) {
		var die = wep.damageDie;
		if (die == null) {
			static var rxDieSize = new RegExp("^d(\\d+)");
			var mt = rxDieSize.exec(wep.damage);
			if (mt != null) {
				die = Std.parseInt(mt[1]);
			} else die = Std.parseInt(wep.damage);
			die ??= 0;
			wep.damageDie = die;
		}
		return die;
	}
	public static function hasTraitWhere(wep:Weapon, fun:WeaponTrait->Bool) {
		return (cast wep.traits).find(fun) != null;
	}
	public static inline function hasTrait(wep:Weapon, trait:WeaponTrait) {
		return wep.traits.contains(trait);
	}
	public static function hasDashTrait(wep:Weapon, key:String) {
		return wep.traits.contains(cast key) || hasTraitWhere(wep, (trait) -> trait.startsWith(key));
	}
	public static function getDashString(self:Weapon, key:String) {
		var prefix = '$key-';
		for (trait in self.traits) {
			var traitStr:String = trait;
			if (traitStr.startsWith(prefix)) {
				return traitStr.substring(prefix.length);
			}
		}
		return null;
	}
	public static function getDashInt(self:Weapon, key:String, defValue:Int = -1) {
		var val = getDashString(self, key);
		return val != null ? Std.parseInt(val) ?? defValue : defValue;
		/*var prefix = '$key-';
		for (trait in self.traits) {
			if (trait.startsWith(prefix)) {
				var r = Std.parseInt(trait.substring(prefix.length));
				if (r != null) return r;
			}
		}
		return defValue;*/
	}
	public static function getDashDie(self:Weapon, key:String, defValue:Int = -1) {
		var val = getDashString(self, key);
		return val != null ? Std.parseInt(val.substring(1)) ?? defValue : defValue;
	}
	//
	public static function getDamageTypes(wep:Weapon) {
		var damageTypes = [wep.damageType];
		inline function add(damageType:WeaponDamageType) {
			if (!damageTypes.contains(damageType)) {
				damageTypes.push(damageType);
			}
		}
		if (wep.hasTrait(VersatileB)) add(Bludgeoning);
		if (wep.hasTrait(VersatileP)) add(Piercing);
		if (wep.hasTrait(VersatileS)) add(Slashing);
		if (wep.hasTrait(Modular)) {
			add(Bludgeoning);
			add(Slashing);
			add(Piercing);
		}
		return damageTypes;
	}
	public static function hasDamageType(wep:Weapon, damageType:WeaponDamageType) {
		return getDamageTypes(wep).contains(damageType);
	}
	public static function isTwoHanded(wep:Weapon) {
		return switch (wep.usage) {
			case HeldInOnePlusHands | HeldInTwoHands: true;
			default: false;
		}
	}
	public static function isRanged(wep:Weapon) {
		return wep.range > 0 && !wep.hasTrait(Thrown);
	}
}