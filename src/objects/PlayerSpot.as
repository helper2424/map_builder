package objects 
{
	import flash.display.Sprite;
	import flash.geom.Point;
	/**
	 * ...
	 * @author MZ
	 */
	public class PlayerSpot extends MapObject
	{
		public var img:Sprite;
		public var type:uint;
		
		public function PlayerSpot(data:Object) 
		{
			img = new Sprite;
			img.name = "DRAG";
			addChild(img);

			UpdateData(data, true);

			this.buttonMode = true;
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
			img.graphics.beginFill(color,selected ? 1.0 : 0.5);
			img.graphics.drawCircle(0,0,30);
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

			data.team = team;
			data.type = type;
			return data;
		}
		
		public function UpdateData(data:Object,draw:Boolean=true):void
		{
 
			x = Main.ConvertToPixels(data.x);
			y = Main.OldY(Main.ConvertToPixels(data.y));

			team = data.team;

			if(!data.type)
				type = 0;
			else
				type = data.type;
			this.color = team > 0 ? MapObject.team_colors[team] : 0x888888;

			if (draw) Draw();
		}
		
	}

}