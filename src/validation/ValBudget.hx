package validation;

class ValBudget {
	public static function init() {
		add("Budget", (wep, out) -> {
			var weapons = Validators.weapons;
			var calc = wep.getTraitWeights();
			var budget = calc.budget;
			if (budget <= 0) return;
			var score = calc.score;
			if (score > budget + 1) {
				out.warn("This weapon is too good for its category and usage.");
			}
			else if (score > budget) {
				var m = "This weapon is slightly better than average.";
				out.warn(m, [m,
					createInfoBlock([
						"In base weapons, this is mostly seen in uncommon AP weapons"
						+" and weapons with specific \"heavy\" traits (like Sweep)"
						+ " that thematically cannot be \"solved\""
						+ " by decreasing their damage die and adding another trait or two."
					])
				]);
			}
			else if (score >= budget - 1) {
				// OK!
			}
			else if (score >= budget - 2) {
				var m = "This weapon is slightly worse than average.";
				out.warn(m, [m,
					createInfoBlock([
						"Sometimes a weapon is more than just a weapon (",
						WeaponRef.create(weapons.find(wep -> wep.name == "Battle Lute")),
						") and sometimes there's nothing else it needs."
					]),
				]);
			} else {
				var m = "This weapon is visibly worse than average.";
				out.warn(m, [m,
					createInfoBlock([
						"Most of the base weapons in this category are still usable with a right build,"
						+ " but not particularly appealing."
					]),
				]);
			}
			//return null;
		});
	}
}