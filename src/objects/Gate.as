package objects 
{
import flash.display.Sprite;
import flash.geom.Point;

/**
	 * ...
	 * @author MZ
	 */
	public class Gate extends Line
	{
		protected var x1_rod:int, x2_rod:int, y1_rod:int, y2_rod:int;
		public var rod1:Sprite;
		public var rod2:Sprite;

		public function Gate(data:Object) 
		{
			super(data);
			this.dashed = true;
			this.team = data.team;
			this.color = team_colors[this.team];
			this.left = false;
			this.right = false;

			this.x1_rod = Main.ConvertToPixels(data.x1_rod);
			this.x2_rod = Main.ConvertToPixels(data.x2_rod);
			this.y1_rod = Main.OldY(Main.ConvertToPixels(data.y1_rod));
			this.y2_rod = Main.OldY(Main.ConvertToPixels(data.y2_rod));

			this.rod1 = new Sprite;
			this.rod1.name = "DRAG";
			addChild(this.rod1);

			this.rod2 = new Sprite;
			this.rod2.name = "DRAG";
			addChild(this.rod2);
		}
		
		override public function Data():Object
		{
			var data:Object = new Object;
 
			data.x1 = Main.ConvertFromPixels(x1);
			data.y1 = Main.ConvertFromPixels(Main.NewY(y1));
			data.x2 = Main.ConvertFromPixels(x2);
			data.y2 = Main.ConvertFromPixels(Main.NewY(y2));
			data.r1 = Main.ConvertFromPixels(r1);
			data.r2 = Main.ConvertFromPixels(r2);

			data.x1_rod = Main.ConvertFromPixels(x1_rod);
			data.x2_rod = Main.ConvertFromPixels(x2_rod);
			data.y1_rod = Main.ConvertFromPixels(Main.NewY(y1_rod));
			data.y2_rod = Main.ConvertFromPixels(Main.NewY(y2_rod));

			data.team = team;
			return data;
		}

		override public function Update(s:Sprite, nx:int, ny:int,snap_axis:int,snap_grid:int):void
		{
			super.Update(s, nx, ny, snap_axis, snap_grid);

			var dx:int = 0;
			var dy:int = 0;

			if(s == this.rod1)
			{
				this.x1_rod += nx - lockX;
				this.y1_rod += ny - lockY;
				if (snap_grid>0)
				{
					if (Math.abs(this.x1_rod%snap_grid)!=0)
					{
						var new_x:int = Math.round(this.x1_rod / snap_grid) * snap_grid;;
						dx += new_x - this.x1_rod;
						this.x1_rod = new_x;
					}

					if (Math.abs(this.y1_rod%snap_grid)!=0)
					{
						var new_y:int = Math.round(this.y1_rod / snap_grid) * snap_grid;;
						dy += new_y - this.y1_rod;
						this.y1_rod = new_y;
					}
				}
				if (snap_axis > 0)
				{
					if (Math.abs(this.x1_rod - this.x2_rod) < snap_axis)
					{
						dx += this.x2_rod - this.x1_rod;
						this.x1_rod = this.x2_rod;
					}
					if (Math.abs(this.y1_rod - this.y2_rod) < snap_axis)
					{
						dy += this.y2_rod - this.y1_rod;
						this.y1_rod = this.y2_rod;
					}
				}
				lockX = nx + dx;
				lockY = ny + dy;
				Draw();
			}
			else if(s == this.rod2)
			{
				this.x2_rod += nx - lockX;
				this.y2_rod += ny - lockY;
				if (snap_grid>0)
				{
					if (Math.abs(this.x2_rod%snap_grid)!=0)
					{
						var new_x:int = Math.round(this.x2_rod / snap_grid) * snap_grid;;
						dx += new_x - this.x2_rod;
						this.x2_rod = new_x;
					}

					if (Math.abs(this.y2_rod%snap_grid)!=0)
					{
						var new_y:int = Math.round(this.y2_rod / snap_grid) * snap_grid;;
						dy += new_y - this.y2_rod;
						this.y2_rod = new_y;
					}
				}
				if (snap_axis > 0)
				{
					if (Math.abs(this.x1_rod - this.x2_rod) < snap_axis)
					{
						dx += this.x2_rod - this.x1_rod;
						this.x1_rod = this.x2_rod;
					}
					if (Math.abs(this.y1_rod - this.y2_rod) < snap_axis)
					{
						dy += this.y2_rod - this.y1_rod;
						this.y1_rod = this.y2_rod;
					}
				}
				lockX = nx + dx;
				lockY = ny + dy;
				Draw();
			}

		}
		
		override public function UpdateData(data:Object,draw:Boolean=true):void
		{
			super.UpdateData(data, false);
			team = data.team;
			color = team_colors[team];

			this.x1_rod = Main.ConvertToPixels(data.x1_rod);
			this.x2_rod = Main.ConvertToPixels(data.x2_rod);
			this.y1_rod = Main.OldY(Main.ConvertToPixels(data.y1_rod));
			this.y2_rod = Main.OldY(Main.ConvertToPixels(data.y2_rod));

			if (draw) Draw();
		}

		override public function Shift(dx:int, dy:int):void
		{
			x1 += dx;
			x2 += dx;
			y1 += dy;
			y2 += dy;

			x1_rod += dx;
			x2_rod += dx;
			y1_rod += dy;
			y2_rod += dy;

			Draw();
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
			spr_r1.graphics.drawCircle(x1, y1, 10);
			spr_r1.graphics.endFill();

			spr_r2.graphics.clear();
			spr_r2.graphics.beginFill(selected ? select_color : 0,selected ? 0.5 : 0.2);
			spr_r2.graphics.drawCircle(x2, y2, 10);
			spr_r2.graphics.endFill();

			rod1.graphics.clear();
			rod1.graphics.beginFill(selected ? select_color : 0,selected ? 0.5 : 0.2);
			rod1.graphics.drawCircle(x1_rod, y1_rod, r1+10);
			rod1.graphics.endFill();

			if (r1 > 0)
			{
				rod1.graphics.beginFill(color,selected ? 1.0 : 0.5);
				rod1.graphics.drawCircle(x1_rod, y1_rod, Math.max(r1,4));
				rod1.graphics.endFill();
			}

			rod2.graphics.clear();
			rod2.graphics.beginFill(selected ? select_color : 0,selected ? 0.5 : 0.2);
			rod2.graphics.drawCircle(x2_rod, y2_rod, r2+10);
			rod2.graphics.endFill();

			if (r2 > 0)
			{
				rod2.graphics.beginFill(color,selected ? 1.0 : 0.5);
				rod2.graphics.drawCircle(x2_rod, y2_rod, Math.max(r2,4));
				rod2.graphics.endFill();
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
		
	}

}