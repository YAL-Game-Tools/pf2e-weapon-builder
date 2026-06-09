package data;

enum abstract WeaponDamageType(String) to String {
	var Acid = "acid";
	var Bludgeoning = "bludgeoning";
	var Cold = "cold";
	var Electricity = "electricity";
	var Fire = "fire";
	var Mental = "mental";
	var Piercing = "piercing";
	var Poison = "poison";
	var Slashing = "slashing";
	var Sonic = "sonic";
	var Spirit = "spirit";
	var Vitality = "vitality";
	var Void = "void";
	public function isBasic() {
		return switch (this) {
			case Bludgeoning: true;
			case Piercing: true;
			case Slashing: true;
			default: false;
		}
	}
}