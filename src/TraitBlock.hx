import data.WeaponTrait;
import js.html.SpanElement;
import js.Browser.document;
using StringTools;

@:forward
abstract TraitBlock(SpanElement) to SpanElement {
	public function new(key:String, ?text, ?weight) {
		this = document.createSpanElement();
		this.append(text ?? key.replace("-", " "));
		set_trait(cast key);
		this.classList.add("trait");
		if (weight != null) set_traitWeight(weight);
	}
	//
	public var trait(get, set):WeaponTrait;
	inline function get_trait() {
		return cast this.getAttribute("trait");
	}
	inline function set_trait(t) {
		this.setAttribute("trait", t);
		return t;
	}
	//
	public var traitWeight(get, set):Null<Int>;
	function get_traitWeight() {
		var w = this.getAttribute("weight");
		return w != null ? Std.parseInt(w) : null;
	}
	function set_traitWeight(w) {
		if (w != null && w != 0) {
			this.setAttribute("weight", "" + w);
		} else this.removeAttribute("weight");
		return w;
	}
}