package objects 
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author MZ
	 */
	public class MapObject extends Sprite
	{
		public static var team_colors:Array = [0, 0xff0000, 0x0000ff, 0x55dd00];
		public static var select_color:int = 0xffff00;
		public var _id:int;
		
		protected var color:int = 0x888888;
		protected var selected:Boolean = false;
		protected var lockX:int;
		protected var lockY:int;
		protected var startX:int;
		protected var startY:int;
		protected var team:int;
		
		public function getTeam():int
		{
			return team;
		}

		public function SwitchTeam(new_team:int):void
		{
			team = new_team;
			color = new_team>0 ? team_colors[new_team] : 0x888888;
			Draw();
		}
		public function StartMove(s:Sprite, sx:int, sy:int):void
		{
			lockX = sx;
			startX = x;
			lockY = sy;
			startY = y;
			this.mouseEnabled = false;
			this.mouseChildren = false;
		}
		
		/*public function ShiftMove(sx:int, sy:int):void
		{
			lockX += sx;
			lockY += sy;
		}*/
		
		public function Shift(dx:int, dy:int):void
		{
			x += dx;
			y += dy;
		}
		
		public function EndMove():void
		{
			this.mouseEnabled = true;
			this.mouseChildren = true;
		}
		
		public function Update(s:Sprite, nx:int, ny:int,snap_axis:int,snap_grid:int):void
		{
			var dx:int = 0;
			var dy:int = 0;
			
			x += nx - lockX;
			y += ny - lockY;
			
			if (snap_grid > 0)
			{
				if (Math.abs(x%snap_grid)!=0) 
				{
					var new_x:int = Math.round(x / snap_grid) * snap_grid;;
					dx = new_x - x;
					x = new_x;
				}
				
				if (Math.abs(y%snap_grid)!=0) 
				{
					var new_y:int = Math.round(y / snap_grid) * snap_grid;;
					dy = new_y - y;
					y = new_y;
				}
			}
			
			if (snap_axis > 0)
			{
				if (Math.abs(x - startX) > Math.abs(y - startY))
				{
					var new_y:int = startY;
					dy += new_y - y;
					y = new_y;
				}
				else
				{
					var new_x:int = startX;
					dx += new_x - x;
					x = new_x;
				}
			}
			
			lockX = nx + dx;
			lockY = ny + dy;
		}
		
		public function isSelected():Boolean
		{
			return selected;
		}
		
		public function Select(sel:Boolean):void
		{
			selected = sel;
			Draw();
		}
		public function Draw():void
		{
			
		}
	}

}