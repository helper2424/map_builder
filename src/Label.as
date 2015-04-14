package  
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author MZ
	 */
	public class Label extends Sprite
	{
		protected var tf:TextField;
		public function Label(text:String,px:int,py:int,size:int=12,color:int=0,bold:Boolean=false, autosize:String="left") 
		{
			var tfmt:TextFormat = new TextFormat("Tahoma", size, 0, bold);
			tf = new TextField();
			tf.defaultTextFormat = tfmt;
			tf.autoSize = autosize;
			tf.text = text!=null ? text : "";
			//tf.border = true;
			this.x = px;
			this.y = py;
			
			addChild(tf);
		}
		
	}

}