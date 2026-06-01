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
	//
	public static var getTraitWeight_range:String = null;
	public static function getTraitWeight(wep:Weapon, trait:WeaponTrait) {
		var n = 0;
		function extractDash(key:String) {
			if (trait.startsWith(key + "-")) {
				n = Std.parseInt((trait:String).substring(key.length + 1));
				return n != null;
			} else return false;
		}
		function extractDie(key:String) {
			if (trait.startsWith(key + "-d")) {
				n = Std.parseInt((trait:String).substring(key.length + 2));
				return n != null;
			} else return false;
		}
		var est = wep.isEstimate;
		if (est) {
			getTraitWeight_range = null;
		}
		inline function range(r) {
			getTraitWeight_range = r;
			return 0;
		}
		return switch (trait) {
			// maneuvers, from comparing the polearms:
			case Shove: 1;
			case Trip: 1;
			case Disarm: 1;
			case Grapple: 1;
			//
			case TwoHandD8: 1;
			case TwoHandD10: 1;
			case TwoHandD12: 1;
			//
			case FatalD8: 3;
			case FatalD10: 3;
			case FatalD12: 3;
			//
			//case Nonlethal: 1; // not actually worth anything? Strange weapon sample
			case FreeHand: 3;
			case Razing: 1;
			case Backstabber: 1;
			//
			case Parry: 2;
			case Modular: 2;
			//
			case VersatileB: 1;
			case VersatileP: 1;
			case VersatileS: 1;
			// Fighting Oar vs Longspear
			case Sweep: 2;
			// plenty things
			case Forceful: 2;
			// Thundermace vs Longspear:
			case Backswing: 3;
			case Reach: 3;
			// low sample:
			case JoustingD6: 2;
			case Brace: 2;
			case Tearing: 3;
			case Resonant: 2;
			case Hampering: 2;
			case Tethered: 1;
			case RangedTrip: 3;
			case Injection: 4;
			case Vehicular: 3;
			case Concealable: 1;
			case Climbing: 1;
			//
			case AttachedToCrossbowOrFirearm: 5; // ..?!
			case AttachedToShield: 3;
			case Attached: {
				// Foundry classifies wheel attachments as "worn gloves" for some reason
				if (est) return range("0|3");
				wep.usage == WeaponUsage.WornGloves ? 0 : 3;
			};
			
			// shared:
			case Agile:
				if (est) return range("1-2");
				wep.damageDie <= 4 ? 1 : 2;
			case Finesse:
				if (est) return range("1-2");
				wep.damageDie <= 6 ? 1 : 2;
			
			// melee:
			case Twin:
				if (est) return range("1-2");
				wep.hasTrait(Agile) ? 2 : 1;
			case _ if (extractDie("deadly")):
				if (est) return range("2-3");
				n > wep.damageDie ? (n >= 10 ? 3 : 2) : 2;
			case _ if (extractDash("thrown")):
				if (est) return range("1-2");
				n <= 30 ? 1 : 2;
			
			// ranged:
			case _ if (extractDash("capacity")):
				if (est) return range("2-3");
				n <= 4 ? 2 : 3;
			case Cobbled: -1; // kind of?
			case Scatter5: 4;
			case Scatter10: 5;
			case Repeating:
				if (est) return range("2-3");
				wep.reload > 0 ? 1 : 2;
			
			default: 0;
		}
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
	public static function getTraitBudget(wep:Weapon) {
		if (wep.range > 0) {
			var base = switch (wep.usage) {
				case HeldInOnePlusHands: 1;
				case HeldInTwoHands: 2;
				default: 0;
			}
			return switch (wep.category) {
				case Simple: 3 + base;
				case Martial: 7 + base;
				case Advanced: 9 + base;
			}
		}
		var twoHanded = isTwoHanded(wep);
		return switch (wep.category) {
			case Simple: twoHanded ? 9 : 4;
			case Martial: twoHanded ? 13 : 7;
			case Advanced: twoHanded ? 15 : 9;
			default: 0;
		}
	}
	public static function getTraitWeights(wep:Weapon, ?traitBlocks:Array<TraitBlock>) {
		var budget = wep.getTraitBudget();
		var damage = wep.getDieSize();
		var pairs = [];
		var total = 0;
		inline function add(name, trait, weight) {
			pairs.push(osh([name, trait, weight]));
			total += weight;
		}
		//
		var damageWeight = Std.int((damage - 4) / 2) * 3;
		var damagePair = { name: "1" + wep.damage, weight: damageWeight };
		total += damageWeight;
		//
		var range = wep.range;
		var rangeTax = 0;
		if (range >= 180) {
			rangeTax = 4;
		} else if (range >= 120) {
			rangeTax = 3;
		} else if (range >= 60) {
			rangeTax = 2;
		} else if (range >= 30) {
			rangeTax = 1;
		}
		if (rangeTax > 0) {
			add("range-" + range, null, rangeTax);
		}
		if (wep.reload > 0) {
			add("reload-" + wep.reload, null, -wep.reload);
		}
		if (wep.group == data.WeaponGroup.Firearm) {
			add("firearm", null, -1);
		}
		//
		for (i => trait in wep.traits) {
			var weight = wep.getTraitWeight(trait);
			if (traitBlocks != null) {
				traitBlocks[i].traitWeight = weight;
			}
			if (trait == Thrown && range > 0 && range < 30) {
				add('Thrown ${range}ft', null, 0);
			} else {
				add(trait, trait, weight);
			}
		}
		return {
			score: total,
			budget: budget,
			damage: damagePair,
			pairs: pairs
		};
	}
}