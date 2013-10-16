package january.music
{
	import january.*;
	
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxMath;

	public class Key
	{		
		/* Musical keys, stored in Arrays. */
		public static const C_MAJOR		: Array = ["C Major", C1, D1, E1, F1, G1, A1, B1, C2, D2, E2, F2, G2, A2, B2, C3, D3, E3, F3, G3, A3, B3, C4, D4, E4, F4, G4, A4, B4];
		public static const C_MINOR		: Array = ["C Minor", C1, D1, Ds1, F1, G1, Gs1, As1, C2, D2, Ds2, F2, G2, Gs2, As2, C3, D3, Ds3, F3, G3, Gs3, As3, C4, D4, Ds4, F4, G4, Gs4, As4]
		//public static const WHOLETONE	: Array = ["Wholetone", C1, D1, E1, Fs1, Gs1, As1, C2, D2, E2, Fs2, Gs2, As2, C3, D3, E3, Fs3, Gs3, As3, C4];
		/** Array of all the keys. */
		public static const DATABASE	: Array = [C_MAJOR, C_MINOR];
		/** Number used with key array to select and identify the current key. */
		public static var index			: int = Helper.randInt(0, DATABASE.length - 1);
		/** The current key, and the string equivalent of keyIndex. */
		public static var current		: String = DATABASE[index][0];
		/** Whether or not the key has been just changed. */
		public static var justChanged	: Boolean;
		
		/** Array of all possible key letters. */
		public static const LETTERS: Array = ["C", "D", "E", "F", "G", "A", "B", "C"];
	
		public static function change():void
		{
			var newIndex:int = Helper.randInt(0, DATABASE.length - 1);
			while (newIndex == index)
				newIndex = Helper.randInt(0, DATABASE.length - 1);			
			index = newIndex;
			current = DATABASE[index][0];
			Intervals.updated = false;
			Intervals.populate();
			
			// Prevent tensions on playback mode key changes.
			if (Playback.mode == "Repeat")
			{
				var currentInterval:String = Playback.sequence[Playback.index];
				var avoidIntervals: Array = ["two1", "for1", "six1", "for2", "six2", "for3", "six3"];
				
				for each (var intervalToAvoid:String in avoidIntervals)
				{
					if (currentInterval == intervalToAvoid)
					{
						// Shift the interval for the next note to be played up or down one spot, to a chord tone.
						for (var i:int = 0; i < Intervals.DATABASE.length - 1; i++)
						{
							if (currentInterval == Intervals.DATABASE[i])
							{
								Playback.sequence[Playback.index] = Intervals.DATABASE[i + FlxMath.randomSign()];
								break;
							}
						}
					}
				}
			}
			
			justChanged = true;
			
			HUD.logMode();
		}
		
		public static function cycle():void
		{	
			change();
			Game.feedback.show(HUD.modeName);
		}
	}
}