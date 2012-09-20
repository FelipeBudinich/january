package january
{
	import january.snowflakes.*;
	
	import org.flixel.*;
	
		public class Text extends FlxText
		{
	        [Embed(source="../assets/frucade.ttf", fontFamily="frucade", embedAsCFF="false")] public var customFont:String;
	
	        /** The number of seconds to hold the text before it starts to fade. */
	        private var _lifespan: Number;
	
			/** The gutter size, used to keep text off screen edges. */
			private var _gutter: Number = 10;
			
			/** Whether the story is over or not. */
		   	public var storyOver: Boolean;
		
			/** The new score, once the story is over. Takes over for FlxG.score */
			public static var newScore: Number = 0;
			    
	        public function Text():void
			{
				x = -15;
				y = -15;
				width = 200;
				
	            super(x,y,width);
	
				velocity.y = -8;
	
	            setFormat("frucade");
	            alpha = 0;
	        }
	
			/**
			 * show() - 
			 *  
			 * @param Text
			 * @param X
			 * @param Y
			 * 
			 */			
	        public function show(Text:String, X: Number, Y: Number):void
			{
			    
			}
	
			/**
			 * onLick() - Figures out what text to display next, and where to display it so it looks nice.
			 *  
			 * @param flakeType
			 * 
			 */			
			public function onLick(flakeType: String):void
			{							
				var _text: String = "";
				
				// What to show during the story.
				if (storyOver == false)
				{
					// Ignore Small flakes, otherwise move story forward!
					if (FlxG.score > 2 && flakeType == "Small")
						null;
					else
						_text = PlayState.strings[FlxG.score-1];
				
					if (FlxG.score == PlayState.strings.length + 1)
						storyOver = true;
				}
				
				// What to show after the story is over.
				if (storyOver == true)
				{					
					newScore = FlxG.score - PlayState.strings.length;
					
					if (newScore != 0 && newScore % 10 == 0)
						_text = newScore.toString() + ".";
				}
				
				
				//_text = "This is a longer test.";
				
				// Show the new text feedback.
				if (_text != "")
				{
					_lifespan = 1.75;        
					text = _text;
					alpha = 1;
					x = PlayState.player.x;
					y = PlayState.player.y - 20;
					
					if (PlayState.player.facing == LEFT)
					{
						x -= realWidth + 4;
						
						// Check Bounds on Left Side
						if (PlayState.player.x - realWidth < _gutter)
							x = _gutter;	
					}
					else // facing == RIGHT
					{
						x -= 4;
						
						// Check Bounds on Right Side
						if (PlayState.player.x + realWidth > FlxG.width - _gutter)
							x = FlxG.width - _gutter - realWidth;
					}
					
				}
				
			}
		
			override public function update():void
			{
				super.update();
				
				if (_lifespan > 0)
					_lifespan -= FlxG.elapsed;
				else
					alpha -= FlxG.elapsed;
					
				if (alpha < 0)
					alpha = 0;
			}
		
	    }
		
}