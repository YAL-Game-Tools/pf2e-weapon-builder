import js.html.Element;
import js.html.SpanElement;
import js.html.DivElement;
import data.Weapon;
import js.Browser.document;
using StringTools;

/**
	Weapon buttons that open weapon preview in a box inside the Review panel
**/
class WeaponRef {
	static var refDiv:Element = find("#review-ref");
	static var refName:SpanElement = find("#review-ref-name");
	static var refScore:TraitBlock = find("#review-ref-score");
	static var refMeta:DivElement = find("#review-ref-meta");
	static var refTraits:DivElement = find("#review-ref-traits");
	static var current:Weapon = null;
	
	public static function hide() {
		refDiv.style.display = "none";
		current = null;
	}
	public static function update(wep:Weapon) {
		if (current == wep) {
			refDiv.style.display = "none";
			current = null;
		} else {
			current = wep;
			refDiv.style.display = "";
			refName.innerText = wep.name;
			ListPrinter.print(wep, refScore, refMeta, refTraits, null);
		}
	}
	public static function create(wep:Weapon) {
		var button = document.createSpanElement();
		button.addEventListener("click", e -> {
			if (wep != null) update(wep);
			e.preventDefault();
			return false;
		});
		button.classList.add("weapon-button", "active");
		button.append(wep?.name ?? "???");
		return button;
	}
}