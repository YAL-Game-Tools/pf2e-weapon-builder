package data;

import haxe.macro.Context;
import haxe.macro.Expr;
using StringTools;

class WeaponTraitBuilder {
	public static macro function build():Array<Field> {
		var p = Context.currentPos();
		var fields = Context.getBuildFields();
		var traitInfoExprs = [];
		for (field in fields) {
			if (field.access != null && field.access.contains(AStatic)) continue;
			switch (field.kind) {
				case FVar(_, { expr: EConst(CString(key)) }): {
					var name = field.name;
					var label = ~/(^| )(\w)/g.map(StringTools.replace(key, "-", " "), rx -> {
						return rx.matched(1) + rx.matched(2).toUpperCase();
					});
					label = label.replace("Two Hand", "Two-Hand");
					label = ~/^(Thrown \d+)$/.replace(label, "$1ft");
					traitInfoExprs.push(macro {
						name: $v{name},
						//key: $v{key},
						trait: $i{name},
						label: $v{label},
					});
				};
				default:
			}
		}
		//
		var traitInfoDecl:Expr = { pos: p, expr: EArrayDecl(traitInfoExprs) };
		var extras = macro class {
			@:keep public static var list = $traitInfoDecl;
			@:keep public static var map = (() -> {
				var map = new Map();
				for (info in list) map[info.trait] = info;
				return map;
			})();
		};
		for (field in extras.fields) fields.push(field);
		//
		return fields;
	}
}