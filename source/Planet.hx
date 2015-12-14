package;
using flixel.util.FlxSpriteUtil;
import flixel.addons.nape.FlxNapeSprite;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import hxColorToolkit.spaces.Lab;
import hxColorToolkit.spaces.RGB;
import nape.geom.Vec2;
import nape.phys.BodyType;
import flixel.addons.nape.FlxNapeSpace;

class Planet extends FlxNapeSprite
{

	public var barren:Bool;
	public var generateDelay:Float;
	public var deltaE:Float;
	public var info:FlxText;
	public var timer:FlxTimer;
	public var isGoal:Bool;
	public var targetColor:FlxColor;
	public var outerRadius:Float;
	public var critterWidth:Int = 10;
	public var critterHeight:Int = 10;
	public var colorDistanceThreshold:Float = 6.25;
	
	public function new (X:Float, Y:Float, outerRadius:Int, c:FlxColor, barren:Bool) {
		super(X, Y);
		
		generateDelay = 4.0;
		deltaE = 9999;
		isGoal = false;
		this.barren = barren;
		info = new FlxText(X-24,Y-10,0,"",16);
		timer = new FlxTimer();
		timer.start(Reg.rng.float(0.5,generateDelay), callbackToGenerateCritter, 1);
		
		this.outerRadius = outerRadius;
		targetColor = c;
		color = c;
		makeGraphic(outerRadius, outerRadius, FlxColor.TRANSPARENT, true);
		var lineStyle = { color:0xFF808080, pixelHinting : true, thickness:2.0 };
		var radius = width / 2.0 - 4;
		drawCircle(width/2.0,height / 2.0,radius,FlxColor.WHITE,lineStyle);
		createCircularBody(radius, BodyType.STATIC);
		this.body.mass *= 0.65;
		body.space = FlxNapeSpace.space;
		body.cbTypes.add(Collision.cb_PLANET);
		body.setShapeFilters(Collision.filter_PLANET);
		body.userData.owner = this;
		
	}
	
	public function setGoal(targetColor:FlxColor):Void {
		isGoal = true;
		this.targetColor = targetColor;
		var canvas = new FlxSprite(x-width/2,y-width/2);
		canvas.makeGraphic(Std.int(width), Std.int(width), FlxColor.TRANSPARENT, true);
		var radius = width * 0.25;
		canvas.drawCircle(width / 2.0, height / 2.0, radius, FlxColor.WHITE);
		canvas.color = targetColor;
		canvas.alpha = 1.0;
		Reg.state.add(canvas);
		Reg.state.add(info);
	}
	
	public function callbackToGenerateCritter(t:FlxTimer):Void {
		if (!barren && Reg.state.numCritters < Reg.state.maxCritters) {
			var critter = generateCritter();
			Reg.state.add(critter);
			Reg.state.objects.push(critter);
		}
		
		timer.reset(Reg.rng.float(0.5, generateDelay));
	}
	
	public function generateCritter():Critter {
		var cx = body.position.x;
		var cy = body.position.y;
		var theta = Reg.rng.float(0, 2 * Math.PI);
		cx += (outerRadius/2 * Math.cos(theta));
		cy += (outerRadius/2 * Math.sin(theta));
		var critter:Critter = new Critter(cx, cy, critterWidth, critterHeight, color);
		Reg.state.numCritters += 1;
		return critter;
	}
	
	public function shiftColor(otherColor:FlxColor,stepSize:Float):Void {
		color = FlxColor.interpolate(color, otherColor, stepSize);
		//var distance = getColorDistance(color, otherColor);
		//color = distance 
	}
	
	public function reachedTarget():Bool {
		var result:Bool = false;
		//if (targetColor == null) {
			//result = true;
		//} else {
			deltaE = getColorDistance(color,targetColor);
			if (deltaE < colorDistanceThreshold) {
				result = true;
			}
		//}
		return result;
	}
	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		var delta = Std.string(deltaE-colorDistanceThreshold);
		var i = delta.indexOf('.');
		delta=delta.substr(0, i+2);
		info.text = "" + delta;
	}
	
	public static function getColorDistance(color, targetColor):Float {
		var targetLAB = new Lab().setColor(targetColor);
		var currentLAB = new Lab().setColor(color);
		var deltaE = Math.sqrt(
			((targetLAB.getValue(0) - currentLAB.getValue(0)) *
			 (targetLAB.getValue(0) - currentLAB.getValue(0))) +
			((targetLAB.getValue(1) - currentLAB.getValue(1)) *
			 (targetLAB.getValue(1) - currentLAB.getValue(1))) +
			((targetLAB.getValue(2) - currentLAB.getValue(2)) *
			 (targetLAB.getValue(2) - currentLAB.getValue(2)))	
		);
		return deltaE;
	}
	
}