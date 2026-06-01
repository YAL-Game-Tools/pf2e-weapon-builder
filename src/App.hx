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
		weapons = weapons.filter(wep -> wep.damage != null
			&& !wep.traits.contains(Magical)
			&& !wep.traits.contains(Consumable)
			&& !wep.isRanged()
		);
		//weapons.sort((a, b) -> a.traits.length - b.traits.length);
		weapons.sort((a, b) -> a.name < b.name ? -1 : 1);
		ListPrinter.init(weapons);
		Validators.init(weapons);
		Editor.init(weapons);
		//WeaponGen.run(weapons);
	}
}