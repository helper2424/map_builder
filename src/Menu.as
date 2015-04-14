package  
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author MZ
	 */
	public class Menu extends Sprite
	{
		private var items_x:int = 5;
		
		public function Menu() 
		{

		}
		
		public function addItem(item:DisplayObject):void
		{
			item.y = 2;
			item.x = items_x;
			items_x += item.width + 10;
			addChild(item);
		}
		
		public function Draw(sw:int):void
		{
			graphics.clear();
			graphics.lineStyle(1);
			graphics.beginFill(0xeeeeee);
			graphics.drawRect(-1,-1, sw+2, 24);
			graphics.endFill();
		}
	}

}