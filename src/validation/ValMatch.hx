package validation;

import data.Weapon;
import data.WeaponDamageType;

/**
	Some weapons are pretty close to other weapons and that's fine,
	but you might want to know.
**/
class ValMatch {
	//
	static function compareDamageTypes(a:Array<WeaponDamageType>, b:Array<WeaponDamageType>) {
		if (a.length != b.length) return false;
		for (damageType in a) {
			if (!b.contains(damageType)) return false;
		}
		return true;
	}
	static function printDamageTypes(damageTypes:Array<WeaponDamageType>) {
		if (damageTypes.length == 0) return "?";
		if (damageTypes.length == 1) return damageTypes[0].capitalize();
		if (damageTypes.length == 2
			&& damageTypes[0].isBasic()
			&& damageTypes[1].isBasic()
		) return "Versatile " + damageTypes.map(t -> (t:String).charAt(0).capitalize()).join("/");
		if (damageTypes.length == 3
			&& damageTypes.contains(Bludgeoning)
			&& damageTypes.contains(Piercing)
			&& damageTypes.contains(Slashing)
		) return "Modular";
		return damageTypes.map(t -> t.capitalize()).join("/");
	}
	static function hasTraits(a:Weapon, b:Weapon) {
		for (trait in a.traits) if (trait.isWeapon()) {
			if (trait.isVersatile()) {
				if (b.traits.find(t -> t.isVersatile()) == null) {
					return false;
				}
			} else if (!b.traits.contains(trait)) {
				return false;
			}
		}
		return true;
	}
	//
	public static function init() {
		add("Match", (wep, out) -> {
			var weapons = Validators.weapons;
			var wepDie = wep.getDieSize();
			//
			var wepDamageTypes = wep.getDamageTypes();
			var wepDamageTypesText = printDamageTypes(wepDamageTypes);
			//
			inline function cmp<T>(a:T, b:T):T {
				return a != b ? a : null;
			}
			for (ref in weapons) {
				/*
				var with = [];
				for (trait in wep.traits) if (!trait.isFlavor()) {
					if (!ref.traits.contains(trait)) with.push(trait);
				}
				var without = [];
				for (trait in ref.traits) if (!trait.isFlavor()) {
					if (!ref.traits.contains(trait)) without.push(trait);
				}
				var instead = with.length == 1 && without.length == 1;
				*/
				
				if (!hasTraits(wep, ref)) continue;
				if (!hasTraits(ref, wep)) continue;
				//
				var cat = cmp(wep.category, ref.category);
				var die = cmp(wepDie, ref.getDieSize());
				var usage = cmp(wep.usage, ref.usage);
				var range = cmp(wep.range ?? 0, ref.range ?? 0);
				//
				//var total = instead ? 1 : with.length + without.length;
				var total = 0;
				if (cat != null) total += 1;
				if (die != null) total += 1;
				if (usage != null) total += 1;
				if (range != null) total += 1;
				//
				if (total <= 0) {
					var refDamageTypes = ref.getDamageTypes();
					//
					var diff = [];
					if (wep.group != ref.group) {
						diff.push('in ${wep.group.capitalize()} group'
							+ ' rather than ${ref.group.capitalize()}');
					}
					if (!compareDamageTypes(wepDamageTypes, refDamageTypes)) {
						diff.push('deals ${printDamageTypes(wepDamageTypes)} damage'
							+ ' rather than ${printDamageTypes(refDamageTypes)}');
					}
					if (diff.length > 2) {
						diff[diff.length - 1] = "and " + diff[diff.length - 1];
					}
					var diffText = diff.length == 2 ? diff.join(" and ") : diff.join(", ");
					if (wep.name == ref.name) {
						// that IS the same weapon
					} else if (diff.length == 0) {
						out.info('This weapon is functionally identical to ${ref.name}', [
							"This weapon seems to be functionally identical to ",
							WeaponRef.create(ref),
							"."
						]);
					} else {
						out.info('This weapon is much alike ${ref.name}', [
							"This weapon is much alike ",
							WeaponRef.create(ref),
							', but $diffText.'
						]);
					}
					/*var diff = [];
					if (instead) {
						diff.push("has " + with[0] + " instead of " + without[0]);
					} else {
						if (with.length > 0) {
							diff.push("with " + with.map(t -> t.toLabel()).join(", "));
						}
						if (without.length > 0) {
							diff.push("without " + without.map(t -> t.toLabel()).join(", "));
						}
					}
					if (cat != null) diff.push('is $cat');
					if (die != null) diff.push('with d$die die');
					if (usage != null) diff.push('used $usage');
					if (group != null) diff.push('is a $group');
					if (diff.length > 1) {
						diff[diff.length - 1] = "and " + diff[diff.length - 1];
					}
					out.info('This weapon is like ${ref.name}, but ' + diff.join(", "));*/
				}
			}
			//return null;
		});
	}
}