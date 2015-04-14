package  
{
	import flash.errors.IOError;
	/**
	 * ...
	 * @author MZ
	 */
	public class MUtils 
	{
		
		public static function StringToPrettyJSON(code:String):String
		{
			var obj:Object = JSON.parse(code);
			return ObjectToPrettyJSON(obj);
		}
		
		public static function isNullOrEmpty(s:String):Boolean
		{
			return s == "" || s == null;
		}
		
		public static function genSpaces(n:int):String
		{
			var out:String = "";
			for (var i = 0; i < n;++i)
				out += " ";
			return out;
		}
		public static function ObjectToPrettyJSON(obj:Object,tab:int=0):String
		{
			if (obj is String) return "\"" + obj + "\"";
			if (obj is Number) return ""+obj;
			
			var lines:String = "";
			for (var k in obj)
			{
				var o:*= obj[k];
				if (lines.length != 0) lines += ",\n";
				lines += genSpaces(tab+4);
				if (o is String) lines += "\""+k+"\":\"" + o + "\"";
				else if (o is Number) lines += "\""+k+"\":" + o;
				else if (o is Boolean) lines += "\"" + k + "\":" + o;
				else if (o is Array) 
				{
					lines += "\"" + k + "\":";
					var array:String = "";
					var a:Array = o;
					for (var i:int = 0; i < a.length; ++i )
					{
						if (array.length != 0)  array += ",\n";
						array += genSpaces(tab+8);
						array += ObjectToPrettyJSON(a[i], tab + 8);
					}
					lines += "[\n" + array + "\n"+genSpaces(tab+4)+"]";
				}
				else if (o is Object) lines += "\"" + k + "\":" + ObjectToPrettyJSON(o, tab + 4);
				else lines += "\""+k+"\":"+o;
			}
			return "{\n" + lines + "\n"+genSpaces(tab)+"}";
		}
		
		public static function Length(x:int, y:int):Number
		{
			return Math.sqrt(x * x + y * y);
		}
		

		/**
		 * Attempts to read a number from the input string.  Places
		 * the character location at the first character after the
		 * number.
		 *
		 * @return The JSONToken with the number value if a number could
		 * 		be read.  Throws an error otherwise.
		 */
		public static function readNumber(str:String):Number
		{
			// the string to accumulate the number characters
			// into that we'll convert to a number at the end
			var input:String = "";
			
			var index:int = 0;
			var ch:String = str.charAt(index);
			
			// check for a negative number
			if ( ch == '-' )
			{
				input += '-';
				ch = str.charAt(++index);
			}
			
			// the number must start with a digit
			if ( !isDigit( ch ) )
			{
				trace( "Expecting a digit" );
				return null;
			}
			
			// 0 can only be the first digit if it
			// is followed by a decimal point
			if ( ch == '0' )
			{
				input += ch;
				ch = str.charAt(++index);
				
				// make sure no other digits come after 0
				if ( isDigit( ch ) )
				{
					trace( "A digit cannot immediately follow 0" );
					return null;
				}
				// unless we have 0x which starts a hex number, but this
				// doesn't match JSON spec so check for not strict mode.
				else if ( ch == 'x' )
				{
					// include the x in the input
					input += ch;
					ch = str.charAt(++index);
					
					// need at least one hex digit after 0x to
					// be valid
					if ( isHexDigit( ch ) )
					{
						input += ch;
						ch = str.charAt(++index);
					}
					else
					{
						trace( "Number in hex format require at least one hex digit after \"0x\"" );
						return null;
					}
					
					// consume all of the hex values
					while ( isHexDigit( ch ) )
					{
						input += ch;
						ch = str.charAt(++index);
					}
				}
			}
			else
			{
				// read numbers while we can
				while ( isDigit( ch ) )
				{
					input += ch;
					ch = str.charAt(++index);
				}
			}
			
			// check for a decimal value
			if ( ch == '.' )
			{
				input += '.';
				ch = str.charAt(++index);
				
				// after the decimal there has to be a digit
				if ( !isDigit( ch ) )
				{
					trace( "Expecting a digit" );
					return null;
				}
				
				// read more numbers to get the decimal value
				while ( isDigit( ch ) )
				{
					input += ch;
					ch = str.charAt(++index);
				}
			}
			
			// check for scientific notation
			/*if ( ch == 'e' || ch == 'E' )
			{
				input += "e"
				ch = str.charAt(++index);
				// check for sign
				if ( ch == '+' || ch == '-' )
				{
					input += ch;
					ch = str.charAt(++index);
				}
				
				// require at least one number for the exponent
				// in this case
				if ( !isDigit( ch ) )
				{
					trace( "Scientific notation number needs exponent value" );
					return null;
				}
				
				// read in the exponent
				while ( isDigit( ch ) )
				{
					input += ch;
					ch = str.charAt(++index);
				}
			}*/
			
			// convert the string to a number value
			var num:Number = Number( input );
			
			if ( isFinite( num ) && !isNaN( num ) )
			{
				// the token for the number that we've read
				return num;
			}
			else
			{
				trace( "Number " + num + " is not valid!" );
				return null;
			}
			
			return null;
		}
		
		/**
		 * Determines if a character is a digit [0-9].
		 *
		 * @return True if the character passed in is a digit
		 */
		public static function isDigit( ch:String ):Boolean
		{
			return ( ch >= '0' && ch <= '9' );
		}
		
		/**
		 * Determines if a character is a hex digit [0-9A-Fa-f].
		 *
		 * @return True if the character passed in is a hex digit
		 */
		public static function isHexDigit( ch:String ):Boolean
		{
			return ( isDigit( ch ) || ( ch >= 'A' && ch <= 'F' ) || ( ch >= 'a' && ch <= 'f' ) );
		}
	}

}