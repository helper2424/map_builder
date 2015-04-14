package objects 
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Point;
	/**
	 * ...
	 * @author MZ
	 */
	public class Arc extends MapObject
	{
		public var arc:Sprite;
		public var spr_r1:Sprite;
		public var spr_r2:Sprite;
		public var spr_r:Sprite;
		
 
		protected var ball_collision:Boolean;

		protected var player_collision:Boolean;
		protected var start_a:Number;
		protected var end_a:Number;
		protected var inside:Boolean;
		protected var outside:Boolean;
		protected var radius:int, r1:int, r2:int;
		
		protected static const NORMAL_R:Number = 15;
		
		public function Arc(data:Object) 
		{
 
			this.x = Main.ConvertToPixels(data.x);
			this.y = Main.OldY(Main.ConvertToPixels(data.y));
			this.r1 = Main.ConvertToPixels(data.r1);
			this.r2 = Main.ConvertToPixels(data.r2);
			this.start_a = data.start_a;
			this.end_a = data.end_a;
			this.radius = Main.ConvertToPixels(data.radius);
			this.inside = data.inside;
			this.outside = data.outside;
			this.player_collision = data.player_collision;
			this.ball_collision = data.ball_collision;
			
			arc = new Sprite;
			arc.name = "DRAG";
			addChild(arc);
			
			spr_r1 = new Sprite;
			addChild(spr_r1);
			spr_r1.name = "DRAG";
			
			spr_r2 = new Sprite;
			addChild(spr_r2);
			spr_r2.name = "DRAG";
			
			spr_r = new Sprite;
			addChild(spr_r);
			spr_r.name = "DRAG";
			
			this.buttonMode = true;
			
			Draw();
		}
		
		override public function Update(s:Sprite, nx:int, ny:int,snap_axis:int,snap_grid:int):void
		{
			if (s == spr_r1)
			{
				start_a = Math.atan2(ny - y , nx - x) * (180.0 / Math.PI);
				
				if (snap_grid>0)
				{
					start_a = Math.round(start_a / snap_grid) * snap_grid;
				}
				if (snap_axis > 0)
				{
					start_a = Math.round(start_a / 90) * 90;
				}
			}
			else
			if (s == spr_r2)
			{
				end_a = Math.atan2(ny - y , nx - x) * (180.0 / Math.PI);
				
				if (snap_grid>0)
				{
					end_a = Math.round(end_a / snap_grid) * snap_grid;
				}
				
				if (snap_axis > 0)
				{
					end_a = Math.round(end_a / 90) * 90;
				}
			}
			else
			if (s == spr_r)
			{
				var dist:Number = MUtils.Length(x - nx, y - ny);
				radius = dist * 2;
				if (radius < 25) radius = 25;
				
				if (snap_grid>0)
				{
					if (Math.abs(radius%snap_grid)!=0) 
					{
						radius = Math.round(radius / snap_grid) * snap_grid;;
					}
				}
				lockX = nx;
				lockY = ny;
			}
			else super.Update(s, nx, ny, snap_axis, snap_grid);
			Draw();
		}
		
		override public function Draw():void
		{
			var cur_color:int = selected ? select_color : color;
			
			var g:Graphics = arc.graphics;
			g.clear();
			g.lineStyle(4, cur_color, selected ? 1.0 : 0.5);
			
			var arc_len:Number = Math.abs(end_a-start_a) * 2 * radius * Math.PI / 360.0;
			var steps:int = (int)(arc_len / 10.0);

			for (var i:int = 0; i <steps;)
			{
				var a1:Number = (start_a + (end_a-start_a) * i/steps) * (Math.PI/180.0);
				var x1:Number = (radius * Math.cos(a1));
				var y1:Number = (radius * Math.sin(a1));
				++i;
				var a2:Number = (start_a + (end_a-start_a) * i/steps) * (Math.PI/180.0);
				var x2:Number = (radius * Math.cos(a2));
				var y2:Number = (radius * Math.sin(a2));

				g.moveTo(x1,y1);
				g.lineTo(x2,y2);
			}
			
			
			// Штанги
			var angle1:Number = start_a * (Math.PI/180.0);
			x1 = (radius * Math.cos(angle1));
			y1 = (radius * Math.sin(angle1));
			var angle2:Number = (start_a + (end_a-start_a)) * (Math.PI/180.0);
			x2 = (radius * Math.cos(angle2));
			y2 = (radius * Math.sin(angle2));
			
			
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

			g.lineStyle(1, 0, 0.5);
			g.moveTo(-10,-0.5);
			g.lineTo(10, -0.5);
			g.moveTo(-0.5,-10);
			g.lineTo( -0.5, 10);
			g.beginFill(0, 0);
			g.drawCircle(0, 0, radius * 0.5);
			g.endFill();
			
			spr_r.graphics.clear();
			var angle:Number = (start_a + (end_a-start_a) * 0.5) * (Math.PI/180.0);
			if (selected)
			{
				var rx:Number = ((radius * 0.5) * Math.cos(angle));
				var ry:Number = ((radius * 0.5) * Math.sin(angle));
				
				g.moveTo(-0.5,-0.5);
				g.lineTo( rx,ry);
		
				spr_r.graphics.beginFill(0, 0.5);
				spr_r.graphics.drawCircle(rx, ry, 5);
				spr_r.graphics.endFill();
			}
			
			
			x1 = ((radius) * Math.cos(angle));
			y1 = ((radius) * Math.sin(angle));
				
			if (inside)
			{
				x2 = ((radius - NORMAL_R) * Math.cos(angle));
				y2 = ((radius - NORMAL_R) * Math.sin(angle));
				
				g.lineStyle(4, 0xdd0000);
				g.moveTo(x1, y1);
				g.lineTo(x2, y2);
			}
			if (outside)
			{
				x2 = ((radius + NORMAL_R) * Math.cos(angle));
				y2 = ((radius + NORMAL_R) * Math.sin(angle));
				
				g.lineStyle(4, 0x006600);
				g.moveTo(x1, y1);
				g.lineTo(x2, y2);
			}
		}
		
		public function Data():Object
		{
			var data:Object = new Object;
 
			data.x = Main.ConvertFromPixels(this.x);
			data.y = Main.ConvertFromPixels(Main.NewY(this.y));

			data.r1 = this.r1;
			data.r2 = this.r2;
			data.start_a = this.start_a;
			data.end_a = this.end_a;
 
			data.radius = Main.ConvertFromPixels(this.radius);
			data.inside = this.inside;
			data.outside = this.outside;
			data.player_collision = this.player_collision;
			data.ball_collision = this.ball_collision;

			return data;
		}
		
		public function UpdateData(data:Object, draw:Boolean=true):void
		{
 
			this.x = Main.ConvertToPixels(data.x);
			this.y = Main.OldY(Main.ConvertToPixels(data.y));
			this.r1 = Main.ConvertToPixels(data.r1);
			this.r2 = Main.ConvertToPixels(data.r2);
			this.start_a = data.start_a;
			this.end_a = data.end_a;
			this.radius = Main.ConvertToPixels(data.radius);
			this.inside = data.inside;
			this.outside = data.outside;
			this.player_collision = data.player_collision;
			this.ball_collision = data.ball_collision;

			if (draw) Draw();
		}
	}

}