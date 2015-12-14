package;
import nape.callbacks.InteractionType;
import nape.dynamics.InteractionFilter;
import nape.callbacks.CbType;
import nape.callbacks.CbEvent;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionCallback;
import flixel.addons.nape.FlxNapeSpace;

class Collision {
	public static var cb_PLANET = new CbType();
	public static var cb_UFO = new CbType();
	public static var cb_CRITTER = new CbType();
	public static var g_PLANET:Int = 1;
	public static var g_UFO:Int = 2;
	public static var g_CRITTER:Int  = 4;
	public static var cmask_PLANET:Int = (g_UFO | g_CRITTER);
	public static var cmask_UFO:Int = (g_PLANET | g_CRITTER);
	public static var cmask_CRITTER:Int = (g_PLANET | g_UFO | g_CRITTER);
	public static var filter_PLANET:InteractionFilter = new InteractionFilter(g_PLANET, cmask_PLANET);
	public static var filter_CRITTER:InteractionFilter = new InteractionFilter(g_CRITTER, cmask_CRITTER);
	public static var filter_UFO:InteractionFilter = new InteractionFilter(g_UFO, cmask_UFO);

	public function new() {
		
	}
	
	
	public static function addListener(op1:CbType, op2:CbType, cb:InteractionCallback->Void, type = null, event = null):Void {
		if (type == null) {
			type = InteractionType.COLLISION;
		}
		if (event == null) {
			event = CbEvent.BEGIN;
		}
		FlxNapeSpace.space.listeners.add(new InteractionListener(event,type,op1,op2,cb));
	}
	
}