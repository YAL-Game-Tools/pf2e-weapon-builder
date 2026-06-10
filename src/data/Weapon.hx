package data;

import data.*;

@:using(data.WeaponTools)
@:using(data.WeaponWeighter)
typedef Weapon = {
	var name:String;
	var category:WeaponCategory;
	var group:WeaponGroup;
	var level:Int;
	var damage:String;
	var ?damageDie:Int;
	var damageType:WeaponDamageType;
	var range:Int;
	var reload:Int;
	var traits:Array<WeaponTrait>;
	var rarity:WeaponRarity;
	var usage:WeaponUsage;
	var ?isEstimate:Bool;
	var notes:String;
};