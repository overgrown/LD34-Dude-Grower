package;

import flixel.addons.ui.FlxButtonPlus;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.Assets;


class LoseState extends FlxState {
	
	public var emitter:FlxEmitter;
	
	override public function create():Void
	{
		FlxG.mouse.visible = true;
		emitter = new FlxEmitter();
		add(emitter);
		emitter.x = Reg.rng.int(0, FlxG.width);
		emitter.y = Reg.rng.int(0, FlxG.height);
		var mainText = "YOU FAILED!";
		emitter.loadParticles(Assets.getBitmapData("assets/images/dude.png"), 500, 0, false);
		if (Reg.success) {
			emitter.color.set(FlxColor.BLACK, FlxColor.WHITE, FlxColor.WHITE, FlxColor.BLACK);
			mainText = "Congratulations! YOU GREW SOME DUDES. YOU WIN.\n(now try endless mode)";
		}
		emitter.start(true, 0, 10);
		
		add(new FlxText(100, 100, 0, mainText, 16));
		
		add(new FlxText(100, 140, 0, "FINAL SCORE: "+Reg.score+"\nDUDES WHO DIDN'T MAKE IT: "+Reg.numDead, 16));
		
		var btn:FlxButtonPlus = new FlxButtonPlus(100, 220, retry, "RETRY LAST LEVEL");
		btn.updateInactiveButtonColors([FlxColor.BLUE, FlxColor.BLACK]);
		add(btn);
		
		var btn2:FlxButtonPlus = new FlxButtonPlus(100, 260, goToMenu, "GO TO MENU");
		btn2.updateInactiveButtonColors([FlxColor.BLUE, FlxColor.BLACK]);
		add(btn2);
		
		super.create();
	}
	
	public function goToMenu():Void {
		FlxG.switchState(new MenuState());
	}
	
	public function retry():Void {
		FlxG.switchState(new PlayState());
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update(elapsed:Float):Void
	{
		if (Reg.rng.int(0, 20) < 1) {
			emitter.x = Reg.rng.int(0, FlxG.width);
			emitter.y = Reg.rng.int(0, FlxG.height);
			emitter.start(true, 0 , 10);
		}
		super.update(elapsed);
	}	
}