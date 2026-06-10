package validation;
import data.WeaponDamageType;
import data.WeaponTrait;
import js.html.MouseEvent;
import tools.HtmlBits;
import js.html.Console;
import js.html.Element;
import js.Browser.document;
import data.Weapon;
import validation.Validator;
using StringTools;

class Validators {
	public static var weapons(default, null):Array<Weapon>;
	public static var list:Array<Validator> = [];
	public static function run(wep:Weapon) {
		var pairs = [];
		for (val in list) {
			var messages = new ValidatorMessages();
			val.func(wep, messages);
			for (message in messages) {
				var note = val.notesPerProblem[message.id];
				pairs.push(osh([message, note]));
			}
		}
		if (pairs.length == 0) {
			pairs.push({
				message: {
					id: "OK!",
					text: "No obvious issues!",
					type: MInfo,
				},
				note: null
			});
		}
		return pairs;
	}
	public static function runAndPrintTo(wep:Weapon, out:Element) {
		for (item in run(wep)) {
			var div = document.createLIElement();
			if (item.message.type == MInfo) {
				div.classList.add("info");
			} else div.classList.add("warn");
			var textDiv = document.createDivElement();
			item.message.text.appendTo(textDiv);
			div.append(textDiv);
			if (item.note != null) {
				var note = document.createDivElement();
				note.classList.add("note");
				item.note.appendTo(note);
				div.append(note);
			}
			out.append(div);
		}
	}
	public static function createInfoBlock(bits:HtmlBits) {
		var extra = document.createDivElement();
		extra.classList.add("explain");
		bits.appendTo(extra);
		//
		var info = document.createSpanElement();
		info.append("i");
		info.classList.add("info-button", "active");
		info.addEventListener("click", (e:MouseEvent) -> {
			if (extra.offsetHeight <= 0) {
				info.parentElement.after(extra);
			} else extra.remove();
			e.preventDefault();
			return false;
		});
		return info;
	}
	//
	public static function add(name, func) {
		var val = new Validator(name, func);
		//var violators = [];
		var violations = val.violatorsPerProblem;
		for (wep in weapons) {
			var messages = new ValidatorMessages();
			func(wep, messages);
			for (warning in messages) if (warning.type != MInfo) {
				var violators = violations[warning.id];
				if (violators == null) {
					violations[warning.id] = violators = [];
				}
				violators.push(wep);
			}
		}
		for (violation => violators in violations) {
			var bits:HtmlBits;
			var n = violators.length;
			if (n == 1) {
				bits = [
					"Only one base weapon (",
					WeaponRef.create(violators[0]),
					") fails this pattern.",
				];
			} else if (n <= 3) {
				bits = ["Only a few base weapons ("];
				for (i in 0 ... n - 1) {
					if (i > 0) bits.push(", ");
					bits.push(WeaponRef.create(violators[i]));
				}
				bits.push(" and ");
				bits.push(WeaponRef.create(violators[n - 1]));
				bits.push(") fail this pattern.");
			} else {
				var listBits:HtmlBits = ["Weapons: "];
				for (wep in violators) {
					listBits.push(WeaponRef.create(wep));
				}
				var p = Math.round(violators.length / weapons.length * 100);
				bits = [
					'Only $n ($p%) base weapons',
					createInfoBlock(listBits),
					' fail this pattern.'
				];
			}
			val.notesPerProblem[violation] = bits;
			Console.warn(violation, violators);
		}
		list.push(val);
	}
	public static function addSimple(name, func:Weapon->String) {
		add(name, (wep, out) -> {
			var snip = func(wep);
			if (snip != null) out.warn(snip, snip);
		});
	}
	public static function init(_weapons:Array<Weapon>) {
		weapons = _weapons;
		ValTraits.init();
		ValMatch.init();
		ValBudget.init();
		
		addSimple("One-handed", (wep) -> {
			if (wep.usage == HeldInOneHand) {
				var damage = wep.getDieSize();
				if (damage != null && damage > 8) {
					return "One-handed weapons don't usually have damage dice above d8.";
				}
			}
			return null;
		});
		
		add("Die size", (wep, out) -> {
			var dieSize = wep.getDieSize();
			if (wep.hasTrait(Agile) && dieSize > 6) {
				out.warn("Agile weapons don't usually have a damage die above a d6.");
			} else if (wep.hasTrait(Finesse) && dieSize > 8) {
				out.warn("Finesse weapons don't usually have a damage die above a d8.");
			} else if (wep.usage == HeldInOneHand && dieSize > 8) {
				out.warn("One-handed weapons don't usually have a damage die above a d8.");
			}
		});
		add("Group rules", (wep, out) -> {
			inline function warn(text) {
				out.warn(text);
			}
			switch (wep.group) {
				case Polearm:
					if (wep.usage != HeldInTwoHands) warn("Polearms are usually two-handed.");
				case Knife:
					if (wep.getDieSize() > 8) warn("Knives don't usually have damage die over d8.");
					var types = wep.getDamageTypes();
					if (!types.contains(Piercing) && !types.contains(Slashing)) {
						warn("Knives can usually deal Piercing or Slashing damage.");
					}
				case Sword:
					var types = wep.getDamageTypes();
					if (!types.contains(Piercing) && !types.contains(Slashing)) {
						warn("Swords can usually deal Piercing or Slashing damage.");
					}
				case Axe:
					if (!wep.getDamageTypes().contains(Slashing)) {
						warn("Axes can usually deal slashing damage.");
					}
					if (!wep.hasTrait(Sweep)) {
						out.info("Axes usually have a Sweep trait.");
					}
				case Hammer:
					if (!wep.getDamageTypes().contains(Bludgeoning)) {
						warn("Hammers can usually deal bludgeoning damage.");
					}
				case Spear:
					if (!wep.getDamageTypes().contains(Piercing)) {
						warn("Spears can usually deal piercing damage.");
					}
				default:
			}
		});
	}
}