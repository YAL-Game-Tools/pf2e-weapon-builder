package validation;
import tools.HtmlBits;
import data.Weapon;
using StringTools;

class Validator {
	public var name:String;
	public var func:ValidatorFunc;
	//
	public var notesPerProblem = new Map<String, HtmlBits>();
	public var violatorsPerProblem = new Map<String, Array<Weapon>>();
	//
	public function new(name, func:ValidatorFunc) {
		this.name = name;
		this.func = func;
	}
}
typedef ValidatorFunc = (wep:Weapon, warnings:ValidatorMessages)->Void;
abstract ValidatorMessages(Array<ValidatorPair>) {
	public inline function new() this = [];
	public function warn(id:String, ?text:HtmlBits, ?extra:HtmlBits) {
		text ??= [id];
		this.push(osh([id, text, extra]));
	}
	public function info(id:String, ?text:HtmlBits, ?extra:HtmlBits) {
		text ??= [id];
		this.push(osh([id, text, extra], { type: MInfo }));
	}
	public inline function toArray():Array<ValidatorPair> {
		return this;
	}
	public inline function iterator() {
		return this.iterator();
	}
}
typedef ValidatorPair = {
	id:String,
	text:HtmlBits,
	?type:ValidatorMessageType,
	?extra:HtmlBits
};
enum abstract ValidatorMessageType(String) {
	var MInfo = "info";
	var MWarn = "warn";
}