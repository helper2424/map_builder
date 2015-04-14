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
		public var special:Boolean;
		
		public function PlayerSpot(data:Object) 
		{
			this.x = Main.ConvertToPixels(data.x);
			this.y = Main.OldY(Main.ConvertToPixels(data.y));
			this.team = data.team;
			this.special = data.special;
			this.color = team > 0 ? MapObject.team_colors[team] : 0x888888;
			img = new Sprite;
			img.name = "DRAG";
			addChild(img);
			
			this.buttonMode = true;
			
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
			data.special = special;
			return data;
		}
		
		public function UpdateData(data:Object,draw:Boolean=true):void
		{
 
			x = Main.ConvertToPixels(data.x);
			y = Main.OldY(Main.ConvertToPixels(data.y));

			team = data.team;
			special = data.special;
			if (draw) Draw();
		}
		
	}

}