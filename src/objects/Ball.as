package objects 
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author MZ
	 */
	public class Ball extends MapObject
	{
		public var img:Sprite;
		protected var ball_id:int
		protected var radius:Number = 20;
		protected var bounce:Number = 0.95
		protected var friction:Number = 1;
		protected var mass:Number = 1;
		
		public function Ball(data:Object) 
		{
 
			this.x = Main.ConvertToPixels(data.x);
			this.y = Main.OldY(Main.ConvertToPixels(data.y));

			this.ball_id = data.ball_id;
			this.mass = data.mass;
			this.bounce = data.bounce;
			this.friction = data.friction;
			this.radius = Main.ConvertToPixels(data.radius);

			img = new Sprite;
			img.name = "DRAG";
			addChild(img);
			
			this.buttonMode = true;
			
			Load();
			
			Draw();
		}
		
		override public function Update(s:Sprite, nx:int, ny:int,snap_axis:int,snap_grid:int):void
		{
			super.Update(s, nx, ny, snap_axis, snap_grid);
			Draw();
		}
		
		override public function Draw():void
		{
			img.graphics.clear();
			img.graphics.lineStyle(4, selected ? 0xffff00 : 0,selected ? 1.0 : 0.5);
			img.graphics.beginFill(0x888888,selected ? 1 : 0.4);
			img.graphics.drawCircle(0,0,(radius+1));
			img.graphics.endFill();
			
			img.graphics.lineStyle();
			img.graphics.beginFill(0);
			img.graphics.drawCircle(0,0,1);
			img.graphics.endFill();
		}
		
		public function Data():Object
		{
			var data:Object = new Object;
 
			data.x = Main.ConvertFromPixels(x);
			data.y = Main.ConvertFromPixels(Main.NewY(y));

			data.ball_id = ball_id;
			data.bounce = this.bounce;
			data.radius = Main.ConvertFromPixels(this.radius);
			data.mass = this.mass;
			data.friction = this.friction;
			return data;
		}
		
		public function Load():void
		{
			img.removeChildren();
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(IOErrorEvent.IO_ERROR, function (e:IOErrorEvent):void {
				trace("Error:"+e.errorID);
			});
			loader.addEventListener(Event.COMPLETE, function (e:Event):void
			{
				var ball:Object = JSON.parse(loader.data);
				if (ball!=null && ball.texture_url)
				{
					radius = ball.radius;
					
					var ldr:Loader = new Loader();
					ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void
					{
						//ldr.width = (radius+1) * 2;
						//ldr.scaleY = ldr.scaleX;
						ldr.x = -ldr.width / 2;
						ldr.y = -ldr.height / 2;
						
						Draw();
					});
					ldr.mouseEnabled = false;
					ldr.load(new URLRequest(ball.texture_url));
					img.addChild(ldr);
				}
			});
			loader.load(new URLRequest("http://dev.voltapps.ru:8081/ball/" + ball_id));
		}
		
		public function UpdateData(data:Object,draw:Boolean=true):void
		{
 
			x = Main.ConvertToPixels(data.x);
			y = Main.OldY(Main.ConvertToPixels(data.y));
			bounce = data.bounce;
			radius = Main.ConvertToPixels(data.radius);
			friction = data.friction;
			mass = data.mass;

			_id = data._id;
			
			if (ball_id != data.ball_id)
			{
				ball_id = data.ball_id;
				Load();
			}
			
			if(draw) Draw();
		}
	}

}