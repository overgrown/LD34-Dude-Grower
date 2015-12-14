package;
using flixel.util.FlxSpriteUtil;
import flixel.addons.display.FlxStarField.FlxStarField2D;
import flixel.addons.effects.FlxWaveSprite;
import flixel.addons.effects.FlxWaveSprite.FlxWaveMode;
import flixel.addons.nape.*;
import flixel.addons.text.FlxTypeText;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import nape.callbacks.InteractionCallback;
import nape.constraint.PivotJoint;
import nape.constraint.DistanceJoint;
import nape.geom.Vec2;
import flixel.addons.ui.FlxButtonPlus;
import nape.shape.*;

class PlayState extends FlxState {

	public var t:Int;
	public var timer:FlxTimer;
	public var splash:FlxSprite;
	public var splashText:FlxTypeText;
	public var showingSplash:Bool = true;
	public var restartGameBtn:FlxButtonPlus;
	public var maxCritters:Int;
	public var numCritters:Int;
	public var numDead:Int;
	public var timeAvailable:Float;
	public var totalElapsed:Float;
	public var hand:PivotJoint;
	public var bg:FlxStarField2D;
	public var info:FlxText;
	public var exploderDeath:FlxEmitter;
	public var ufo:UFO;
	public var ufoRing:FlxWaveSprite;
	public var planets:Array<Planet>;
	public var pullers:Array<FlxNapeSprite>;
	public var objects:Array<FlxNapeSprite>;
	public var terminalVelocity:Float;
	public var numGoals:Int;
	public var goalsReached:Int;
	
	override public function create():Void {
		super.create();
		
		Reg.state = this;
		FlxG.mouse.visible = false;
		
		timeAvailable = 165;
		totalElapsed = 0;
		numCritters = 0;
		numDead = 0;
		terminalVelocity = 375;
		
		planets = new Array<Planet>();
		pullers = new Array<FlxNapeSprite>();
		objects = new Array<FlxNapeSprite>();
		
		FlxNapeSpace.init();
		var walls = FlxNapeSpace.createWalls(-30,-30,FlxG.width+30,FlxG.height+30);
		FlxNapeSpace.velocityIterations = 5;
		FlxNapeSpace.positionIterations = 5;
		
		bg = new FlxStarField2D(0, 0, FlxG.width, FlxG.height, 150);
		add(bg);
		
		info = new FlxText(400 - 60, 5,0,"",16);
		add(info);
	
		exploderDeath = new FlxEmitter();
		exploderDeath.makeParticles(2, 2, FlxColor.RED, 300);
		add(exploderDeath);
		
		loadLevel();
		
		ufo = new UFO(400,400);
		add(ufo);
		var ufoRingRadius = 55;
		var canvas = new FlxSprite(ufo.x,ufo.y);
		canvas.makeGraphic(ufoRingRadius,ufoRingRadius,FlxColor.TRANSPARENT);
		var lineStyle:LineStyle = { color: FlxColor.CYAN, thickness: 2};
		FlxSpriteUtil.drawCircle(canvas, -1, -1, ufoRingRadius/2.0-2, FlxColor.TRANSPARENT, lineStyle);
		ufoRing = new FlxWaveSprite(canvas, FlxWaveMode.ALL, 30, -1, 8);
		ufoRing.alpha = 0.5;
		add(ufoRing);
		ufoRing.kill();

		hand = new PivotJoint(FlxNapeSpace.space.world, null, new Vec2(FlxG.mouse.x, FlxG.mouse.y), new Vec2());
		hand.active = false;
		hand.stiff = false;
		hand.space = FlxNapeSpace.space;
		
		while (numCritters < maxCritters) {
			var planet = Reg.rng.getObject(planets);
			if (!planet.barren) {
				var critter = planet.generateCritter();
				objects.push(critter);
				add(critter);
			}
		}
		Collision.addListener(Collision.cb_CRITTER, Collision.cb_PLANET, collideCritterPlanet);
		
		
		restartGameBtn = new FlxButtonPlus(FlxG.width-50, 0, retryCallback, "RETRY",50,20);
		restartGameBtn.updateInactiveButtonColors([FlxColor.RED, FlxColor.BLACK]);
		add(restartGameBtn);
		//var nextLevelBtn  = new FlxButtonPlus(FlxG.width-50, 20, winLevel, "SKIP",50,20);
		//nextLevelBtn.updateInactiveButtonColors([FlxColor.BLUE, FlxColor.BLACK]);
		//add(nextLevelBtn);
		
		showingSplash = true;
		splash = new FlxSprite(0, 0);
		splash.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		//var splashString:String = "Level " + (Reg.levelIndex+1) + "\n\nGrow new dudes on " + numGoals + " planet" + ( numGoals == 1 ? "" : "s");
		var splashString:String = "Level " + (Reg.levelIndex + 1) + "\n\n" + Reg.levels[Reg.levelIndex].levelText;
		splashText = new FlxTypeText(Math.ceil(FlxG.width / 2 - 300), Math.ceil(FlxG.height / 2 - 100), 0, splashString, 16);
		splashText.start(0, true, false);
		add(splash);
		add(splashText);
		timer = new FlxTimer();
		timer.start(5, hideSplash, 1);

	}
	
	public function retryCallback():Void {
		if (Reg.endless) {
			Reg.randomizePlanets();
		}
		FlxG.switchState(new PlayState());
	}
	
