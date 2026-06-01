package tools;

import js.html.Element;
import js.html.Node;
import haxe.extern.EitherType;

@:forward
abstract HtmlBits(Array<HtmlBit>) from Array<HtmlBit> to Array<HtmlBit> {
	public inline function new() this = [];
	
	@:from public static inline function fromBit(bit:HtmlBit):HtmlBits {
		return [bit];
	}
	
	public function appendTo(e:Element) {
		for (bit in this) {
			e.append(bit);
		}
	}
	
	public inline function iterator() {
		return this.iterator();
	}
}
typedef HtmlBit = EitherType<String, Node>;