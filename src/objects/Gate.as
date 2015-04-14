package objects 
{
	/**
	 * ...
	 * @author MZ
	 */
	public class Gate extends Line
	{
		public function Gate(data:Object) 
		{
			super(data);
			this.dashed = true;
			this.team = data.team;
			this.color = team_colors[this.team];
			this.left = false;
			this.right = false;
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

			data.team = team;
			return data;
		}
		
		override public function UpdateData(data:Object,draw:Boolean=true):void
		{
			super.UpdateData(data, false);
			team = data.team;
			color = team_colors[team];
			if (draw) Draw();
		}
		
	}

}