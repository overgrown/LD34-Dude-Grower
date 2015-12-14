package;
import flixel.FlxG;
import flixel.math.FlxRandom;
import flixel.util.helpers.FlxBounds;
import flixel.util.helpers.FlxRangeBounds;
import haxe.Json;
import flixel.util.FlxColor;
import openfl.Assets;

class Reg {

	public static var endless:Bool;
	public static var rng:FlxRandom;
	public static var state:PlayState;
	public static var levels:Array<Dynamic>;
	public static var levelIndex:Int;
	public static var score:Float = 0;
	public static var numDead:Float = 0;
	public static var success:Bool = false;
	
	public static var songList:Array<String> = ["bu-a-walking-body", "bu-a-white-road"];
	
	public static function init() {
		FlxG.mouse.visible = false;
		rng = new FlxRandom();
		loadLevels();
		levelIndex = 0;
	}
	
	public static function loadLevels():Void {
		var levelData = Json.parse(Assets.getText("assets/data/levels.json"));
		levels = levelData.levels;
	}
	
	public static function randomizePlanets():Void {
		Reg.levelIndex = 0;
		var planets:Array<Dynamic> = [
            {
                "color"   : "0xFF0000FF",
                "x"       : 60,
                "y"       : 60,
                "radius"  : 125
            },
            {
                "color"   : "0xFF00FF00",
                "x"       : 740,
                "y"       : 60,
                "radius"  : 125
            },
            {
                "color"   : "0xFFFF00FF",
                "x"       : 30,
                "y"       : 300,
                "radius"  : 95
            },
            {
                "color"   : "0xFFFF0000",
                "x"       : 60,
                "y"       : 540,
                "radius"  : 125
            },
            {
                "color"   : "0xFF00FFFF",
                "x"       : 770,
                "y"       : 300,
                "radius"  : 95
            },
            {
                "color"   : "0xFFFFFF00",
                "x"       : 740,
                "y"       : 540,
                "radius"  : 125
            },
            {
                "color"   : "0xFFFFFFFF",
                "x"       : 400,
                "y"       : 300,
                "radius"  : 250,
                "target"  : Std.string(Reg.rng.color(FlxColor.BLACK, FlxColor.WHITE))
            }
			
			];
		Reg.levels = [ { "maxCritters" : 60, "levelText" : "Endless mode! If it looks impossible, just press retry to get a new level",
			"planets" : planets
			} ];
	}

	
}