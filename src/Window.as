package  
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	/**
	 * ...
	 * @author MZ
	 */
	public class Window extends Sprite
	{
		protected var scrW:int;
		protected var scrH:int;
		protected var bg:Sprite;
		protected var drag_bg:Sprite;
		protected var drag_object:DisplayObject;
		protected var dragging:Boolean = false;
		
		private var Scroll:Sprite;
		private var scroll_w:Number = 8;
		private var scroll_y:Number = 0;
		
		protected var lockX:Number;
		protected var lockY:Number;
		
		private var window:Sprite;
		public var content:Sprite;
		private var content_mask:Sprite;
		public var close_cb:Function;
		
		public var max_window_h:int = 640;
		public var min_window_h:int = 50;
		
		public var MARGIN:int = 25;
		
		public function Window(sw:int,sh:int) 
		{
			scrW = sw;
			scrH = sh;
			bg = new Sprite;
			bg.buttonMode = true;
			content = new Sprite;
			content.x = MARGIN;
			content.y = MARGIN;
			content_mask = new Sprite;
			content_mask.x = content.x;
			content_mask.y = content.y;
			content.mask = content_mask;
			window = new Sprite();
			window.filters = [new DropShadowFilter(2, 90, 0, 0.5, 5, 5, 1, 2)];
			addChild(bg);
			window.addChild(content);
			window.addChild(content_mask);
			addChild(window);
			
			
			Scroll = new Sprite;
			Scroll.buttonMode = true;
			Scroll.y = MARGIN;
			Scroll.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			window.addChild(Scroll);
			
			drag_bg = new Sprite;
			
			window.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			drag_bg.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			drag_bg.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			window.addEventListener(MouseEvent.MOUSE_WHEEL, function (e:MouseEvent):void {
				
				ScrollBy( - e.delta * 10);
				
				
			});
			
			bg.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				visible = false;
				if (close_cb) close_cb();
			});
			Draw();
		}
		
		private function ScrollBy(dy:Number):Number
		{
			var new_y:Number = scroll_y + dy;
			var d_y:Number = new_y;
			
			var scroll_bar_h:int = content_mask.height;
			var scroll_h:Number = scroll_bar_h * scroll_bar_h / content.height;
			var min_scroll_y:int = 0;
			if (new_y < min_scroll_y) new_y = min_scroll_y;
			if (new_y > min_scroll_y + scroll_bar_h - scroll_h) new_y = min_scroll_y + scroll_bar_h - scroll_h;
			
			d_y -= new_y;
			
			scroll_y = new_y;
			
			content.y = -((content.height - scroll_bar_h) * scroll_y / (scroll_bar_h - scroll_h)) + MARGIN;
			
			updateScroll(false);
			
			return d_y;
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			if (e.target != window && e.target != Scroll) return;
			drag_object = e.target as DisplayObject;
			dragging = true;
			addChild(drag_bg);
			lockX = drag_bg.mouseX;
			lockY = drag_bg.mouseY;
		}
		
		private function onMouseMove(e:MouseEvent):void
		{
			var dx:int = drag_bg.mouseX - lockX;
			var dy:int = drag_bg.mouseY - lockY;
			if (drag_object==window)
			{
				var new_x:int = window.x + dx;
				var new_y:int = window.y + dy;

				var d_x:int = new_x;
				var d_y:int = new_y;
				
				if (new_x < 0) new_x = 0;
				if (new_y < 0) new_y = 0;
				if (new_x > scrW - getWinW()) new_x = scrW - getWinW();
				if (new_y > scrH - getWinH()) new_y = scrH - getWinH();
				
				d_x -= new_x;
				d_y -= new_y;
				
				window.x = new_x;
				window.y = new_y;
				
				lockX = drag_bg.mouseX - d_x;
				lockY = drag_bg.mouseY - d_y;
			}
			else
			if (drag_object==Scroll)
			{
				d_y = ScrollBy(dy);
				lockY = drag_bg.mouseY - d_y;
			}
		}
		
		public function getWinW():Number
		{
			return content_mask.width + MARGIN * 2;
		}
		
		public function getWinH():Number
		{
			return content_mask.height + MARGIN * 2;
		}
		
		private function updateScroll(calc_pos:Boolean=true):void
		{
			var scroll_bar_h:int = content_mask.height;

			var scroll_h:Number = scroll_bar_h * scroll_bar_h / content.height;
			
			if (scroll_h >= scroll_bar_h)
			{
				Scroll.visible = false;
				return;
			}
			
			Scroll.visible = true;
			
			if (calc_pos) 
			{
				scroll_y = (scroll_bar_h - scroll_h) * (content.y-MARGIN) / (content.height - scroll_bar_h);
				var min_scroll_y:int = 0;
				if (scroll_y > min_scroll_y + scroll_bar_h - scroll_h) scroll_y = min_scroll_y + scroll_bar_h - scroll_h;
			}
			
			with (Scroll.graphics)
			{
				clear();
				if (scroll_bar_h <= 0) return;
				beginFill(0, 0.1);
				drawRoundRect(0, 0, scroll_w, scroll_bar_h, scroll_w);
				endFill();
				beginFill(0, 0.5);
				drawRoundRect(0, scroll_y, scroll_w, scroll_h,scroll_w);
				endFill();
			}
		}
		
		private function onMouseUp(e:MouseEvent):void
		{
			dragging = false;
			removeChild(drag_bg);
		}
		
		public function Draw():void
		{
			drag_bg.graphics.clear();
			drag_bg.graphics.beginFill(0, 0);
			drag_bg.graphics.drawRect(0, 0, scrW, scrH);
			drag_bg.graphics.endFill();
		
			bg.graphics.clear();
			bg.graphics.beginFill(0,0.2);
			bg.graphics.drawRect(0, 0, scrW, scrH);
			bg.graphics.endFill();
			
			
			window.graphics.clear();
			
			var w:int = content.width + MARGIN * 2;
			var h:int = content.height + MARGIN * 2;
			if (h > scrH * 0.8) h = scrH * 0.8;
			if (h < min_window_h) h = min_window_h;
			if (h > max_window_h) h = max_window_h;
			
			window.graphics.beginFill(0xeeeeee);
			window.graphics.drawRect(0, 0, w, h);
			window.graphics.endFill();
			
			content_mask.graphics.clear();
			content_mask.graphics.beginFill(0xee0000);
			content_mask.graphics.drawRect(0, 0, w + 2 - MARGIN * 2, h - MARGIN * 2);
			content_mask.graphics.endFill();
			
			window.x = (scrW - w) * 0.5;
			window.y = (scrH - h) * 0.5;
			
			updateScroll();
			Scroll.x = window.width - MARGIN + scroll_w;
		}
		
		public function Resize(sw:int,sh:int):void
		{
			scrW = sw;
			scrH = sh;
			Draw();
		}
	}

}