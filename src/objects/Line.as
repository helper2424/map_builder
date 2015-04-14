package objects 
{
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	/**
	 * ...
	 * @author MZ
	 */
	public class Line extends MapObject
	{
		public var line:Sprite;
		public var spr_r1:Sprite;
		public var spr_r2:Sprite;
		protected var x1:int, x2:int, y1:int, y2:int, r1:int, r2:int;
		protected var left:Boolean;
		protected var right:Boolean;
		protected var dashed:Boolean = false;
 
		protected var ball_collision:Boolean;

		protected var player_collision:Boolean;
		
		protected static const NORMAL_R:Number = 15;
		
		public function Line(data:Object) 
		{
 
			this.x1 = Main.ConvertToPixels(data.x1);
			this.y1 = Main.OldY(Main.ConvertToPixels(data.y1));
			this.x2 = Main.ConvertToPixels(data.x2);
			this.y2 = Main.OldY(Main.ConvertToPixels(data.y2));
			this.r1 = Main.ConvertToPixels(data.r1);
			this.r2 = Main.ConvertToPixels(data.r2);
			this.left = data.left;
			this.right = data.right;
			this.player_collision = data.player_collision;
			this.ball_collision = data.ball_collision;

			line = new Sprite;
			line.name = "DRAG";
			addChild(line);

			spr_r1 = new Sprite;
			addChild(spr_r1);
			spr_r1.name = "DRAG";
			
			spr_r2 = new Sprite;
			addChild(spr_r2);
			spr_r2.name = "DRAG";
			
			this.buttonMode = true;
		}

		override public function StartMove(s:Sprite, sx:int, sy:int):void
		{
			lockX = sx;
			startX = x1;
			lockY = sy;
			startY = y1;
			this.mouseEnabled = false;
			this.mouseChildren = false;
		}
		
		override public function Shift(dx:int, dy:int):void
		{
			x1 += dx;
			x2 += dx;
			y1 += dy;
			y2 += dy;
			Draw();
		}
		
		override public function Update(s:Sprite, nx:int, ny:int,snap_axis:int,snap_grid:int):void
		{
			var dx:int = 0;
			var dy:int = 0;
			
			if (s == line)
			{
				var shx:int = nx - lockX;
				var shy:int = ny - lockY;
				
				x1 += shx;
				y1 += shy;
				x2 += shx;
				y2 += shy;
				
				if (snap_grid>0)
				{
					if (Math.abs(x1%snap_grid)!=0) 
					{
						var new_x:int = Math.round(x1 / snap_grid) * snap_grid;;
						dx += new_x - x1;
						x1 = new_x;
						x2 += dx;
					}
					
					if (Math.abs(y1%snap_grid)!=0) 
					{
						var new_y:int = Math.round(y1 / snap_grid) * snap_grid;;
						dy += new_y - y1;
						y1 = new_y;
						y2 += dy;
					}
				}
				
				if (snap_axis > 0)
				{
					if (Math.abs(x1 - startX) > Math.abs(y1 - startY))
					{
						var new_y:int = startY;
						dy += new_y - y1;
						y2 += new_y - y1;
						y1 = new_y;
					}
					else
					{
						var new_x:int = startX;
						dx += new_x - x1;
						x2 += new_x - x1;
						x1 = new_x;
					}
				}

				lockX = nx + dx;
				lockY = ny + dy;
				Draw();
			}
			else
			if (s == spr_r1)
			{
				x1 += nx - lockX;
				y1 += ny - lockY;
				if (snap_grid>0)
				{
					if (Math.abs(x1%snap_grid)!=0) 
					{
						var new_x:int = Math.round(x1 / snap_grid) * snap_grid;;
						dx += new_x - x1;
						x1 = new_x;
					}
					
					if (Math.abs(y1%snap_grid)!=0) 
					{
						var new_y:int = Math.round(y1 / snap_grid) * snap_grid;;
						dy += new_y - y1;
						y1 = new_y;
					}
				}
				if (snap_axis > 0)
				{
					if (Math.abs(x1 - x2) < snap_axis) 
					{
						dx += x2 - x1;
						x1 = x2;
					}
					if (Math.abs(y1 - y2) < snap_axis) 
					{
						dy += y2 - y1;
						y1 = y2;
					}
				}
				lockX = nx + dx;
				lockY = ny + dy;
				Draw();
			}
			else
			if (s == spr_r2)
			{
				x2 += nx - lockX;
				y2 += ny - lockY;
				if (snap_grid>0)
				{
					if (Math.abs(x2%snap_grid)!=0) 
					{
						var new_x:int = Math.round(x2 / snap_grid) * snap_grid;;
						dx += new_x - x2;
						x2 = new_x;
					}
					
					if (Math.abs(y2%snap_grid)!=0) 
					{
						var new_y:int = Math.round(y2 / snap_grid) * snap_grid;;
						dy += new_y - y2;
						y2 = new_y;
					}
				}
				if (snap_axis>0)
				{
					if (Math.abs(x1 - x2) < snap_axis) 
					{
						dx += x1 - x2;
						x2 = x1;
					}
					if (Math.abs(y1 - y2) < snap_axis)
					{
						dy += y1 - y2;
						y2 = y1;
					}
				}
				lockX = nx + dx;
				lockY = ny + dy;
				Draw();
			}
		}
		
		override public function Draw():void
		{
			var cur_color:int = selected ? select_color : color;
			
			line.graphics.clear();
			line.graphics.lineStyle(4, cur_color, selected ? 1.0 : 0.5);
			
			if (dashed)
			{
				var len:Number = MUtils.Length(x1 - x2, y1 - y2);
				var steps:int = len / 15;
				for (var i = 0; i < steps; i+=2)
				{
					var fx:int = x1 + (x2 - x1) * i / steps;
					var fy:int = y1 + (y2 - y1) * i / steps;
					var tx:int = x1 + (x2 - x1) * (i+1) / steps;
					var ty:int = y1 + (y2 - y1) * (i+1) / steps;
					line.graphics.moveTo(fx, fy);
					line.graphics.lineTo(tx, ty);
				}
				
			}
			else
			{
				line.graphics.moveTo(x1, y1);
				line.graphics.lineTo(x2, y2);
			}
			
			spr_r1.graphics.clear();

			spr_r1.graphics.beginFill(selected ? select_color : 0, selected ? 0.5 :0.2);
			spr_r1.graphics.drawCircle(x1, y1, r1+10);
			spr_r1.graphics.endFill();
				
			if (r1 > 0)
			{
				spr_r1.graphics.beginFill(color,selected ? 1.0 : 0.5);
				spr_r1.graphics.drawCircle(x1, y1, Math.max(r1,4));
				spr_r1.graphics.endFill();
			}
			
			spr_r2.graphics.clear();

			spr_r2.graphics.beginFill(selected ? select_color : 0,selected ? 0.5 : 0.2);
			spr_r2.graphics.drawCircle(x2, y2, r2+10);
			spr_r2.graphics.endFill();

			if (r2 > 0)
			{
				spr_r2.graphics.beginFill(color,selected ? 1.0 : 0.5);
				spr_r2.graphics.drawCircle(x2, y2, Math.max(r2,4));
				spr_r2.graphics.endFill();
			}
			
			// Нормали
			var center:Point = new Point(x1 + (x2 - x1) / 2, y1 + (y2 - y1) / 2);
			var length:Number = MUtils.Length((x2 - x1), (y2 - y1));
			if (length > 0)
			{
				var r_normal:Point = new Point((y2 - y1) / length, -(x2 - x1) / length);
				var l_normal:Point = new Point( -(y2 - y1) / length, (x2 - x1) / length);
				
				if (left)
				{
					line.graphics.lineStyle(4, 0xdd0000);
					line.graphics.moveTo(center.x, center.y);
					line.graphics.lineTo(center.x - l_normal.x * NORMAL_R, center.y - l_normal.y * NORMAL_R);
				}
				if (right)
				{
					line.graphics.lineStyle(4, 0x006600);
					line.graphics.moveTo(center.x, center.y);
					line.graphics.lineTo(center.x - r_normal.x * NORMAL_R, center.y - r_normal.y * NORMAL_R);
				}
			}
		}
		
		public function Data():Object
		{
			var data:Object = new Object;
 
			data.x1 = Main.ConvertFromPixels(x1);
			data.y1 = Main.ConvertFromPixels(Main.NewY(y1));
			data.x2 = Main.ConvertFromPixels(x2);
			data.y2 = Main.ConvertFromPixels(Main.NewY(y2));
			data.r1 = Main.ConvertFromPixels(r1);
			data.r2 = Main.ConvertFromPixels(r2);
			data.player_collision = player_collision;
			data.ball_collision = ball_collision;
			return data;
		}
		
		public function UpdateData(data:Object, draw:Boolean=true):void
		{
 
			trace(data.x1);
			x1 = Main.ConvertToPixels(data.x1);
			trace(data.x1);
			y1 = Main.OldY(Main.ConvertToPixels(data.y1));
			x2 = Main.ConvertToPixels(data.x2);
			y2 = Main.OldY(Main.ConvertToPixels(data.y2));
			r1 = Main.ConvertToPixels(data.r1);
			r2 = Main.ConvertToPixels(data.r2);
			left = data.left;
			right = data.right;
			ball_collision = data.ball_collision;

			player_collision = data.player_collision;
			if (draw) Draw();
		}
	}

}