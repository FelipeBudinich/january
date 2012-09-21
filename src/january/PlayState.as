package january
{			
	import january.colorlayers.*;
	import january.snowflakes.*;
	
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	
	public class PlayState extends FlxState
	{
		[Embed(source = "../assets/maps/level.txt", mimeType = "application/octet-stream")] protected var _levelMap: Class;
		[Embed(source = "../assets/maps/trees.txt", mimeType = "application/octet-stream")] protected var _treeMap : Class;
		[Embed(source = "../assets/maps/sky.txt", mimeType = "application/octet-stream")] 	protected var _skyMap  : Class;
		
		[Embed(source = "../assets/art/ground.png")] 	protected var _groundImg: Class;
		[Embed(source = "../assets/art/trees.png")] 	protected var _treeImg	: Class;
		[Embed(source = "../assets/art/sky.png")] 		protected var _skyImg	: Class;
		[Embed(source = "../assets/art/cabin.png")]		protected var _houseImg : Class;
		
		//SOUNDS
		[Embed(source = "../assets/audio/ambience.swf", symbol = "snow_01.aif")] protected var _ambience: Class;
		[Embed(source = "../assets/audio/door_open.mp3")] 						 protected var _doorOpen: Class;
		[Embed(source = "../assets/audio/door_close.mp3")] 						 protected var _doorClose:Class;
		
		public static var HUDkey  : FlxText;
		public static var HUDnote : FlxText;
		public static var HUDevent: FlxText;
		
		public static var dusk:  Dusk;
		public static var haze:  Haze;
		public static var night: Night;
		public static var black: Black;
		
		public static var storyData:  StoryData;
		public static var strings: 	  Array;
		public static var textOutput: Text;
		
		protected var _ground: FlxTilemap;
		protected var _trees : FlxTilemap;
		protected var _sky 	 : FlxSprite;
		
		public static var houseLeft : FlxSprite;
		public static var houseRight: FlxSprite;
		
		public static var player: Player;
		public static var snow 	: FlxGroup;
		
		public static var camera: FlxCamera;
		public static var cameraRails: FlxSprite;
		public static var startingX: Number = 420;
		
		protected var _spawnTimer: FlxDelay;
		protected var _resetTime: int;
		
		override public function create():void
		{					
			//	Kill Mouse, Initialize Score.
			FlxG.mouse.hide();
			FlxG.score = 0;
			
			//	Play Background Audio
			FlxG.play(_ambience, 2, 0, true).fadeIn(1);
			
			//	Set Background Color
			FlxG.bgColor = 0xFFd8e3e5;

			
			//	Build Skymap		
				_sky = new FlxSprite(0, 0, _skyImg);
				_sky.scrollFactor.x = 0;
				_sky.velocity.x = -2;
			add(_sky);
			
			//	Build Tilemap
				_ground = new FlxTilemap();
				_ground.loadMap(new _levelMap, _groundImg, 16);
				_ground.x = 0;
			add(_ground);
			
			//	Set World Bounds, for optimization purposes.
			FlxG.worldBounds.x = 160;
			FlxG.worldBounds.y = 0;
			FlxG.worldBounds.width = _ground.width - 160;
			FlxG.worldBounds.height = FlxG.height;
			
			//	Build Treemap
				_trees = new FlxTilemap();
				_trees.y = 83;
				_trees.scrollFactor.x = 0.25;
				_trees.loadMap(new _treeMap, _treeImg, 51, 15);
			add(_trees);				
			
			// Add Feedback Text
				textOutput = new Text();
			add(textOutput);
			
			// Draw Player
				player = new Player();
			add(player);
			add(player.tongueBox);
			
			//	Build Houses
				houseLeft = new FlxSprite(50, 16);
				houseLeft.loadGraphic(_houseImg,false,true);
				houseLeft.facing = FlxObject.LEFT;
			add(houseLeft);
			
				houseRight = new FlxSprite(2768, 16, _houseImg);
			add(houseRight);
						
			// Create Snow
				snow = new FlxGroup();
			add(snow);
			
			// Create Backgrounds (keep order in tact for proper blending)
				dusk  = new Dusk();
				haze  = new Haze();
				night = new Night();
				black = new Black();
			add(dusk);
			add(haze);
			add(night);
			add(black);
			
			// Add HUD
			addHUD();
			
			// Create Camera and Camera Rails (Camera Follows Rails Object)										
				cameraRails = new FlxSprite(startingX + FlxG.width + 1, FlxG.height - 1);
				cameraRails.makeGraphic(1,1,0xFFFF0000);
				//cameraRails.alpha = 0;
			add(cameraRails);
			
				camera = new FlxCamera(0, 0, FlxG.width + 1, FlxG.height);
				camera.setBounds(startingX, 0, _ground.width, FlxG.height);
				camera.deadzone = new FlxRect(0, 0, FlxG.width + 1, FlxG.height);
				camera.target = cameraRails;
			add(camera);
			
			FlxG.resetCameras(camera);
			
			// Prepare Story
			storyData = new StoryData();
			  strings = storyData.toString().split("\n");
			
			// Start Spawn Timer
			_spawnTimer = new FlxDelay(6000);
			_spawnTimer.start();
			
			super.create();
		}
		
		override public function update():void
		{																
			// Spawn snowflakes when timer expires.
			_spawnTimer.callback =
				function():void
				{				
					if (Text.storyOver == false && FlxG.score == 0)
						_spawnTimer.reset(12000);
					else
					{
						if (_resetTime < 25)
							_resetTime = 25;
						
						FlxG.log(_resetTime);
						_spawnTimer.reset(_resetTime);						
					}
					
					Snowflake.manage();
				}
			
			super.update();	
			
			// Loop Sky Background
			if (_sky.x < -716) _sky.x = 0;
			
			// Toggle HUD
			toggleHUD();
			
			// Collision Check
			FlxG.overlap(snow, player.tongueBox, onLick);
			FlxG.overlap(snow, player, player.onOverlap);
			
			// Camera Logic
			if (camera.scroll.x >= _ground.width - FlxG.width)
			{
				cameraRails.acceleration.x = -5;
				if (cameraRails.velocity.x <= 0)
					cameraRails.velocity.x = 0;
			}
				
			else if (player.x <= camera.scroll.x + 25)
			{
				cameraRails.drag.x = 5;
				if (cameraRails.velocity.x <= 0)
				{
					cameraRails.velocity.x = 0;
					cameraRails.drag.x = 0;
				}
			}
			else if (FlxG.score > 0)
			{
				cameraRails.acceleration.x = 10;	
				if (cameraRails.velocity.x >= 10)
				{
					cameraRails.velocity.x = 10;
					cameraRails.acceleration.x = 0;
				}					
			}
		}
		
		/**
		 * Called when the overlap check for snow and player passes.
		 * Runs the various onLick functions!
		 */
		public function onLick(SnowRef: Snowflake, TongueRef: FlxSprite):void
		{
			var pressedUpKey:Boolean = FlxG.keys.UP || FlxG.keys.W;
			if (pressedUpKey)
			{
				SnowRef.onLick();
				textOutput.onLick(SnowRef.type);
				haze.onLick();
				dusk.onLick();
				night.onLick();
				
				_resetTime = 200 - (FlxG.score * 10);
			}
				
		}
		
		/**
		 * Instantiates HUD.
		 */
		public function addHUD() : void
		{				
			// Add Last Note Text
			HUDnote = new FlxText(10, 8, 256, "Note: ");
			HUDnote.alignment = "left";
			HUDnote.scrollFactor.x = 0;
			add(HUDnote);
			
			// Add Event Text
			HUDevent = new FlxText(125, 8, 256, "Event: ");
			HUDevent.alignment = "left";
			HUDevent.scrollFactor.x = 0;
			add(HUDevent);
			
			// Add Key Text
			HUDkey = new FlxText(225, 8, 256, "Key: ");
			HUDkey.alignment = "left";
			HUDkey.scrollFactor.x = 0;
			add(HUDkey);
			
			// Hide HUD by default.
			HUDkey.exists 	= false;
			HUDnote.exists 	= false;
			HUDevent.exists = false;
		}
		
		/**
		 * Turns HUD on or off.
		 */ 
		public function toggleHUD() : void
		{
			if(FlxG.keys.justPressed("H") == true)
			{
				HUDkey.exists   = !HUDkey.exists;
				HUDnote.exists  = !HUDnote.exists;
				HUDevent.exists = !HUDevent.exists;
			}
			
		}
		


	}
}