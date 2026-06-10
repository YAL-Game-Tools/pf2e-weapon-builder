package validation;

import data.WeaponDamageType;
import data.WeaponTrait;

/**
	Rules related to specific weapon traits
**/
class ValTraits {
	public static function init() {
		addSimple("Ranged Trip", (wep) -> {
			if (!wep.hasTrait(RangedTrip)) return null;
			if (wep.hasDashTrait("thrown") || wep.range > 0) return null;
			return "Weapon with Ranged Trip should have a range";
		});
		
		addSimple("Monk", (wep) -> {
			if (wep.hasTrait(Monk) && wep.damageDie > 8) {
				return "Monastic weapons don't usually have damage dice above d8.";
			} else return null;
		});
		
		//
		addSimple("Deadly", (wep) -> {
			var deadly = wep.getDashDie("deadly", 0);
			if (deadly > 0) {
				var damage = wep.getDieSize();
				if (deadly > damage + 4) {
					return "Deadly die size should be no more than two steps above the weapon's die size.";
				} else if (deadly < damage) {
					return "Deadly die size should not be below the weapon's die size.";
				}
			}
			return null;
		});
		addSimple("Fatal", (wep) -> {
			var fatal = wep.getDashDie("fatal", 0);
			if (fatal > 0) {
				var damage = wep.getDieSize();
				if (fatal > 12) {
					return "Fatal should not have a die above d12.";
				}
				if (damage == 10 && fatal == 12) return null; // waste of potential but it's fine
				if (fatal != damage + 4) {
					return "Fatal die size should be two steps above the weapon's die size (capped at d12).";
				}
			}
			return null;
		});
		addSimple("Fatal+Deadly", (wep) -> {
			if (wep.getDashDie("fatal", 0) > 0 && wep.getDashDie("deadly", 0) > 0) {
				return "Weapons don't usually have Fatal and Deadly at once.";
			}
			return null;
		});
		
		//
		add("Versatile#", (wep, out) -> {
			var versatileCount = 0;
			inline function check(trait:WeaponTrait, damageType:WeaponDamageType) {
				if (wep.hasTrait(trait)) {
					versatileCount += 1;
					if (wep.damageType == damageType) {
						out.warn("This weapon's versatile damage type is the same as its damage type.");
					}
				}
			}
			check(VersatileB, Bludgeoning);
			check(VersatileS, Slashing);
			check(VersatileP, Piercing);
			if (versatileCount > 1) {
				out.warn("Weapons don't usually have multiple Versatile traits, consider using Modular instead.");
			}
		});
		
		//
		add("Maneuvers", (wep, out) -> {
			var n = 0;
			if (wep.hasTrait(Trip)) n++;
			if (wep.hasTrait(Grapple)) n++;
			if (wep.hasTrait(Disarm)) n++;
			if (wep.hasTrait(Shove)) n++;
			if (n > 2) {
				out.warn("Weapons don't usually have more than 2 maneuver traits.");
			}
		});
		
		//
		addSimple("Two-Hand", (wep) -> {
			if (!wep.hasDashTrait("two-hand")) return null;
			if (wep.usage == HeldInTwoHands) {
				return "Two-handed weapons can't have a Two-Hand trait.";
			}
			if (wep.hasTrait(Agile)) {
				return "Agile weapons don't usually have a Two-Hand trait.";
			}
			if (wep.hasTrait(FreeHand)) {
				return "Free-hand weapons don't usually have a Two-Hand trait.";
			}
			if (wep.hasTrait(Attached)
				|| wep.hasTrait(AttachedToCrossbowOrFirearm)
				|| wep.hasTrait(AttachedToShield)
			) {
				return "Attached weapons don't usually have a Two-Hand trait.";
			}
			return null;
		});
		addSimple("Free-Hand", (wep) -> {
			if (!wep.hasTrait(FreeHand)) return null;
			if (wep.usage == HeldInTwoHands) {
				return "Free-hand weapons can't be two-handed.";
			}
			if (wep.getDieSize() > 4) {
				return "Free-hand weapons don't usually have a damage die above a d4.";
			}
			return null;
		});
		
		//
	}
}