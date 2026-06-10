import haxe.DynamicAccess;
import js.html.FieldSetElement;
import js.html.Console;
import js.lib.RegExp;
import js.Browser;
import js.Browser.document;
import data.*;
using StringTools;

class App {
	public static function main() {
		for (node in document.querySelectorAll("main fieldset")) {
			var q:FieldSetElement = cast node;
			var legend = q.querySelector("& > legend");
			legend.onclick = (e) -> {
				if (q.classList.contains("hide")) {
					q.classList.remove("hide");
				} else {
					q.classList.add("hide");
				}
			}
		}
		var weapons:Array<Weapon> = (cast Browser.window).pf2eWeapons;
		var notePairs:DynamicAccess<String> = (cast Browser.window).pf2eWeaponNotes;
		for (name => notes in notePairs) {
			var wep = weapons.find(wep -> wep.name == name);
			if (wep != null) {
				wep.notes = notes;
			} else {
				Console.error('"notes.js" references non-existing weapon "$name"');
			}
		}
		weapons = weapons.filter(wep -> wep.damage != null
			&& !wep.traits.contains(Magical)
			&& !wep.traits.contains(Consumable)
			&& !wep.traits.contains(Alchemical)
			&& !wep.traits.contains(Combination)
			&& !wep.isRanged()
		);
		//weapons = weapons.filter(wep -> wep.group == Firearm && wep.usage == HeldInTwoHands);
		//weapons.sort((a, b) -> a.traits.length - b.traits.length);
		weapons.sort((a, b) -> a.name < b.name ? -1 : 1);
		ListPrinter.init(weapons);
		validation.Validators.init(weapons);
		Editor.init(weapons);
		//WeaponGen.run(weapons);
	}
}