package org.stylekit.css.parse
{
	
	/**
	* This is the class responsible for lexical parsing of CSS code. After a successful parsing operation,
	* a vector of <code>StyleSheet</code> objects is made available on the parser.
	*
	* CSS Parsing is an asynchronous operation.
	*/
	import flash.events.EventDispatcher;
	
	import org.stylekit.css.StyleSheet;
	import org.stylekit.css.style.Style;
	import org.stylekit.css.style.Animation;
	import org.stylekit.css.style.FontFace;
	import org.stylekit.css.style.Import;
	
	public class StyleSheetParser extends EventDispatcher
	{
		// All possible states for the parser as it works through the CSS string.
		protected static var SELECTOR:uint 		= 1; // Parsing a selector
		protected static var PROPERTY:uint 		= 2; // Parsing a property name
		protected static var VALUE:uint 		= 3; // Parsing a property value
		protected static var STRING:uint 		= 4; // Parsing a quoted string
		protected static var COMMENT:uint 		= 5; // Parsing a comment
		protected static var MEDIA:uint 		= 6; // Parsing an @media statement
		protected static var IMPORT:uint 		= 7; // Parsing an @import statement
		protected static var FONTFACE:uint 		= 8; // Parsing an @font-face statement
		protected static var KEYFRAMES:uint 	= 9; // Parsing an @keyframes block
		protected static var KEYFRAME:uint 		= 10; // Parsing a keyframe description within an @keyframes block
		
		// Parser state
		// --------------------------------------------------------------
		
		/**
		* The StyleSheet instance currently being built by the parser.
		*/
		protected var _styleSheet:StyleSheet;
		
		/**
		* The Style instance currently being built by the parser.
		*/
		
		protected var _currentStyle:Style;
		
		/**
		* The token currently being collected by the parser
		*/
		protected var _token:String;
		
		/**
		* Keeps track of the CSS code's nesting as a series of nested states.
		*/
		protected var _stateStack:Vector.<uint>;
		
		/**
		* Maintains a list of parsed Style objects.
		*/
		protected var _styleStack:Vector.<Style>;
		
		/** 
		* Maintains a list of parsed Animation objects.
		*/
		protected var _animationStack:Vector.<Animation>;
		
		/**
		* Maintains a list of parsed FontFace objects.
		*/
		protected var _fontFaceStack:Vector.<FontFace>;
		
		/**
		* Maintains a list of parsed Import objects.
		*/
		protected var _importStack:Vector.<Import>;
		
		/**
		* When parsing a quoted string, this variable holds the quote character used to enter the string state - the same character
		* will be required in order to exit the string state.
		*/	
		protected var _stringStateExitChar:String;
		
		// Option flags
		// --------------------------------------------------------------
		
		
		
		/**
		* Creates a new StyleSheetParser instance.
		* @constructor
		*/
		public function StyleSheetParser()
		{
		}
		
		/**
		* Begins parsing a chunk of CSS code. In the event an external stylesheet being parsed, an optional second argument <code>url</code> may be given.
		* The <code>url</code> argument should be set to the URL from which the CSS was loaded and will be used for resolving relative paths for any external
		* assets mentioned in the CSS code.
		*/
		public function parse(css:String, url:String=""):void
		{
			this.resetState();
			
			// Start a character-by-character loop over the given CSS.
			for(var i:uint=0; i < css.length; i++) {
				var char:String = css.charAt(i);
				
				if(this.currentState != StyleSheetParser.COMMENT && this.currentState != StyleSheetParser.STRING)
				{
					// Entering a comment state
					if(css.substr(i, 2) == "/*") {
						i++; // We don't need to scan the next character so let's just skip it
						this.debug("Encountered comment start, entering comment state", this);
						this.enterState(StyleSheetParser.COMMENT);
						continue;
					}
					// Entering a string state
					else if(char == "'" || char == '"' || char == "(")
					{
						this.enterState(StyleSheetParser.STRING);
						this._stringStateExitChar = (char == "(")? ")" : char;
						this._token += char;
						this.debug("Encountered string start, entering string state", this);
						continue;
					}
				}
				
				
				switch(this.currentState)
				{
					// During a comment block
					case StyleSheetParser.COMMENT:
						// During a comment block, all content is ignored until we encounter the */ signal.
						if(css.substr(i,2) == "*/")
						{
							i++; // We don't need to scan the next character so let's just skip it
							this.debug("Encountered comment end", this);
							this.exitState();
						}
						break;
					// During a string block
					case StyleSheetParser.STRING:
						// During a string block, all content is appended to the current token.
						// If we meet the current _stringStateExitChar, then the string block state is exited.
						if(char == this._stringStateExitChar)
						{
							this.debug("Encountered string end character during string state", this);
							this.exitState();							
						}
						this._token += char;
						break;
					// During an import statement
					case StyleSheetParser.IMPORT:
						// In an import statement, we let the token build until the statement is terminated with a semicolon.
						if(char == ";")
						{
							// Ending the import statement. 
							// TODO Throw the token into an Import object at the current style index.
							// Kill the token and exit the state
							this.debug("Ending import state, about to clear token", this);
							this._token = "";
							this.exitState();
						}
						else
						{
							// Not ending the import statement just yet. Keep building the token.
							this._token += char;
						}
						break;
					// During a font-face statement
					case StyleSheetParser.FONTFACE:
						// @font-face statements are blocks much like regular selector statements, but they have no selector 
						// text - therefore no token accumulation needs to happen here. We simply watch for the { character
						// and enter the property state when it arrives.
						if(char == "{")
						{
							// Entering the property descriptor block, switch to property state
							this.debug("Found entering brace for at-font-face block, about to enter property state", this);
							this._token = "";
							this.enterState(StyleSheetParser.PROPERTY);
						}
						else if(char == "}")
						{
							// Exiting property descriptor block for the @font-face
							this.debug("Found closing brace for at-font-face block, about to exit state", this);
							this._token = "";
							this.exitState();
						}
						break;
					// During an @media rule
					case StyleSheetParser.MEDIA:
						break;
					// During a selector state
					case StyleSheetParser.SELECTOR:
						// SELECTOR is something of a default state for the parser, so this case mainly contains exit criteria for going to other states.
						if(char == "{")
						{
							// Entering the property block
							this.debug("Found selector '"+this._token+"'. Entering selector's property array, switching to property state. ", this);
							this._token = "";
							this.enterState(StyleSheetParser.PROPERTY);
						}
						else if(char == "}")
						{
							// Exiting a block associated with this selector
							this._token = "";
							this.debug("Reached end of selector block, exiting selector state", this);
							this.exitState();
						}
						else if(char == "@")
						{
							// Entering a special selector. Exit the state and rewind the loop.
							this._token = "";
							this.debug("Selector state encountered an at-selector, rewinding loop and entering special case", this);
							this.exitState();
							i--;
						}
						else
						{
							// Continuing the selector block
							this._token += char;
						}
						break;
					// During a property state
					case StyleSheetParser.PROPERTY:
						// Properties can belong to a number of objects - we must use the state stack to determine
						// which property-inheritable state has been entered more recently.
						// Properties are supported on selectors, font-faces, and keyframe descriptors.
						if(char == ":")
						{
							// On encountering a colon, we've reached the end of the property key and can start parsing the value.
							this.debug("Found property '"+this._token+"'. about to enter value state to parse property value", this);
							this._token = "";
							this.enterState(StyleSheetParser.VALUE);
						}
						else if(char == "}")
						{
							// When exiting from a value state, we may encounter the end of this block.
							this.debug("Found closing brace, about to exit property state to search for a new selector", this);
							this._token = "";
							this.nullifyState();
						}
						else
						{
							this._token += char;
						}
						break;
					// During a value state
					case StyleSheetParser.VALUE:
						if(char == ";" || char == "}") // We allow a closing brace to end the value statement
						{
							this.debug("Found property value. about to exit value state", this);
							this._token = "";
							this.exitState();
							if(char == "}")
							{
								// However if the exit character was a closing brace then we exit twice to get back to the selector state.
								this.exitState();
							}
						}
						else if(css.substr(i, 10) == "!important")
						{
							// Special value exit - the !important flag is registered but not appended to the value token.
							this.debug("Found !important property value '"+this._token+"'. about to exit value state", this);
							this._token = "";
							this.exitState();
						}
						else
						{
							this._token += char;
						}
						break;
					// During an @keyframes state
					case StyleSheetParser.KEYFRAMES:
						// Accumulate the keyframeset name, then expect an opening brace. Then expect a keyframe name followed by another opening brace.
						if(char == "{")
						{
							// Found the keyframes block name
							this.debug("Found at-keyframe set '"+this._token+"'. About to look for keyframe descriptors.", this);
							this._token = "";
							this.enterState(StyleSheetParser.KEYFRAME);
						}
						else if(char == "}")
						{
							// End the keyframes block
							this.debug("Found closing brace for at-keyframe set, about to exit state", this);
							this._token = "";
							this.exitState();
						}
						else
						{
							this._token += char;
						}
						break;
					// During a keyframe state within an @keyframes state
					case StyleSheetParser.KEYFRAME:
						if(char == "{")
						{
							// Finished collecting a keyframe descriptor
							this.debug("Found individual keyframe descriptor '"+this._token+"', about to look for properties", this);
						}
						else if(char == "}")
						{
							// finished a keyframe descriptor block
							this.debug("Found exit brace for keyframe descriptor.", this);
						}
						else
						{
							this._token += char;
						}
						break;
					default:
						// Whitespace is skipped
						if(char != " ")
						{
							// Entering an @keyframes block
							if(css.substr(i, 10) == "@keyframes")
							{
								this.debug("Encountered at-keyframes statement, entering keyframes state", this);
								this.enterState(StyleSheetParser.KEYFRAMES);
								i = i+10;
								continue;
							}
							// Entering an @media rule
							else if(css.substr(i, 6) == "@media")
							{
								this.debug("Encountered at-media statement, entering at-media state", this);
								this.enterState(StyleSheetParser.MEDIA);
								i = i+6;
								continue;
							}
							// Entering an @import statement
							else if(css.substr(i, 7) == "@import")
							{
								this.debug("Encountered at-import statement, entering at-import state", this);
								this.enterState(StyleSheetParser.IMPORT);
								i = i+7;
								continue;
							}
							// Entering a font-face statement
							else if(css.substr(i, 10) == "@font-face")
							{
								this.debug("Encountered at-font-face statement, entering at-font-face state", this);
								this.enterState(StyleSheetParser.FONTFACE);
								i = i+10;
								continue;
							}
							// Default of defaults: Look for a selector!
							else
							{
								this.enterState(StyleSheetParser.SELECTOR);
							}
						}
						// Keep building the token
						this._token += char;
						break;
				}
			}
		}
		
		protected function resetState():void
		{
			this.debug("Resetting parser state for new parse operation", this);
			this._styleSheet = new StyleSheet();			
			this._stateStack = new Vector.<uint>();
			this._styleStack = new Vector.<Style>();
			this._animationStack = new Vector.<Animation>();
			this._fontFaceStack = new Vector.<FontFace>();
			this._token = "";
		}
		
		protected function enterState(state:uint):void
		{
			// Duplicate states are not allowed to stack
			if(this.currentState != state) 
			{
				this._stateStack.push(state);
			}
		}
		
		protected function exitState():void
		{
			this._stateStack.pop();
		}
		
		/**
		* Rather than exiting a single state, resets the state stack entirely to exit ALL states.
		*/
		protected function nullifyState():void
		{
			this._stateStack = new Vector.<uint>();
		}
		
		protected function get currentState():uint
		{
			if(this._stateStack.length < 1) return 0;
			return this._stateStack[this._stateStack.length-1];
		}
		
		protected function get previousState():uint
		{
			if(this._stateStack.length <= 1) return 0;
			return this._stateStack[this._stateStack.length-2];
		}
		
		/**
		* Returns true if the state stack contains the given state (i.e. if we are activey processing in, or nested within, the specified state)
		*/
		protected function inState(state:uint):Boolean
		{
			return (this._stateStack.indexOf(state) > -1);
		}
		
		protected function get currentAnimation():Animation
		{
			return this._animationStack[this._animationStack.length-1];
		}
		
		protected function get currentFontFace():FontFace
		{
			return this._fontFaceStack[this._fontFaceStack.length-1];
		}
		
		protected function get currentImport():Import
		{
			return this._importStack[this._importStack.length-1];
		}
		
		// TODO DELETEME when adam adds UtilKit to the mix
		public var logs:Vector.<String>;
		protected function debug(message:String, target:Object):void
		{
			if(!this.logs) this.logs = new Vector.<String>();
			this.logs.push(message);
		}
	}
	
}