	public function hideSplash(timer:FlxTimer):Void {
		splash.kill();
		splashText.kill();
		showingSplash = false;
	}
	
	public function loadLevel():Void {
		numGoals = 0;
		goalsReached = 0;
		var level:Dynamic = Reg.levels[Reg.levelIndex];
		maxCritters = level.maxCritters;
		var planetList:Array<Dynamic> = level.planets;
		for (planetData in planetList) {
			var pColor = Std.parseInt(planetData.color);
			var pX = planetData.x;
			var pY = planetData.y;
			var pRadius = planetData.radius;
			var pBarren = planetData.barren != null;
			var pIsGoal = planetData.target != null;
			var pTarget = !pIsGoal ?  null : Std.parseInt(planetData.target);
			generatePlanet(pColor, pX, pY, pRadius, pIsGoal, pTarget, pBarren);
		}
	}
	
	public function collideCritterPlanet(cb:InteractionCallback):Void {
		var critter:Critter = cb.int1.userData.owner;
		var planet:Planet = cb.int2.userData.owner;
		
		if (critter.body.velocity.length > terminalVelocity) {
			FlxG.sound.play("assets/sounds/death.wav");
			explodeCritter(critter, exploderDeath);
		}
		planet.shiftColor(critter.color,0.01);
	}
	
	public function explodeCritter(critter:Critter, exploder:FlxEmitter):Void {
		exploder.x = critter.body.position.x;
		exploder.y = critter.body.position.y;
		exploder.start(true, 0, 5);
		objects.remove(critter);
		remove(critter);
		critter.kill();
		critter.destroy();
		numCritters -= 1;
		numDead += 1;
	}
	
	public function generatePlanet(c:FlxColor, x:Float, y:Float, outerRadius:Int, isGoal:Bool, targetColor:FlxColor = null, barren:Bool = false) {
		var planet:Planet = new Planet(x,y,outerRadius,c,barren);
		add(planet);
		planets.push(planet);
		pullers.push(planet);
		
		if (isGoal) {
			numGoals += 1;
			planet.setGoal(targetColor);
		}
	}
	
	override public function update(elapsed:Float):Void {
		
		
		totalElapsed += elapsed;
		super.update(elapsed);
		
		if (FlxG.mouse.justPressed) {
			FlxG.sound.play("assets/sounds/beam"+Reg.rng.int(1,4)+".wav");
			pullers.push(ufo);
			ufoRing.revive();
		}
		if (FlxG.mouse.justReleased) {
			pullers.remove(ufo);
			ufoRing.kill();
		}
		
		
		
		var mx = FlxG.mouse.x;
		var my = FlxG.mouse.y;
		var mp = new Vec2(mx, my);
		hand.body1 = FlxNapeSpace.space.world;
		hand.body2 = ufo.body;
		hand.anchor1.setxy(mx, my);
		hand.anchor2 = ufo.body.worldPointToLocal(ufo.body.position);
		hand.active = true;
		
		mp.dispose();
		ufoRing.x = ufo.x + ufo.width/2.0 - ufoRing.width / 2.0;
		ufoRing.y = ufo.y + ufo.height/2.0- ufoRing.height / 2.0;
		
		
		for (puller in pullers) {
            applyGravity(puller, elapsed);
        }
		
		updateInfo();
		
		checkSuccess();
		
	}
	
	public function checkSuccess() {
		// must have all goals reached at same time
		goalsReached = 0;
		for (planet in planets) {
			if (planet.isGoal) {
				var success = planet.reachedTarget();
				if (success) {
					goalsReached += 1;
					if (goalsReached >= numGoals) {
						winLevel();
					}
				}
			}
		}
		if (timeAvailable-totalElapsed <= 0) {
			loseLevel();
		}
	}
	
	public function winLevel() {
		levelWrapup();
		Reg.levelIndex += 1;
		if ( Reg.levelIndex >= Reg.levels.length ) {
			Reg.levelIndex -= 1;
			Reg.success = true;
			FlxG.switchState(new LoseState());
		} else {
			if (Reg.endless) {
				Reg.randomizePlanets();
			}
			FlxG.switchState(new PlayState());
		}
	}
	
	public function loseLevel() {
		levelWrapup();
		FlxG.switchState(new LoseState());	
	}
	
	public function levelWrapup() {
		Reg.score += timeAvailable-totalElapsed;
		Reg.numDead += numDead;
	}
	
	public function updateInfo() {
		
		info.text = "";
		
		var timeLeft = Std.string(timeAvailable-totalElapsed);
		var i = timeLeft.indexOf('.');
		timeLeft = timeLeft.substr(0, i + 3);
		
		info.text += "Time left: " + timeLeft;
		info.text += "\n";
		info.text += "Live: " + numCritters;
		info.text += "\n";
		info.text += "Dead: " + numDead;
	}
	
	
	
	function applyGravity(planet:FlxNapeSprite, elapsed:Float) {
        var gravityVector = Vec2.get(planet.getMidpoint().x, planet.getMidpoint().y);
		for (object in objects) {
			var distance = FlxMath.getDistance(planet.getMidpoint(), object.getMidpoint());
            var force = gravityVector.sub(object.body.position, true);
            force.length = object.body.mass * (1e6*planet.body.mass) / (distance * distance);
            //formula is impulse = force * deltaTime
            object.body.applyImpulse(force.muleq(elapsed),null,true);
        }
		gravityVector.dispose();
	}
 
	
	
}