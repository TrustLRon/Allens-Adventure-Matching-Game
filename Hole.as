package  {
	import flash.display.*;
	import flash.events.*;
	
	public dynamic class Hole extends MovieClip {
		private var digStep:uint;
		private var isDigging:Boolean = false;
		private var digFrame:uint;		
		

		public function startDig(digWhichFrame:uint) {
			isDigging = true;
			digStep = 0;
			digFrame = digWhichFrame;
			this.scaleY = 0;
			this.addEventListener(Event.ENTER_FRAME, digIt);
		}
		
		public function digIt(event:Event) {
			digStep++;
			
			if (digStep <= 10) {
				this.scaleY = .1 * digStep;
			}
			
			if (digStep == 5) {
				gotoAndStop(digFrame);
			}
			
			if (digStep == 10) {
				this.removeEventListener(Event.ENTER_FRAME, digIt);
			}
		}

	}
}