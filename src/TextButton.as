package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author MZ
	 */
	public class TextButton extends Sprite
	{
		public var userData:Object;
		public var on_click:Function;
		
		public function update(fontsize:int, text:String, shadowed:Boolean = false, bold:Boolean = false) 
		{
			removeChildren();
			
			var shadow_shift:int = fontsize > 16?2:1;
			//LABEL
			var lfmt:TextFormat = new TextFormat("Tahoma", fontsize, 0, bold);
			var label:TextField = new TextField;
			label.embedFonts = false;
			label.defaultTextFormat = lfmt;
			label.x = 0;
			label.y = 0;
			label.width = 0;
			label.height = 0;
			label.autoSize = "left";
			label.text = text;
			//label.filters = [new DropShadowFilter(shadow_shift, 45, 0, 0.4, 0, 0,4,1)];
			
			var frame:Sprite = new Sprite;
			frame.graphics.lineStyle(1, 0x0000dd);
			frame.graphics.beginFill(0x0000dd, 0.1);
			frame.graphics.drawRect(0, 0, label.width, label.height);
			frame.graphics.endFill();
			
			var ctr:ColorTransform = new ColorTransform;
			ctr.alphaMultiplier = 0.4;
			
			//Render IDLE
			var bd_idle:BitmapData = new BitmapData(label.width + shadow_shift, label.height + shadow_shift, true, 0);
			label.textColor = 0;
			if (shadowed)
			{
				var mx:Matrix = new Matrix;
				mx.translate(shadow_shift, shadow_shift);
				bd_idle.draw(label, mx, ctr);
			}
			bd_idle.draw(label);
			var idle_bitmap:Bitmap = new Bitmap(bd_idle);
			
			var bd_over:BitmapData = new BitmapData(label.width + shadow_shift, label.height + shadow_shift, true, 0);
			label.textColor = 0;
			bd_over.draw(frame);
			if (shadowed)
			{
				var mx:Matrix = new Matrix;
				mx.translate(shadow_shift, shadow_shift);
				bd_over.draw(label, mx, ctr);
			}
			label.textColor = 0x0000dd;
			bd_over.draw(label);
			var over_bitmap:Bitmap = new Bitmap(bd_over);
			
			var bd_press:BitmapData = new BitmapData(label.width + shadow_shift, label.height + shadow_shift, true, 0);
			label.textColor = 0;
			if (shadowed)
			{
				var mx:Matrix = new Matrix;
				mx.translate(shadow_shift, shadow_shift);
				bd_press.draw(label, mx, ctr);
			}
			label.textColor = 0xff5500;
			if (shadowed)
			{
				if (shadow_shift > 1) mx.translate(shadow_shift - 1, shadow_shift - 1);
				bd_press.draw(label,mx);
			}
			else bd_press.draw(label);
			
			var press_bitmap:Bitmap = new Bitmap(bd_press);

			addChild(new Button(idle_bitmap, over_bitmap, press_bitmap));
			
			this.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onClick(e:MouseEvent):void { 
			if(on_click)on_click(this);
		}
		public function TextButton(fontsize:int,text:String,shadowed:Boolean=false, bold:Boolean=false) 
		{
			update(fontsize, text, shadowed, bold);
		}
		
	}

}