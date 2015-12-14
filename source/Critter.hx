package;
using flixel.util.FlxSpriteUtil;
import flixel.addons.nape.FlxNapeSprite;
import flixel.addons.nape.FlxNapeSpace;
import flixel.util.FlxColor;

class Critter extends FlxNapeSprite {

	public function new(X:Float, Y:Float, W:Int, H:Int, color:FlxColor = FlxColor.WHITE) {
		super(X, Y);
		var roll = Reg.rng.int(0, 2);
		loadGraphic("assets/images/dude.png");
		//loadGraphic("assets/images/"+Reg.rng.getObject(["dude","legs","long","feet","tail","cross"])+".png");
		createRectangularBody(width, height);
		
		this.color = color;
		body.space = FlxNapeSpace.space;
		body.cbTypes.add(Collision.cb_CRITTER);
		body.setShapeFilters(Collision.filter_CRITTER);
		body.userData.owner = this;
	}
	
}