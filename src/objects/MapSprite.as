package objects 
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author MZ
	 */
	public class MapSprite extends MapObject
	{
		public var z_index:int;
		public var img:Sprite;
		private var frame:Sprite;
		private var _url:String;
		
		public function MapSprite(data:Object) 
		{
			this.z_index = data.z_index;
 
			this.x = Main.ConvertToPixels(data.x);
			this.y = Main.OldY(Main.ConvertToPixels(data.y));
			
			frame = new Sprite;
			frame.name = "DRAG";
			addChild(frame);
			
			img = new Sprite();
			img.name = "DRAG";
			img.mouseChildren = false;
			addChild(img);
			
			Load(data.url);

			buttonMode = true;
		}
		
		public function Load(url:String):void
		{
			img.removeChildren();
			_url = url;
			
			if (url.indexOf("http") == -1) url = "http://dev.r3studio.ru/" + url;
			
			var ldr:Loader = new Loader();
			ldr.load(new URLRequest(url));
			ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function (e:IOErrorEvent):void
			{
				trace(e);
			});
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, function (e:Event):void
			{
				img.x = -img.width / 2;
				img.y = -img.height / 2;
				
				Draw();
			});
			img.addChild(ldr);
		}
		
		override public function Draw():void
		{
			frame.graphics.clear();
			if (selected)
			{
				frame.graphics.lineStyle(4, select_color);
				frame.graphics.beginFill(0, 0.5);
				frame.graphics.drawRect( -img.width / 2 - 2, -img.height / 2 - 2, img.width + 4, img.height + 4);
				frame.graphics.endFill();
			}
		}
		
		
		public function Data():Object
		{
			var data:Object = new Object;
 
			data.x = Main.ConvertFromPixels(x);
			data.y = Main.ConvertFromPixels(Main.NewY(y));

			data.z_index = z_index;
			data.url = _url;
			return data;
		}
		
		public function UpdateData(data:Object,draw:Boolean=true):void
		{
 
			x = Main.ConvertToPixels(data.x);
			y = Main.OldY(Main.ConvertToPixels(data.y));

			z_index = data.z_index;
			_url = data.url;
			Load(_url);
		}
	}

}