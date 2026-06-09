package data;
using StringTools;

class WeaponWeighter {
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
		var twoHanded = wep.isTwoHanded();
		return switch (wep.category) {
			case Simple: twoHanded ? 9 : 4;
			case Martial: twoHanded ? 13 : 7;
			case Advanced: twoHanded ? 15 : 9;
			default: 0;
		}
	}
	
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
			case Propulsive: 1;
			case Concussive: 1;
			case DoubleBarrel: 3;
			case Kickback:
				if (est) return range("1-2");
				wep.reload > 0 && wep.damageDie >= 8 ? 1 : 2;
			case Repeating:
				if (est) return range("2-3");
				wep.reload > 0 ? 1 : 2;
			case _ if (extractDash("volley")):
				if (est) return range("-3-0");
				n <= 10 ? -1 : n <= 20 ? -2 : -3;
			case _ if (extractDie("fatal-aim")): 1;
			
			default: 0;
		}
	}
	
	public static function getTraitWeights(wep:Weapon, ?traitBlocks:Array<TraitBlock>) {
		var budget = wep.getTraitBudget();
		var damage = wep.getDieSize();
		var pairs = [];
		var total = 0;
		function add(name, trait, weight) {
			var pair = osh([name, trait, weight]);
			pairs.push(pair);
			total += weight;
			return pair;
		}
		//
		var damageWeight = Std.int((damage - 4) / 2) * 3;
		var damagePair = { name: "1" + wep.damage, weight: damageWeight };
		total += damageWeight;
		//
		var range = wep.range;
		var rangeTax = 0;
		if (wep.isRanged()) {
			if (range >= 120) {
				rangeTax = 2;
			} else if (range >= 60) {
				rangeTax = 1;
			}
		} else {
			// thrown weapons have different rules?
			if (range > 30) {
				rangeTax = 2;
			} else if (range > 0) {
				rangeTax = 1;
			}
			/*if (range >= 180) {
				rangeTax = 4;
			} else if (range >= 120) {
				rangeTax = 3;
			} else if (range >= 60) {
				rangeTax = 2;
			} else if (range >= 30) {
				rangeTax = 1;
			}*/
		}
		var rangePair = null;
		if (range > 0) {
			rangePair = add("range-" + range, null, rangeTax);
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
		return osh([budget, pairs], {
			score: total,
			damage: damagePair,
			range: rangePair,
		});
	}
}