package;
using flixel.util.FlxSpriteUtil;
import flixel.addons.nape.*;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import nape.constraint.WeldJoint;
import nape.constraint.PivotJoint;
import nape.geom.Vec2;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.*;
import nape.geom.Geom;
import nape.callbacks.InteractionCallback;
import flixel.addons.effects.FlxWaveSprite;
import flixel.addons.effects.FlxWaveSprite.FlxWaveMode;
import flixel.addons.display.FlxStarField;
import openfl.Assets;
import flixel.addons.ui.FlxButtonPlus;
import haxe.Json;

class MenuState extends FlxState {

	public var instructions:FlxSprite;
	public var playGame:FlxButtonPlus;
	public var instBtn:FlxButtonPlus;
	public var sandboxBtn:FlxButtonPlus;
	public var unlimitedBtn:FlxButtonPlus;
	public var bg:FlxStarField2D;
	public var canvas:FlxSprite;
	public var inst:FlxText;
	
	override public function create():Void {
		super.create();
		
		Reg.init();
		FlxG.mouse.visible = true;
		
		//FlxG.sound.playMusic(Assets.getMusic("assets/music/"+Reg.rng.getObject(Reg.songList)+".mp3"), 1, true);
		FlxG.sound.playMusic(Assets.getMusic("assets/music/bu-a-walking-body.mp3"), 1, true);
		
		bg = new FlxStarField2D(0, 0, FlxG.width, FlxG.height, 300);
		bg.setStarSpeed(1, 75);
		add(bg);
		
		canvas = new FlxSprite(0, 0);
		canvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		var lineStyle:LineStyle = { color: FlxColor.BLACK, thickness: 2};
		FlxSpriteUtil.drawCircle(canvas, -1, -1, 250, FlxColor.GRAY, lineStyle);
		add(canvas);
		
		var title = new FlxSprite(0, 0);
		title.loadGraphic("assets/images/title.png");
		add(title);
		
		FlxG.camera.flash(FlxColor.WHITE, 1, null, true);
		
		
		add(new FlxSprite(FlxG.width/2 - 25, FlxG.height - 35, Assets.getBitmapData("assets/images/ufo.png")));
		
		instBtn = new FlxButtonPlus(FlxG.width / 2 - 50, 255, showInstructions, "INSTRUCTIONS");
		instBtn.updateInactiveButtonColors([FlxColor.BLUE, FlxColor.BLACK]);
		add(instBtn);
		playGame = new FlxButtonPlus(FlxG.width / 2 - 50, 285, startGame, "PLAY GAME");
		playGame.updateInactiveButtonColors([FlxColor.BLUE, FlxColor.BLACK]);
		add(playGame);
		var endlessBtn = new FlxButtonPlus(FlxG.width / 2 - 50, 315, playEndless, "ENDLESS MODE");
		endlessBtn.updateInactiveButtonColors([FlxColor.BLUE, FlxColor.BLACK]);
		add(endlessBtn);
		
		
		instructions = new FlxSprite(0, FlxG.height - 125);
		instructions.makeGraphic(FlxG.width, 120, FlxColor.BLACK);
		var instText:String = 	"You pilot a UFO and must change the colors of planets by moving dudes.\n";
		instText += 			"Hold the left mouse button to activate your tractor beam and pull\n";
		instText +=				"dudes close to you. Be careful, they will die if thrown too hard!\n";
		instText += 			"Every time a dude bounces on a planet, the planet's color changes.\nMost planets will produce new dudes of their color.\n";
		inst = new FlxText(0, FlxG.height - 125, 0, instText, 16);
		add(instructions);
		add(inst);
		inst.kill();
		instructions.kill();
	
	}
	public function startGame():Void {
		Reg.endless = false;
		FlxG.switchState(new PlayState());
	}
	
	public function startSandbox():Void {
		FlxG.switchState(new PlayState());
	}
	public function showInstructions():Void {
		instructions.revive();
		inst.revive();
	}
	
	public function playEndless():Void {
		Reg.endless = true;
		Reg.randomizePlanets(); 
		FlxG.switchState(new PlayState());
	}
	
	override public function destroy():Void {
		super.destroy();
	}

	override public function update(elapsed:Float):Void {
		if (FlxG.keys.anyJustPressed(["M"])) {
			if (FlxG.sound.music.active == true) {
				FlxG.sound.music.stop();
			}else {
				FlxG.sound.music.play();
			}
		}

		super.update(elapsed);
	}	
}