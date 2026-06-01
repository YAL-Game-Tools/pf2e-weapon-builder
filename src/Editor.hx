import js.html.UListElement;
import js.html.OptionElement;
import js.html.DivElement;
import js.html.SpanElement;
import js.html.InputElement;
import js.html.SelectElement;
import js.html.Element;
import js.html.Console;
import js.lib.RegExp;
import js.Browser;
import js.Browser.document;
import data.*;
using StringTools;

class Editor {
	static function find<T:Element>(qry:String, ?c:Class<T>):T {
		return cast document.querySelector(qry);
	}
	static function findLink<T:Element>(qry:String, ?c:Class<T>):T {
		var el = inline find(qry, c);
		el.addEventListener("change", e -> {
			if (!hasChanges) {
				hasChanges = true;
				loadTemplate.value = "";
			}
			update();
		});
		return el;
	}
	static var hasChanges = false;
	static var loadTemplate:SelectElement = find("#load-template");
	static var traitSelect:SelectElement = find("#weapon-traits");
	//
	static var weaponName:InputElement = findLink("#weapon-name");
	static var weaponRarity:SelectElement = findLink("#weapon-rarity");
	static var weaponCategory:SelectElement = findLink("#weapon-category");
	static var weaponGroup:SelectElement = findLink("#weapon-group");
	static var weaponDamageDie:SelectElement = findLink("#weapon-damage-die");
	static var weaponDamageType:SelectElement = findLink("#weapon-damage-type");
	static var weaponUsage:SelectElement = findLink("#weapon-usage");
	//
	static var previewName:SpanElement = find("#preview-name");
	static var previewScore:TraitBlock = find("#preview-score");
	static var previewMeta:DivElement = find("#preview-meta");
	static var previewTraits:DivElement = find("#preview-traits");
	static var previewWarnings:UListElement = find("#warnings");
	//
	static function getTraitBlocks() {
		var traitBlocks:Array<TraitBlock> = [];
		for (block in previewTraits.querySelectorAll(".trait")) traitBlocks.push(cast block);
		return traitBlocks;
	}
	static function getWeapon(traitBlocks:Array<TraitBlock>):Weapon {
		var name = weaponName.value;
		if (name == "") name = weaponName.placeholder;
		//
		return {
			name: name,
			category: cast weaponCategory.value,
			group: cast weaponGroup.value,
			level: 1,
			damage: cast weaponDamageDie.value,
			damageType: cast weaponDamageType.value,
			range: 0,
			reload: 0,
			traits: traitBlocks.map(block -> block.trait),
			rarity: cast weaponRarity.value,
			usage: cast weaponUsage.value,
		};
	}
	public static function update() {
		var traitBlocks = getTraitBlocks();
		var wep = getWeapon(traitBlocks);
		previewName.innerText = wep.name;
		ListPrinter.print(wep, previewScore, previewMeta, previewTraits, traitBlocks);
		previewWarnings.innerHTML = "";
		Validators.refDiv.style.display = "none";
		Validators.runAndPrintTo(wep, previewWarnings);
	}
	public static function init(weapons:Array<Weapon>) {
		//
		var dummy:Weapon = getWeapon(getTraitBlocks());
		dummy.isEstimate = true;
		function addTraitOption(trait) {
			var tuple = WeaponTrait.map[trait];
			var option = document.createOptionElement();
			var weight = dummy.getTraitWeight(tuple.trait);
			var weightLabel = WeaponTools.getTraitWeight_range ?? "" + weight;
			var label = tuple.label;
			if (weightLabel != "0") label = '$label ($weightLabel)';
			option.append(label);
			option.value = tuple.trait;
			traitSelect.append(option);
		}
		//
		traitSelect.append(document.createHRElement());
		var meleeTraits = WeaponTraitSets.either.concat(WeaponTraitSets.melee);
		meleeTraits.sort((a, b) -> (a:String) < (b:String) ? -1 : 1);
		for (trait in meleeTraits) addTraitOption(trait);
		//
		traitSelect.append(document.createHRElement());
		for (trait in WeaponTraitSets.flavor) addTraitOption(trait);
		//
		function addTrait(trait:WeaponTrait, ?label:String) {
			var tuple = WeaponTrait.map[trait];
			label ??= tuple != null ? tuple.label : trait;
			for (node in previewTraits.querySelectorAll(".trait")) {
				var block:TraitBlock = cast node;
				if (block.trait == trait) return;
			}
			var block = new TraitBlock(trait, label);
			block.addEventListener("click", e -> {
				block.remove();
				update();
			});
			previewTraits.append(block);
		}
		traitSelect.addEventListener("change", _ -> {
			var sel:OptionElement = cast traitSelect.selectedOptions[0];
			if (sel == null || sel.value == "") return;
			var tuple = WeaponTrait.map[cast sel.value];
			if (tuple == null) return;
			addTrait(tuple.trait);
			update();
			traitSelect.value = "";
		});
		//
		for (wep in weapons) {
			var option = document.createOptionElement();
			option.append(wep.name);
			loadTemplate.append(option);
		}
		loadTemplate.addEventListener("change", (e) -> {
			var name = loadTemplate.value;
			if (name == "") return;
			var wep:Weapon = (cast weapons).find((wep:Weapon) -> wep.name == name);
			if (wep == null) return;
			if (hasChanges && !Browser.window.confirm(
				"Are you sure you want to load a base weapon? This will replace your edits!"
			)) return;
			hasChanges = false;
			//
			weaponName.value = wep.name;
			weaponRarity.value = wep.rarity;
			weaponCategory.value = wep.category;
			weaponGroup.value = wep.group;
			weaponDamageDie.value = wep.damage;
			weaponDamageType.value = wep.damageType;
			weaponUsage.value = wep.usage;
			//
			previewTraits.innerHTML = "";
			for (trait in wep.traits) addTrait(trait);
			//
			update();
		});
		//
		addTrait(Reach);
		addTrait(Tripkee);
		addTrait(Shove);
		update();
	}
}