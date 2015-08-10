package 
{
	//what to import, what we are going to need
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	import flash.text.*;
	import flash.utils.*;
	import flash.media.Sound;
	import flash.media.SoundChannel;

	//class declaration
	public class MatchingPartObject extends MovieClip {

	
	//constants
		//set up factors	
		private static const yardWidth:uint = 4;
		private static const yardHeight:uint = 5;
		private static const horizSpace:Number = 64;
		private static const vertSpace:Number = 40;
		private static const holeOffsetX:Number = 66;
		private static const holeOffsetY:Number = 77;
		
		//points weighting
		private static const pointsBone:int = 1;
		private static const pointsBanana:int = -4;
			
	//digging holes
		//yellow selector box
		private var s:Selector = new Selector;
		
		//scores and linger animation
		private var goodScore:Good = new Good;
		private var badScore:Bad = new Bad;
		private var fadeBone1:FadeBone = new FadeBone;
		private var fadeBone2:FadeBone = new FadeBone;
		private var fadeBanana1:FadeBanana = new FadeBanana;
		private var fadeBanana2:FadeBanana = new FadeBanana;
		
		//holes selection
		private var firstHole:Hole;
		private var secondHole:Hole;
		
		//variables for event trigger animations
		private var matchStepBone:uint;
		private var isMatchingBone:Boolean = false;
		private var matchStepBanana:uint;
		private var isMatchingBanana:Boolean = false;
		private var goodMatchStep:uint;
		private var isGoodMatching:Boolean = false;
		private var badMatchStep:uint;
		private var isBadMatching:Boolean = false;
		
		//score variables
		private var holesDug:uint;
		private var matchScore:int;
		private var bones:int;
		
		//timers
		private var gameTime:uint;
		private var startTime:uint;
		private var timerLimit:Number;
		
		//sounds
		var allBonesSound:AllBonesSound = new AllBonesSound();
		var badSound:BadSound = new BadSound();
		var countdownSound:CountdownSound = new CountdownSound();
		var gameplaySound:GameplaySound = new GameplaySound();
		var goodSound:GoodSound = new GoodSound();
		var tenPointsSound:TenPointsSound = new TenPointsSound();
		var themeSound:ThemeSound = new ThemeSound();
		
			
	//initialisation/constructor function
		public function MatchingPartObject():void
		{
			// initialize arrow variables
			var leftArrow:Boolean = false;
			var rightArrow:Boolean = false;
			var upArrow:Boolean = false;
			var downArrow:Boolean = false;
			var spaceBar:Boolean = false;
			
			//show time function
			startTime = getTimer();
			gameTime = 0;
			playSound(gameplaySound);
			
			/*the next code for the array is for the bone and banana graphics,
			because my array is set to 20 I can hard code the numbers. 0 
			corresponds to a bone and 1 is a banana peel.  Beacuse I want 
			the result to be a match as long as the same type is chosen.
			the loop the texts uses to set the array creates two of each 
			number 0-9 which means the player has to select the right two 
			holes which may be wrong even though the same type is diplayed*/
			
			//set array for bone and banana peel selection
			var holesToDig:Array = new Array(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1);
			
			
			//set variables for scoring to zero
			holesDug = 0;
			bones = 0;
			
			/* constructor code.  sets a grid of holes 4x5.  A random 
			number is used to select a 0 or 1 from the array and is assigned
			to each object as it is added to the grid.*/			
			for (var x:uint=0; x<yardWidth; x++)
			{
				for (var y:uint=0; y<yardHeight; y++)
				{
					var h:Hole = new Hole();
					h.stop();
					h.x = x * horizSpace + holeOffsetX;
					h.y = y * vertSpace + holeOffsetY;
					var r:uint = Math.floor(Math.random() * holesToDig.length);
					h.dug = holesToDig[r];
					holesToDig.splice(r,1);
					
					//a listener is added to each hole to start a function if it is clicked
					h.addEventListener(MouseEvent.CLICK,digHole);
						
						//add the total number of bones only to a variable
						if (h.dug == 0){
							bones++
						}
					
					//add hole to stage
					addChild(h);
					
					//increase total number of holes on stage by one per cycle
					holesDug++;
				}
			}
			
			//add yellow box to move around as selector
			s.x = holeOffsetX;
			s.y = holeOffsetY -16;
			addChild(s);			
			
			// set event listeners
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressedDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyPressedUp);
			stage.addEventListener(Event.ENTER_FRAME, moves);
			addEventListener(Event.ENTER_FRAME,showTime);


			// set arrow variables to true
			function keyPressedDown(event:KeyboardEvent) {
				if (event.keyCode == 37) {
					leftArrow = true;
				} else if (event.keyCode == 39) {
					rightArrow = true;
				} else if (event.keyCode == 38) {
					upArrow = true;
				} else if (event.keyCode == 40) {
					downArrow = true;
				} else if (event.keyCode == 32) {
					spaceBar = true;
				}
			}
	
			// set arrow variables to false
			function keyPressedUp(event:KeyboardEvent) {
				if (event.keyCode == 37) {
					leftArrow = false;
				} else if (event.keyCode == 39) {
					rightArrow = false;
				} else if (event.keyCode == 38) {
					upArrow = false;
				} else if (event.keyCode == 40) {
					downArrow = false;
				} else if (event.keyCode == 32) {
					spaceBar = false;
				}
			}
			
				
			//each time a button is pressed move only to a hole and pause to stop double movements
			function moves(event:Event) {

				if (leftArrow) {
					s.x -= 64;
					leftArrow = false;
				}
				if (rightArrow) {
					s.x += 64;
					rightArrow = false;
				}
				if (upArrow) {
					s.y -= 40;
					upArrow = false;
				}
				if (downArrow) {
					s.y += 40;
					downArrow = false;
				}
				/*this event triggers a mouse click at the selectors location
				by calling a dispatchevent in the select function. Each hole
				is listening for a mouse click event which then triggers the
				hole to be dug*/
				if (spaceBar) {
					select(s.x,s.y);
					spaceBar = false;
				}

			//constrain movement to the holes grid
				if (s.x <= 66) {
					s.x = 66;
				}
				if (s.x >= 258) {
					s.x = 258;
				}
				if (s.y <= 61) {
					s.y = 61;
				}
				if (s.y >= 221) {
					s.y = 221;
				}
			}
			
			//remove listeners if some conditions for game over are met
			if(holesDug == 0 || bones == 0 || timerLimit == 0) {
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressedDown);
				stage.removeEventListener(KeyboardEvent.KEY_UP, keyPressedUp);
				h.removeEventListener(MouseEvent.CLICK,digHole);
				stage.removeEventListener(Event.ENTER_FRAME, moves);
			}						
			
		//function to get target and send a mouse click event when spacebar is pressed
			function select(x:Number, y:Number):void
			
			{	//make array of all objects under the selector
				var objects:Array = parent.getObjectsUnderPoint(new Point(x, y));
				var target:DisplayObject;

				//get the second shape in the array and make sure it is a shape(hole).
				while(target = objects[1])
				{	
					if(target is Shape)
					{
						break;
					}
				}
				
				//set the Hole under the selector as the target and dispatch a mouse click at its location
				//and reset the point location if holesDug == 0 (when resettting to play again)
				if(target !== null && holesDug !== 0 && timerLimit !== 0 && matchScore !== 10 && bones !== 0)
				{	
					var local:Point = target.globalToLocal(new Point(x, y));
					var startDigging:MouseEvent = new MouseEvent(MouseEvent.CLICK);
					target.dispatchEvent(startDigging);
				}
			}
		}
		
		/*this function detects a click and assigns the underlying 
		number to either firstHole or secondHole and checks if they
		are the same.  if they are they get removed, if not they
		are turned back into holes*/
		public function digHole(event:MouseEvent) {

			var thisHole:Hole = (event.currentTarget as Hole);

				//if first selected hole has nothing selected, select hole
				if (firstHole == null)
				{
					//make the hole the first selected hole and start the animation to dig it
					firstHole = thisHole;
					firstHole.startDig(thisHole.dug+2);

					}
					
					//if the player selects the same card again cover it up and 
					//start the first selection process again
					else if (firstHole == thisHole)
					{
						firstHole.startDig(1);
						firstHole = null;
			
					}
					
					//if the player has chosen the first hole make the next selected the second hole
					else if (secondHole == null)
					{
						//make selection and animate
						secondHole = thisHole;
						thisHole.startDig(thisHole.dug+2);
	
						//check for a match
						if (firstHole.dug == secondHole.dug)
						{	
							//if the selected holes are both bones they are a match
							if (firstHole.dug == [0] && secondHole.dug == [0]) {
								
								//if player matches bones give points, update score and decrease number of bones 
								//that are known to be still active.  Also adds two new bones to fade away to 
								//give the appearance of them lingering to fade.  Also adds the points animation
								matchScore += pointsBone;
								showMatchScore();											
								goodScore.x = 120;
								goodScore.y = 80;
								addChild(goodScore);
								digGoodMatch();
								bones -= 2;							
								fadeBone1.x = firstHole.x;
								fadeBone1.y = firstHole.y;								
								fadeBone2.x = secondHole.x;
								fadeBone2.y = secondHole.y;
								addChild(fadeBone1);
								addChild(fadeBone2);
								matchingBone();
								
							}
								else {
									
									//if player matches banana take off points and update score, as well as 
									//animate the bad score and adding the fading banana
									matchScore += pointsBanana;
									showMatchScore();
									badScore.x = 120;
									badScore.y = 80;
									addChild(badScore);
									digBadMatch();
									fadeBanana1.x = firstHole.x;
									fadeBanana1.y = firstHole.y;
									fadeBanana2.x = secondHole.x;
									fadeBanana2.y = secondHole.y;
									addChild(fadeBanana1);
									addChild(fadeBanana2);
									matchingBanana();
								}
								
								//after showing scores and preparing faders, removes the matched holes.
								removeChild(firstHole);
								removeChild(secondHole);


							//leave behind a static dug hole image in each spot with a bit of 
							//a fade so the player knows they are inactive.
							var dugHole1:Dughole = new Dughole;
							dugHole1.x = firstHole.x;
							dugHole1.y = firstHole.y;
							dugHole1.alpha = .7;
							var dugHole2:Dughole = new Dughole;
							dugHole2.x = secondHole.x;
							dugHole2.y = secondHole.y;
							dugHole2.alpha = .7;
							addChild(dugHole1);
							addChild(dugHole2);
							
							//reset selections
							firstHole = null;
							secondHole = null;

							//update counter for holes left and bones found, 
							//if either reaches zero, end the game.
							holesDug -= 2;

							if (holesDug == 0 || bones == 0) {
								endMatchingGame();
							}
						} 

					}
				else
				{
					//if everything alse has passed, reshow the undug holes and selected objects.
					firstHole.gotoAndStop(1);
					secondHole.gotoAndStop(1);
					secondHole = null;
					firstHole = thisHole;
					firstHole.startDig(thisHole.dug+2);
				}
		}
		
		//update score text
		public function showMatchScore() {
			MovieClip(root).currentScore.text = "" + String(matchScore);
		}
		
		//set timer to count down from 10.  if it reaches zero, end the game.
		public function showTime(event:Event) {	
			gameTime = getTimer() - startTime;
			timerLimit = ((10000 - gameTime)/1000);
			MovieClip(root).timer.text = "" + String(timerLimit);
			if (timerLimit < 0) {
				timerLimit = 0;
			}
			if (timerLimit == 0) {
				endMatchingGame();
			}
		}				
		
		//function to fade out treasures if matching.
		public function matchingBone() {
			isMatchingBone = true;
			matchStepBone = 0;
			this.addEventListener(Event.ENTER_FRAME, matchItBone);
		}
		
		public function matchItBone(event:Event) {
			matchStepBone++;
			
			if (matchStepBone < 10) {
				fadeBone1.alpha = 1 - (matchStepBone/10);
				fadeBone2.alpha = 1 - (matchStepBone/10);
			}
						
			if (matchStepBone == 10) {
				removeChild(fadeBone1);
				removeChild(fadeBone2);
				this.removeEventListener(Event.ENTER_FRAME, matchItBone);
			}
		}

		//function to fade out matched bananas.
		public function matchingBanana() {
			isMatchingBanana = true;
			matchStepBanana = 0;
			this.addEventListener(Event.ENTER_FRAME, matchItBanana);
		}
		
		public function matchItBanana(event:Event) {
			matchStepBanana++;
			
			if (matchStepBanana < 10) {
				fadeBanana1.alpha = 1 - (matchStepBanana/10);
				fadeBanana2.alpha = 1 - (matchStepBanana/10);
			}
						
			if (matchStepBanana == 10) {
				removeChild(fadeBanana1);
				removeChild(fadeBanana2);
				this.removeEventListener(Event.ENTER_FRAME, matchItBanana);
			}
		}

		//function to add a graphic and animation for matching a bone.  
		//it grows and fades out rapidly
		public function digGoodMatch() {
			isGoodMatching = true;
			goodMatchStep = 0;
			this.addEventListener(Event.ENTER_FRAME, goodMatchIt);
		}
		
		public function goodMatchIt(event:Event) {
			goodMatchStep++;
			
			if (goodMatchStep < 10) {
				goodScore.scaleY = 1 * goodMatchStep;
				goodScore.scaleX = 1 * goodMatchStep;
				goodScore.alpha = 1 - (goodMatchStep/10);
				playSound(goodSound);
			}
						
			if (goodMatchStep == 10) {
				removeChild(goodScore);
				this.removeEventListener(Event.ENTER_FRAME, goodMatchIt);
			}
		}
		
		//function to add a graphic and animation for matching a banana, 
		//like the bone it grows and fades out rapidly.
		public function digBadMatch() {
			isBadMatching = true;
			badMatchStep = 0;
			this.addEventListener(Event.ENTER_FRAME, badMatchIt);
		}
		
		public function badMatchIt(event:Event) {
			badMatchStep++;
			
			if (badMatchStep < 10) {
				badScore.scaleY = 1 * badMatchStep;
				badScore.scaleX = 1 * badMatchStep;
				badScore.alpha = 1 - (badMatchStep/10);
				playSound(badSound);
			}
						
			if (badMatchStep == 10) {
				removeChild(badScore);
				this.removeEventListener(Event.ENTER_FRAME, badMatchIt);
			}
		}
		
		
		//function to set conditions for end game.
		public function endMatchingGame() {
			//if the player matches all the bones without any bananas, give bonus
			if (matchScore == 8) {
				matchScore = 10;
			}
			removeEventListener(Event.ENTER_FRAME,showTime);
			MovieClip(root).matchScore = matchScore;
			MovieClip(root).bones = bones;
			MovieClip(root).gotoAndStop("scorescreen");
		}
		
		//function for playing sounds
		public function playSound(soundObject:Object) {
			var channel:SoundChannel = soundObject.play();
		}
		
	}	
}
