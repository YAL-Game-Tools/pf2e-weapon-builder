package tools;

import js.html.Element;
import js.Browser.document;

class HtmlTools {
	public static function find<T:Element>(qry:String, ?c:Class<T>):T {
		return cast document.querySelector(qry);
	}
	/*public static function createPara(text:String) {
		var p = document.createParagraphElement();
		p.append(text);
		return p;
	}*/
}
