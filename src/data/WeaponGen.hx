package data;
import js.html.Console;
import js.lib.RegExp;
import data.*;

class WeaponGen {
	static function genEnumMembers(weapons:Array<Weapon>, func:(wep:Weapon, add:String->Void)->Void) {
		var outMap = new Map<String, Bool>();
		var out = [];
		var add = (str) -> {
			if (str != null && !outMap.exists(str)) {
				outMap[str] = true;
				out.push(str);
			}
		};
		for (wep in weapons) {
			func(wep, add);
		}
		out.sort((a, b) -> a < b ? -1 : 1);
		var rxCap = new RegExp("(?:^|-)(\\w)", "g");
		return out.map(key -> {
			var name = (cast key).replace(rxCap, (_:String, letter:String) -> {
				return letter.toUpperCase();
			});
			return '\tvar $name = "$key";';
		}).join("\n");
	}
	public static function run(weapons:Array<Weapon>) {
		var ind = 0;
		function run(name, func) {
			var hx = genEnumMembers(weapons, func);
			hx = [
				'enum abstract $name(String) to String {',
				hx,
				'}'
			].join("\n");
			Console.log(++ind, name, hx);
		}
		run("WeaponTrait", (wep, add) -> {
			for (trait in wep.traits) {
				add(trait);
			}
		});
		run("WeaponUsage", (wep, add) -> add(wep.usage));
		run("WeaponDamageType", (wep, add) -> add(wep.damageType));
		run("WeaponCategory", (wep, add) -> add(wep.category));
		run("WeaponGroup", (wep, add) -> add(wep.group));
	}
}