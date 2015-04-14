package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author MZ
	 */
	public class Input extends Label
	{
		public var on_change_cb:Function;
		public var key:String;
		public var type:String = "";
		
		public function Input(key:String, text:String,px:int,py:int,w:int,size:int=12,color:int=0,bold:Boolean=false, autosize:String="left") 
		{
			super(text, px, py, size, color, bold, autosize);
			
			this.key = key;
			
			tf.type = "input";
			tf.border = true;
			tf.width = w;
			tf.height = size + 4;
			tf.background = true;
			tf.addEventListener(Event.CHANGE, function (e:Event):void
			{
				if (on_change_cb) on_change_cb(key,tf.text,type);
			});
		}
		
	}

}