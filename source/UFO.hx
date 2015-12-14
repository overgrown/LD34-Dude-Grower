package;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import nape.phys.BodyType;
import nape.phys.Material;

class UFO extends FlxNapeSprite {

	public function new(X,Y) {
		super(X, Y);
		loadGraphic("assets/images/ufo.png", false);
		createRectangularBody(24, 10, BodyType.DYNAMIC);
		
		body.allowRotation = false;
		body.mass *= 2.4;
		body.space = FlxNapeSpace.space;
		body.cbTypes.add(Collision.cb_UFO);
		body.setShapeFilters(Collision.filter_UFO);
		body.userData.owner = this;
		
		setBodyMaterial(0, 1, 1, 1, 1);
	}
	
}