/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version 1.1
 * (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * The Original Code is the StyleKit library.
 *
 * The Initial Developer of the Original Code is
 * Videojuicer Ltd. (UK Registered Company Number: 05816253).
 * Portions created by the Initial Developer are Copyright (C) 2010
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 * 	Dan Glegg
 * 	Adam Livesley
 *
 * ***** END LICENSE BLOCK ***** */
package org.stylekit.css.value 
{
	
	import org.stylekit.css.parse.ValueParser;
	import org.stylekit.css.value.Value;
	import org.utilkit.util.Hex;
	import org.utilkit.util.StringUtil;
	
	public class ColorValue extends Value
	{
		
		public static var COLORS:Object = {
			"aliceblue": 0xF0F8FF,
			"antiquewhite": 0xFAEBD7,
			"aqua": 0x00FFFF,
			"aquamarine": 0x7FFFD4,
			"azure": 0xF0FFFF,
			"beige": 0xF5F5DC,
			"bisque": 0xFFE4C4,
			"black": 0x000000,
			"blanchedalmond": 0xFFEBCD,
			"blue": 0x0000FF,
			"blueviolet": 0x8A2BE2,
			"brown": 0xA52A2A,
			"burlywood": 0xDEB887,
			"cadetblue": 0x5F9EA0,
			"chartreuse": 0x7FFF00,
			"chocolate": 0xD2691E,
			"coral": 0xFF7F50,
			"cornflowerblue": 0x6495ED,
			"cornsilk": 0xFFF8DC,
			"crimson": 0xDC143C,
			"cyan": 0x00FFFF,
			"darkblue": 0x00008B,
			"darkcyan": 0x008B8B,
			"darkgoldenrod": 0xB8860B,
			"darkgray": 0xA9A9A9,
			"darkgreen": 0x006400,
			"darkkhaki": 0xBDB76B,
			"darkmagenta": 0x8B008B,
			"darkolivegreen": 0x556B2F,
			"darkorange": 0xFF8C00,
			"darkorchid": 0x9932CC,
			"darkred": 0x8B0000,
			"darksalmon": 0xE9967A,
			"darkseagreen": 0x8FBC8F,
			"darkslateblue": 0x483D8B,
			"darkslategray": 0x2F4F4F,
			"darkturquoise": 0x00CED1,
			"darkviolet": 0x9400D3,
			"deeppink": 0xFF1493,
			"deepskyblue": 0x00BFFF,
			"dimgray": 0x696969,
			"dodgerblue": 0x1E90FF,
			"firebrick": 0xB22222,
			"floralwhite": 0xFFFAF0,
			"forestgreen": 0x228B22,
			"fuchsia": 0xFF00FF,
			"gainsboro": 0xDCDCDC,
			"ghostwhite": 0xF8F8FF,
			"gold": 0xFFD700,
			"goldenrod": 0xDAA520,
			"gray": 0x808080,
			"green": 0x008000,
			"greenyellow": 0xADFF2F,
			"honeydew": 0xF0FFF0,
			"hotpink": 0xFF69B4,
			"indianred": 0xCD5C5C,
			"indigo": 0x4B0082,
			"ivory": 0xFFFFF0,
			"khaki": 0xF0E68C,
			"lavender": 0xE6E6FA,
			"lavenderblush": 0xFFF0F5,
			"lawngreen": 0x7CFC00,
			"lemonchiffon": 0xFFFACD,
			"lightblue": 0xADD8E6,
			"lightcoral": 0xF08080,
			"lightcyan": 0xE0FFFF,
			"lightgoldenrodyellow": 0xFAFAD2,
			"lightgrey": 0xD3D3D3,
			"lightgreen": 0x90EE90,
			"lightpink": 0xFFB6C1,
			"lightsalmon": 0xFFA07A,
			"lightseagreen": 0x20B2AA,
			"lightskyblue": 0x87CEFA,
			"lightslategray": 0x778899,
			"lightsteelblue": 0xB0C4DE,
			"lightyellow": 0xFFFFE0,
			"lime": 0x00FF00,
			"limegreen": 0x32CD32,
			"linen": 0xFAF0E6,
			"magenta": 0xFF00FF,
			"maroon": 0x800000,
			"mediumaquamarine": 0x66CDAA,
			"mediumblue": 0x0000CD,
			"mediumorchid": 0xBA55D3,
			"mediumpurple": 0x9370D8,
			"mediumseagreen": 0x3CB371,
			"mediumslateblue": 0x7B68EE,
			"mediumspringgreen": 0x00FA9A,
			"mediumturquoise": 0x48D1CC,
			"mediumvioletred": 0xC71585,
			"midnightblue": 0x191970,
			"mintcream": 0xF5FFFA,
			"mistyrose": 0xFFE4E1,
			"moccasin": 0xFFE4B5,
			"navajowhite": 0xFFDEAD,
			"navy": 0x000080,
			"oldlace": 0xFDF5E6,
			"olive": 0x808000,
			"olivedrab": 0x6B8E23,
			"orange": 0xFFA500,
			"orangered": 0xFF4500,
			"orchid": 0xDA70D6,
			"palegoldenrod": 0xEEE8AA,
			"palegreen": 0x98FB98,
			"paleturquoise": 0xAFEEEE,
			"palevioletred": 0xD87093,
			"papayawhip": 0xFFEFD5,
			"peachpuff": 0xFFDAB9,
			"peru": 0xCD853F,
			"pink": 0xFFC0CB,
			"plum": 0xDDA0DD,
			"powderblue": 0xB0E0E6,
			"purple": 0x800080,
			"red": 0xFF0000,
			"rosybrown": 0xBC8F8F,
			"royalblue": 0x4169E1,
			"saddlebrown": 0x8B4513,
			"salmon": 0xFA8072,
			"sandybrown": 0xF4A460,
			"seagreen": 0x2E8B57,
			"seashell": 0xFFF5EE,
			"sienna": 0xA0522D,
			"silver": 0xC0C0C0,
			"skyblue": 0x87CEEB,
			"slateblue": 0x6A5ACD,
			"slategray": 0x708090,
			"snow": 0xFFFAFA,
			"springgreen": 0x00FF7F,
			"steelblue": 0x4682B4,
			"tan": 0xD2B48C,
			"teal": 0x008080,
			"thistle": 0xD8BFD8,
			"tomato": 0xFF6347,
			"turquoise": 0x40E0D0,
			"violet": 0xEE82EE,
			"wheat": 0xF5DEB3,
			"white": 0xFFFFFF,
			"whitesmoke": 0xF5F5F5,
			"yellow": 0xFFFF00,
			"yellowgreen": 0x9ACD32
		}
		
		protected var _hexValue:uint;
		protected var _alphaValue:Number = 1.0;
		
		public function ColorValue()
		{
			super();
		}
		
		public static function parse(str:String):ColorValue
		{
			str = StringUtil.trim(str);
			var cVal:ColorValue = new ColorValue();
				cVal.rawValue = str;
			var wVal:uint = ColorValue.COLORS[str.toLowerCase()];
			
			if(wVal)
			{
				// Word value.
				cVal.hexValue = wVal;
			}
			else if (str.indexOf("rgba") != -1 || str.indexOf("rgb") != -1)
			{
				var rgba:String = str.substr(str.indexOf("(") + 1);
				rgba = rgba.substr(0, rgba.length - 1);
				rgba = rgba.replace(/ /g, '');
				
				var values:Array = rgba.split(",");
				
				var red:int = Math.max(0, Math.min(255, parseInt(values[0])));
				var green:int = Math.max(0, Math.min(255, parseInt(values[1])));
				var blue:int = Math.max(0, Math.min(255, parseInt(values[2])));
				var alpha:Number = (values.length == 4 ? Math.max(0, Math.min(1.0, values[3])) : 1.0);
				
				var hex:uint = Hex.rgbToHex(red, green, blue);
				
				cVal.alphaValue = alpha;
				cVal.hexValue = hex;
			}
			else
			{
				// Attempt to parse into hex number
				var mInd:int = -1;
				mInd = str.indexOf("0x");
				if(mInd > -1)
				{
					str = str.substr(mInd+2, 6);
				}
				
				mInd = str.indexOf("#");
				if(mInd > -1)
				{
					str = str.substr(mInd+1, 6);
				}
				
				var hVal:uint = parseInt(str, 16);
				if(!isNaN(hVal))
				{
					cVal.hexValue = parseInt(str, 16);
				}			
			}
			return cVal;
		}
		
		public static function identify(str:String):Boolean
		{
			str = StringUtil.trim(str).toLowerCase();
			if(str.charAt(0) == "#" || str.charAt(0) == "#" || str.substr(0,2) == "0x" || str.substr(0,3) == "rgb" || ColorValue.COLORS[str] != null)
			{
				return true;
			}
			return false;
		}
		
		public function set hexValue(n:uint):void
		{
			this._hexValue = n;
			
			this.modified();
		}
		
		public function get hexValue():uint
		{
			return this._hexValue;
		}
		
		public function set alphaValue(n:Number):void
		{
			this._alphaValue = Math.max(0, Math.min(n, 1.0));
			
			this.modified();
		}
		
		public function get alphaValue():Number
		{
			return this._alphaValue;
		}
		
		public override function isEquivalent(other:Value):Boolean
		{
			// type matches
			if (other is ColorValue)
			{
				return (this.hexValue == (other as ColorValue).hexValue);
			}
			
			return super.isEquivalent(other);
		}
	}
}