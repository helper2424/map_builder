package  
{
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author MZ
	 */
	public class Button extends Sprite
	{
		private var idle_img:DisplayObject;
		private var over_img:DisplayObject;
		private var press_img:DisplayObject;
		private var isOver:Boolean;
		private var isPressed:Boolean;
		public function Button(idle:DisplayObject,over:DisplayObject,press:DisplayObject) 
		{
			isOver = false;
			isPressed = false;
			
			idle_img = idle;
			over_img = over;
			press_img = press;
			
			over_img.visible = false;
			press_img.visible = false;
			
			addChild(idle_img);
			addChild(over_img);
			addChild(press_img);
			
			this.buttonMode = true;
			this.mouseChildren = false;
			
			addEventListener(Event.REMOVED_FROM_STAGE, Release);
			addEventListener(Event.ADDED_TO_STAGE, Prepare);
	
		}
		
		private function Prepare(e:Event):void
		{
			addEventListener(MouseEvent.MOUSE_DOWN, MouseDown);
			addEventListener(MouseEvent.MOUSE_UP,MouseUp);
			addEventListener(MouseEvent.MOUSE_OVER, MouseOver);
			addEventListener(MouseEvent.MOUSE_OUT,MouseOut);
		}
		
		private function Release(e:Event):void
		{
			removeEventListener(MouseEvent.MOUSE_DOWN, MouseOver);
			removeEventListener(MouseEvent.MOUSE_UP,MouseOver);
			removeEventListener(MouseEvent.MOUSE_OVER, MouseOver);
			removeEventListener(MouseEvent.MOUSE_OUT,MouseOut);
		}
		
		private function MouseDown(e:MouseEvent):void
		{
			press_img.visible = true;
			idle_img.visible = false;
			over_img.visible = false;
			isPressed = true;
		}
		private function MouseUp(e:MouseEvent):void
		{
			idle_img.visible = false;
			press_img.visible = false;
			over_img.visible = true;
			
			isPressed = false;
		}
		private function MouseOver(e:MouseEvent):void
		{
			if (isPressed)
			{
				idle_img.visible = false;
				press_img.visible = true;
				over_img.visible = false;
			}
			else
			{
				idle_img.visible = false;
				press_img.visible = false;
				over_img.visible = true;
			}
			
			isOver = true;
		}
		private function MouseOut(e:MouseEvent):void
		{
			idle_img.visible = true;
			press_img.visible = false;
			over_img.visible = false;
			
			isOver = false;
			isPressed = false;
		}
	}

}