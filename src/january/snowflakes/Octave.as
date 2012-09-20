package january.snowflakes
{
	import january.*;
	import org.flixel.*;
	
	public class Octave extends Snowflake
	{	
		[Embed(source="../assets/art/flakes/octave.png")] private var sprite : Class;
		
		public function Octave():void
		{
			super();
			
			loadGraphic(sprite);
			
			_pointValue = 1;
			noteVolume = Helpers.rand(0.1, 0.25);
		}
		
		public override function onLick():void
		{
			super.onLick();
			
			Music.generate(noteVolume, x);	
			Music.octave();				
		}
	}
}