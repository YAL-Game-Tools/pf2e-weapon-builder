import js.html.InputElement;
import js.html.Element;
import js.html.Console;
import js.lib.RegExp;
import js.Browser;
import js.Browser.document;
import data.*;
using StringTools;

class ListPrinter {
	public static function print(wep:Weapon, scoreBlock:TraitBlock, metaDiv:Element, traitDiv:Element, traitBlocks) {
		var calc = wep.getTraitWeights(traitBlocks);
		var score = calc.score;
		var budget = calc.budget;
		//
		scoreBlock.className = "score";
		if (score >= budget + 2) {
			scoreBlock.classList.add("too-good");
		} else if (score >= budget + 1) {
			scoreBlock.classList.add("above-average");
		} else if (score >= budget) {
			scoreBlock.classList.add("just-right");
		} else if (score >= budget - 1) {
			scoreBlock.classList.add("alright");
		} else if (score >= budget - 2) {
			scoreBlock.classList.add("below-average");
		} else {
			scoreBlock.classList.add("not-good");
		}
		scoreBlock.innerText = '$score/$budget';
		//
		metaDiv.innerHTML = "";
		function addMetaBlock(text:String, cname) {
			var metaBlock = document.createSpanElement();
			metaBlock.classList.add("trait");
			if (cname != null) metaBlock.classList.add(cname);
			metaBlock.append(text);
			metaDiv.append(metaBlock);
			return metaBlock;
		}
		addMetaBlock(wep.rarity, wep.rarity == Uncommon ? "uncommon" : "no-weight");
		addMetaBlock(wep.category, wep.category);
		var handedness = switch (wep.usage) {
			case HeldInOnePlusHands: "1+handed";
			case _ if (wep.hasDashTrait("two-hand")): "1-2 handed";
			case HeldInOneHand: "1-handed";
			case HeldInTwoHands: "2-handed";
			default: "?";
		}
		addMetaBlock(handedness, null);
		metaDiv.append(new TraitBlock("group-" + wep.group, wep.group));
		metaDiv.append(new TraitBlock(
			"damage-" + wep.damage + "-" + wep.damageType,
			calc.damage.name + " " + wep.damageType,
			calc.damage.weight
		));
		//
		if (traitBlocks == null) {
			traitDiv.innerHTML = "";
			for (p in calc.pairs) {
				var tuple = WeaponTrait.map[p.trait];
				var traitBlock = new TraitBlock(p.name, tuple?.label, p.weight);
				traitDiv.append(traitBlock);
			}
		} else if (calc.range != null) {
			var thrownBlock = traitBlocks.find(tb -> tb.trait == Thrown);
			if (thrownBlock != null) {
				thrownBlock.traitWeight = calc.range.weight;
			}
		}
		return calc;
	}
	public static function run(weapons:Array<Weapon>) {
		var ul = Browser.document.createElement("ul");
		ul.classList.add("weapons");
		document.getElementById("base-weapons").append(ul);
		for (wep in weapons) {
			//if (!(wep.hasDamageType(Bludgeoning) && wep.hasDamageType(Slashing))) continue;
			var twoHanded = wep.isTwoHanded();
			var obj = {
				name: wep.name,
				die: wep.damage,
				cat: wep.category,
				group: wep.group,
				hands: twoHanded ? 2 : 1
			};
			//
			var h3 = document.createElement("h3");
			h3.append(wep.name + " ");
			var scoreBlock = new TraitBlock("score");
			h3.append(scoreBlock);
			var metaDiv = document.createDivElement();
			metaDiv.classList.add("meta");
			var traitDiv = document.createDivElement();
			traitDiv.classList.add("traits");
			//
			var li = document.createElement("li");
			li.append(h3, metaDiv, traitDiv);
			//
			var calc = print(wep, scoreBlock, metaDiv, traitDiv, null);
			var info:Array<Any> = [];
			for (pair in [calc.damage].concat(calc.pairs)) {
				info.push(pair.name);
				info.push(pair.weight);
			}
			var delta = calc.score - calc.budget;
			var deltaStr = delta >= 0 ? "@+" + delta : "@" + delta;
			Console.log('${calc.score}/${calc.budget} $deltaStr', obj, info);
			ul.append(li);
		}
	}
	public static function init(weapons:Array<Weapon>) {
		var button:InputElement = find("#print-base-weapons");
		function onClick() {
			run(weapons);
			button.parentElement.innerText = "And if you know what browser Developer Tools are,"
				+ " check out the Console tab for a filterable list!";
		}
		button.addEventListener("click", onClick);
		onClick();
	}
}