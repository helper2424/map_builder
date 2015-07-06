package  
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import objects.Arc;
	import objects.Ball;
	import objects.Gate;
	import objects.Line;
	import objects.MapObject;
	import objects.MapSprite;
	import objects.PlayerSpot;
	import org.as3wavsound.WavSound;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author MZ
	 */
	public class MapField extends Sprite
	{
		public var mapWidth:int;
		public var mapHeight:int;
		private var moving_sprite:Sprite;
		private var selected_object:Array=[];
		private var grid:Sprite;
		private const GRID_SIZE:int = 5;
		private const BIG_GRID:int = 5;
		private var texture_url:String;
		private var minimap_texture:DisplayObject;
		public var banner_top_texture:DisplayObject;
		public var banner_bottom_texture:DisplayObject;
		public var banner_left_texture:DisplayObject;
		public var banner_right_texture:DisplayObject;
		private var minimap:String;
		private var banner_top:String;
		private var banner_bottom:String;
		private var banner_left:String;
		private var banner_right:String;
		private var markup_url:String;
		private var bg_sound_url:String;
		private var friction:Number = 1.0;
		private var _id:int;
		private var type:int;
		private var field_texture:DisplayObject;
		private var field_markup:DisplayObject;
		private var bgsound:*;
		private var layers:Object = new Object;
		private var creating:String = null;
		private var last_team:int = 1;
		
		public function MapField() 
		{
 
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0);
			
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			grid = new Sprite();
			grid.mouseEnabled = false;
		}
		
		private function onMouseMove(e:MouseEvent):void
		{
			if (moving_sprite != null)
			{
				if (moving_sprite.parent is MapObject)
				{
					var pt:Point = this.globalToLocal(new Point(e.stageX,e.stageY));
					(moving_sprite.parent as MapObject).Update(moving_sprite,pt.x,pt.y, e.shiftKey ? GRID_SIZE*2:0, !e.ctrlKey ? GRID_SIZE : 0);
				}
			}
		}
		
		private function onMouseUp(e:MouseEvent):void
		{
			if (moving_sprite != null)
			{
				(moving_sprite.parent as MapObject).EndMove();
				
				moving_sprite = null;
			}
			else 
			{
				if (selected_object.length > 0 && !e.shiftKey) UnselectAll();
			}
		}
			
		private function onMouseDown(e:MouseEvent):void
		{
 
			if(Main.instance.openSettings)
			{
				var settings:Object = GetSettings(e);
				Main.instance.LoadSettings(settings);	
				return;
			}
			

			var pt:Point = this.globalToLocal(new Point(e.stageX,e.stageY));
			var s:Sprite = e.target as Sprite;
			
			if (creating != null)
			{
				if (!e.ctrlKey)
				{
					pt.x = Math.round(pt.x / GRID_SIZE) * GRID_SIZE;
					pt.y = Math.round(pt.y / GRID_SIZE) * GRID_SIZE;
				}
				if (creating == "arc")
				{
					creating = null;
					
					trace("Create Arc");
 
					var a:Arc = new Arc( { x:Main.ConvertFromPixels(pt.x), y:Main.ConvertFromPixels(Main.NewY(pt.y)),radius:Main.ConvertFromPixels(BIG_GRID*GRID_SIZE),

											player_collision:true, shape_collision:true,
											inside:true, outside:false, r1:0, r2:0, start_a:0, end_a:90 } );
					a.Draw();
					layers['shapes'].addChild(a);
					
					s = a.arc;
				}
				else
				if (creating == "line")
				{
					creating = null;
					
					trace("Create line");
 
					var l:Line = new Line( { x1:Main.ConvertFromPixels(pt.x), x2:Main.ConvertFromPixels(pt.x), y1:Main.ConvertFromPixels(Main.NewY(pt.y)), y2:Main.ConvertFromPixels(Main.NewY(pt.y)),

											player_collision:false, shape_collision:true,
											left:true, right:true, r1:0, r2:0 } );
					layers['shapes'].addChild(l);

					s = l.spr_r2;
				}
				else
				if (creating == "gate")
				{
					creating = null;
					
					trace("Create gate");
 
					var g:Gate = new Gate( { x1:Main.ConvertFromPixels(pt.x), x2:Main.ConvertFromPixels(pt.x), y1:Main.ConvertFromPixels(Main.NewY(pt.y)), y2:Main.ConvertFromPixels(Main.NewY(pt.y)),
											team: last_team, r1:0.4, r2:0.4, x1_rod:Main.ConvertFromPixels(pt.x)-10, y1_rod:Main.ConvertFromPixels(Main.NewY(pt.y))+10, x2_rod:Main.ConvertFromPixels(pt.x)-10, y2_rod:Main.ConvertFromPixels(Main.NewY(pt.y))-10});
					layers['shapes'].addChild(g);

					s = g.spr_r2;
				}
				else
				if (creating == "playerspot")
				{
					creating = null;
					
					trace("Create Player Spot");
 
					var p:PlayerSpot = new PlayerSpot( { x:Main.ConvertFromPixels(pt.x), y:Main.ConvertFromPixels(Main.NewY(pt.y)), team: last_team, special: false });
					layers['shapes'].addChild(p);

					s = p.img;
				}
				else
				if (creating == "ball")
				{
					creating = null;
					
					trace("Create Ball");

					var b:Ball = new Ball( { id: getNextBallId(), x:Main.ConvertFromPixels(pt.x), y:Main.ConvertFromPixels(Main.NewY(pt.y)), ball_id: 1, friction: 1, mass:1, bounce: 1, radius: 0.6 });
					layers['shapes'].addChild(b);

					s = b.img;
				}
				else
				if (creating == "mapsprite")
				{
					creating = null;
					
					trace("Create MapSprite");
 
					var ms:MapSprite = new MapSprite( { x:Main.ConvertFromPixels(pt.x), y:Main.ConvertFromPixels(Main.NewY(pt.y)), z_index: 2, url: "http://voltapps.ru/images/r3logo.png" });
					layers[ms.z_index].addChild(ms);

					s = ms.img;
				}
			}
			
			if (s != null)
			{
				if (s.name == "DRAG")
				{
					// Если множественный выбор и не нажат SHIFT - сброс выделенного ранее
					if (selected_object.length > 0 &&  !e.shiftKey) {
						if ( !e.shiftKey ) UnselectAll();
					}

					var mo:MapObject = (s.parent as MapObject);
					// Если множественный выбор и выбранный объект уже выделен, ...
					if (selected_object.length > 0 && mo.isSelected())
					{
						// ... а SHIFT нажат - убираем с него выделение
						if ( e.shiftKey ) {
							selected_object.splice(selected_object.indexOf(mo), 1);
							mo.Select(false);
							return;
						}
					}
					// Обычное добавление в список выделенного
					moving_sprite = s;
					mo.parent.setChildIndex(mo, mo.parent.numChildren - 1);
					selected_object.push(mo);
					mo.Select(true);
					if(!e.shiftKey) mo.StartMove(s,pt.x,pt.y);
				}
			}
		}
		
		public function UnselectAll():void
		{
			for (var i:int = 0; i < selected_object.length;++i)
				selected_object[i].Select(false);
			selected_object = [];
		}
		
		public function getNextBallId():int
		{
			var ball_id:int = 1;
			var layer:Sprite = layers['shapes'] as Sprite;
			var ball_ids:Object = new Object;
			for (var i:int = 0; i < layer.numChildren;++i)
			{
				if (layer.getChildAt(i) is Ball) 
				{
					var b:Ball = layer.getChildAt(i) as Ball;
					ball_ids[b._id] = true;
				}
			}
			
			for (var i:int = 1;;++i)
			{
				if (!ball_ids[i]) return i;
			}
			return -1;
		}
		
		/*public function Shift(dx:int, dy:int):void
		{
			if (moving_sprite != null) 
			{
				for (var i:int = 0; i < selected_object.length;++i)
					selected_object[i].ShiftMove(-dx, -dy);
			}
		}*/
		
		private function updateGrid():void
		{
			grid.graphics.clear();
			grid.graphics.lineStyle(1, 0, 0.1);
			
			for (var i = 0; i < mapWidth / GRID_SIZE;++i)
			{
				if (i > 0 && i % BIG_GRID == 0) grid.graphics.lineStyle(1, 0, 0.2);
				else grid.graphics.lineStyle(1, 0, 0.1);
				grid.graphics.moveTo(i * GRID_SIZE-0.2, 0);
				grid.graphics.lineTo(i * GRID_SIZE-0.2, mapHeight);
			}
			for (var j = 0; j < mapHeight / GRID_SIZE;++j)
			{
				if (j > 0 && j % BIG_GRID == 0) grid.graphics.lineStyle(1, 0, 0.2);
				else grid.graphics.lineStyle(1, 0, 0.1);
				grid.graphics.moveTo(0, j*GRID_SIZE-0.2);
				grid.graphics.lineTo(mapWidth, j*GRID_SIZE-0.2);
			}
			
			grid.graphics.lineStyle(1, 0xff0000, 0.2);
			grid.graphics.moveTo((int)(mapWidth / 2)-0.2 ,0);
			grid.graphics.lineTo((int)(mapWidth / 2)-0.2, mapHeight);
			grid.graphics.moveTo(0, (int)(mapHeight / 2)-0.2);
			grid.graphics.lineTo(mapWidth, (int)(mapHeight / 2)-0.2);
		}
		
		private function gridToFront():void
		{
			setChildIndex(grid, numChildren - 1);
		}

		private function loadStartPositions(pos:Array):void
		{
			trace("Load start positions:");
			
			for (var i:int = 0; i < pos.length; ++i )
			{
				trace("Load player start position for team" + pos[i].team);
				var p:PlayerSpot = new PlayerSpot(pos[i]);
				layers['shapes'].addChild(p);
			}
		}
		
		private function loadArcs(arcs:Array):void
		{
			trace("Load arcs:");
			
			for (var i:int = 0; i < arcs.length; ++i )
			{
				trace("Load arc");
				var a:Arc = new Arc(arcs[i]);
				layers['shapes'].addChild(a);
				a.Draw();
			}
		}
		
		private function loadGates(gates:Array):void
		{
			trace("Load gates:");
			
			for (var i:int = 0; i < gates.length; ++i )
			{
				trace("Load gate for team" + gates[i].team);
				var g:Gate = new Gate(gates[i]);
				layers['shapes'].addChild(g);
				g.Draw();
			}
		}
		
		private function loadSprites(sprites:Array):void
		{
			trace("Load sprites:");
			
			for (var i:int = 0; i < sprites.length; ++i )
			{
				trace("Load sprite: " + sprites[i].url);
				var s:MapSprite = new MapSprite(sprites[i]);
				var z_index:int = sprites[i].z_index;
				if (!layers[z_index])
				{
					layers[z_index] = new Sprite();
					addChild(layers[z_index]);
				}
				layers[z_index].addChild(s);
			}
		}
		
		private function loadBalls(balls:Array):void
		{
			trace("Load balls:");
			
			for (var i:int = 0; i < balls.length; ++i )
			{
				trace("Load ball with _id=" + balls[i]._id);
				var b:Ball = new Ball(balls[i]);
				layers['shapes'].addChild(b);
				b.Draw();
			}
		}
		
		private function loadLines(lines:Array):void
		{
			trace("Load lines:");
			
			for (var i:int = 0; i < lines.length; ++i )
			{
				trace("Load line");
				var l:Line = new Line(lines[i]);
				layers['shapes'].addChild(l);
				l.Draw();
			}
		}
		
		public function GetSettings(e:MouseEvent):Object
		{
			if (e.target.parent is Gate)
			{
				return {target: e.target.parent, settings:(e.target.parent as Gate).Data(), name: "Ворота" };
			}
			else
			if (e.target.parent is Arc)
			{
				return {target: e.target.parent, settings:(e.target.parent as Arc).Data(), name: "Дуга" };
			}
			else
			if (e.target.parent is Line)
			{
				return {target: e.target.parent, settings:(e.target.parent as Line).Data(), name: "Линия" };
			}
			else
			if (e.target.parent is PlayerSpot)
			{
				return { target: e.target.parent, settings:(e.target.parent as PlayerSpot).Data(), name: "Позиция игрока, type: 0 - Обычная позиция, 1 - позиция при разводе мяча, 2 - позиция новго игрока при заходе в матч" };
			}
			else
			if (e.target.parent is Ball)
			{
				return {target: e.target.parent, settings:(e.target.parent as Ball).Data(), name: "Мяч" }
			}
			if (e.target.parent is MapSprite)
			{
				return {target: e.target.parent, settings:(e.target.parent as MapSprite).Data(), name: "Спрайт" }
			}
			else
			{
				return { target:null, settings: { friction: friction, team_colors:MapObject.team_colors, 
													bg_sound_url: bg_sound_url, banner_top: banner_top, 
													banner_bottom: banner_bottom, banner_left: banner_left, 
													banner_right: banner_right, 
													texture_url: texture_url, markup_url: markup_url, minimap: minimap,
 
													width: Main.ConvertFromPixels(mapWidth), height: Main.ConvertFromPixels(mapHeight), type: type, _id:_id }, name: "Поле"};
			}
		}
		
		public function UpdateData(data:Object):void
		{
			if (data.target != null)
			{
				if (data.target is PlayerSpot)
				{
					(data.target as PlayerSpot).UpdateData(data.settings);
				}
				else
				if (data.target is Ball)
				{
					(data.target as Ball).UpdateData(data.settings);
				}
				else
				if (data.target is Gate)
				{
					(data.target as Gate).UpdateData(data.settings);
				}
				else
				if (data.target is Line)
				{
					(data.target as Line).UpdateData(data.settings);
				}
				else
				if (data.target is Arc)
				{
					(data.target as Arc).UpdateData(data.settings);
				}
				else
				if (data.target is MapSprite)
				{
					var ms:MapSprite = (data.target as MapSprite);
					var new_z_index:int = data.settings.z_index;
					if (layers[new_z_index])
					{
						ms.parent.removeChild(ms);
						layers[new_z_index].addChild(ms);
						trace("Update sprite Z index to:" + new_z_index);
					}
					else data.settings.z_index = ms.z_index;
					
					ms.UpdateData(data.settings);
				}
			}
			else
			{
				var obj:Object = data.settings;
				_id = obj._id;
				type = obj.type;
 
				mapWidth = Main.ConvertToPixels(obj.width);
				mapHeight = Main.ConvertToPixels(obj.height);
				texture_url = obj.texture_url;
				banner_top = obj.banner_top;
				banner_bottom = obj.banner_bottom;
				banner_left = obj.banner_left;
				banner_right = obj.banner_right;
				bg_sound_url = obj.bg_sound_url;
				markup_url = obj.markup_url;
				minimap = obj.minimap;
				friction = obj.friction;
				MapObject.team_colors = obj.team_colors;

				
				for (var i:int = 0; i < layers['shapes'].numChildren;++i)
				{
					var o:MapObject = layers['shapes'].getChildAt(i) as MapObject;
					if (o!=null)
					{
						if(o is PlayerSpot) o.SwitchTeam(o.getTeam());
						if(o is Gate) o.SwitchTeam(o.getTeam());
					}
				}
				
				if (!MUtils.isNullOrEmpty(bg_sound_url)) loadBgSound(bg_sound_url);
				if (!MUtils.isNullOrEmpty(texture_url)) loadFieldTexture(texture_url);
				if (!MUtils.isNullOrEmpty(banner_top)) loadBannerTopTexture(banner_top);
				if (!MUtils.isNullOrEmpty(banner_bottom)) loadBannerBottomTexture(banner_bottom);
				if (!MUtils.isNullOrEmpty(banner_left)) loadBannerLeftTexture(banner_left);
				if (!MUtils.isNullOrEmpty(banner_right)) loadBannerRightTexture(banner_right);
				if (!MUtils.isNullOrEmpty(markup_url)) loadFieldMarkupTexture(markup_url);
				
				this.graphics.clear();
				this.graphics.beginFill(0xffffff);
				this.graphics.drawRect(0, 0, mapWidth, mapHeight);
				this.graphics.endFill();
				
				updateGrid();
			}
		}
		
		private function loadBgSound(url:String):void
		{
			trace("loading bg sound");
			if (url.indexOf("http") == -1) url = "http://dev.r3studio.ru/" + url;
			// WAV?
			if (url.indexOf(".wav") != -1)
			{
				var ldr:URLLoader = new URLLoader();
				ldr.dataFormat = URLLoaderDataFormat.BINARY;
				ldr.addEventListener(IOErrorEvent.IO_ERROR, function (e:IOErrorEvent):void
				{
					trace(e);
				});
				ldr.addEventListener(Event.COMPLETE, function (e:Event):void
				{
					bgsound = new WavSound(ldr.data);
					(bgsound as WavSound).play();
				});
				ldr.load(new URLRequest(url));
			}
			else
			{
				bgsound = new Sound();
				bgsound.addEventListener(IOErrorEvent.IO_ERROR, function (e:IOErrorEvent):void
				{
					trace(e);
				});
				bgsound.addEventListener(Event.COMPLETE, function (e:Event):void
				{
					bgsound.play();
				});
				bgsound.load(new URLRequest(url));
			}
		}
		private function loadFieldTexture(url:String):void
		{
			if (url.indexOf("http") == -1) url = "http://dev.r3studio.ru/" + url;
			trace("loading texture: "+url);
			var ldr:Loader = new Loader();
			ldr.load(new URLRequest(url));
			ldr.mouseChildren = false;
			if (field_texture) field_texture.parent.removeChild(field_texture);
			field_texture = ldr;
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, function (e:*):void
			{
				if (banner_bottom_texture) 
				{
					banner_bottom_texture.y = field_texture.height;
					banner_bottom_texture.x = (field_texture.width - banner_bottom_texture.width) / 2;
				}
				if(banner_top_texture) banner_top_texture.x = (field_texture.width - banner_top_texture.width) / 2;
				if (banner_right_texture) 
				{
					banner_right_texture.x = field_texture.width;
				}
			});
			layers[0].addChild(ldr);
		}
		
		private function loadBannerTopTexture(url:String):void
		{
			if (url.indexOf("http") == -1) url = "http://dev.r3studio.ru/" + url;
			trace("loading banner top texture: "+url);
			var ldr:Loader = new Loader();
			ldr.load(new URLRequest(url));
			ldr.mouseChildren = false;
			if (banner_top_texture) banner_top_texture.parent.removeChild(banner_top_texture);
			banner_top_texture = ldr;
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, function (e:*):void
			{
				banner_top_texture.y = - banner_top_texture.height;
				if (field_texture) banner_top_texture.x = (field_texture.width - banner_top_texture.width) / 2;
			});
			layers[0].addChild(banner_top_texture);
		}
		
		private function loadBannerLeftTexture(url:String):void
		{
			if (url.indexOf("http") == -1) url = "http://dev.r3studio.ru/" + url;
			trace("loading banner left texture: "+url);
			var ldr:Loader = new Loader();
			ldr.load(new URLRequest(url));
			ldr.mouseChildren = false;
			if (banner_left_texture) banner_left_texture.parent.removeChild(banner_left_texture);
			banner_left_texture = ldr;
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, function (e:*):void
			{
				banner_left_texture.x = - banner_left_texture.width;
			});
			layers[0].addChild(banner_left_texture);
		}
		
		private function loadBannerRightTexture(url:String):void
		{
			if (url.indexOf("http") == -1) url = "http://dev.r3studio.ru/" + url;
			trace("loading banner right texture: "+url);
			var ldr:Loader = new Loader();
			ldr.load(new URLRequest(url));
			ldr.mouseChildren = false;
			if (banner_right_texture) banner_right_texture.parent.removeChild(banner_right_texture);
			banner_right_texture = ldr;
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, function (e:*):void
			{
				if(field_texture) banner_right_texture.x = field_texture.width;
			});
			layers[0].addChild(banner_right_texture);
		}
		
		private function loadMinimapTexture(url:String):void
		{
			if (url.indexOf("http") == -1) url = "http://dev.r3studio.ru/" + url;
			trace("loading minimap texture: "+url);
			var ldr:Loader = new Loader();
			ldr.load(new URLRequest(url));
			ldr.mouseChildren = false;
			if (minimap_texture) minimap_texture.parent.removeChild(minimap_texture);
			minimap_texture = ldr;
			minimap_texture.x = 5;
			minimap_texture.y = 5;
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, function (e:*):void
			{
				minimap_texture.width = 160;
				minimap_texture.scaleY = minimap_texture.scaleX;
			});
			layers[0].addChild(minimap_texture);
		}
		private function loadBannerBottomTexture(url:String):void
		{
			if (url.indexOf("http") == -1) url = "http://dev.r3studio.ru/" + url;
			trace("loading banner bottom texture: "+url);
			var ldr:Loader = new Loader();
			ldr.load(new URLRequest(url));
			ldr.mouseChildren = false;
			if (banner_bottom_texture) banner_bottom_texture.parent.removeChild(banner_bottom_texture);
			banner_bottom_texture = ldr;
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, function (e:*):void
			{
				if (field_texture) banner_bottom_texture.y = field_texture.height;
				if (field_texture) banner_bottom_texture.x = (field_texture.width - banner_bottom_texture.width) / 2;
			});
			layers[0].addChild(banner_bottom_texture);
		}
		
		private function loadFieldMarkupTexture(url:String):void
		{
			if (url.indexOf("http") == -1) url = "http://dev.r3studio.ru/" + url;
			trace("loading markup texture: "+url);
			var ldr:Loader = new Loader();
			ldr.load(new URLRequest(url));
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, function (e:Event):void
			{
				ldr.x = (mapWidth - ldr.width) * 0.5;
				ldr.y = (mapHeight - ldr.height) * 0.5;
			});
			if (field_markup) field_markup.parent.removeChild(field_markup);
			field_markup = ldr;
			layers[0].addChild(ldr);
		}
		
		private function loadMap(obj:Object):void
		{
			moving_sprite = null;
			selected_object = [];
			
			for (var i = 0; i < 10;++i)
			{
				layers[i] = new Sprite;
				addChild(layers[i]);
			}
			
			layers['shapes'] = new Sprite;

			_id = obj._id;
			type = obj.type;
 
			mapWidth =  Main.ConvertToPixels(obj.width);
			mapHeight = Main.ConvertToPixels(obj.height);

			texture_url = obj.texture_url;
			banner_top = obj.banner_top;
			banner_bottom = obj.banner_bottom;
			banner_left = obj.banner_left;
			banner_right = obj.banner_right;
			bg_sound_url = obj.bg_sound_url;
			markup_url = obj.markup_url;
			minimap = obj.minimap;
			
			if (obj.friction) friction = obj.friction;
			if (!MUtils.isNullOrEmpty(bg_sound_url)) loadBgSound(bg_sound_url);
			if (!MUtils.isNullOrEmpty(texture_url)) loadFieldTexture(texture_url);
			if (!MUtils.isNullOrEmpty(banner_top)) loadBannerTopTexture(banner_top);
			if (!MUtils.isNullOrEmpty(banner_left)) loadBannerLeftTexture(banner_left);
			if (!MUtils.isNullOrEmpty(banner_right)) loadBannerRightTexture(banner_right);
			if (!MUtils.isNullOrEmpty(banner_bottom)) loadBannerBottomTexture(banner_bottom);
			if (!MUtils.isNullOrEmpty(minimap)) loadMinimapTexture(minimap);
			if (!MUtils.isNullOrEmpty(markup_url)) loadFieldMarkupTexture(markup_url);
			MapObject.team_colors = obj.team_colors;

			for (var k in obj)
			{
				var o:*= obj[k];
				
				if (o is Array) 
				{
					if ( k == "lines") loadLines(o);
					else if ( k == "arcs") loadArcs(o);
					else if ( k == "gates") loadGates(o);
					else if ( k == "sprites") loadSprites(o);
					else if ( k == "balls") loadBalls(o);
					else if ( k == "start_positions") loadStartPositions(o);
				}
			}
 
			trace("Map size:" + Main.ConvertFromPixels(mapWidth) + "x" + Main.ConvertFromPixels(mapHeight));
			
			addChild(layers['shapes']);
		}
		private function Delete():void
		{
			moving_sprite = null;
			
			for (var i:int = 0; i < selected_object.length;++i )
			{
				selected_object[i].parent.removeChild(selected_object[i]);
			}
			selected_object = [];
		}
		public function KeyDown(code:int,shift:Boolean):void
		{
			switch (code)
			{
			case Keyboard.H:
				SelectAll();
				break;
			case Keyboard.U:
				UnselectAll();
				break;
			case Keyboard.N:
				grid.visible = !grid.visible;
				break;
			case Keyboard.LEFT:
			case Keyboard.A:// left
				if (hasSelection()) ShiftSelection(shift?-1:-GRID_SIZE,0);
				else this.x += GRID_SIZE;
				break;
			case Keyboard.RIGHT:
			case Keyboard.D:// right
				if (hasSelection()) ShiftSelection(shift?1:GRID_SIZE,0);
				else this.x -= GRID_SIZE;
				break;
			case Keyboard.W:
			case Keyboard.UP:// up
				if (hasSelection()) ShiftSelection(0,shift?-1:-GRID_SIZE);
				else this.y += GRID_SIZE;
				break;
			case Keyboard.DOWN:
			case Keyboard.S:// down
				if (hasSelection()) ShiftSelection(0,shift?1:GRID_SIZE);
				else this.y -= GRID_SIZE;
				break;
			case Keyboard.DELETE:
					Delete();
				break;
			case Keyboard.NUMBER_0:
			case Keyboard.NUMBER_1:
			case Keyboard.NUMBER_2:
			case Keyboard.NUMBER_3:
			case Keyboard.NUMBER_4:
				if (selected_object.length)
				{
					var team_code:int = code-48;
					if (team_code >= MapObject.team_colors.length) break;
					
					last_team = team_code;
					trace("Switch team to",last_team);
					SwitchTeamSelection(last_team);
				}
				break;
			case Keyboard.L:
				creating = "line";
				break;
			case Keyboard.G:
				creating = "gate";
				break;
			case Keyboard.R:
				creating = "arc";
				break;
			case Keyboard.B:
				creating = "ball";
				break;
			case Keyboard.P:
				creating = "playerspot";
				break;
			case Keyboard.M:
				creating = "mapsprite";
				break;
			}
			
		}
		
		private function SelectAll():void
		{
			for (var k in layers)
			{
				var layer = layers[k];
				for (var i:int = 0; i < layer.numChildren;++i)
				{
					var child:MapObject = layer.getChildAt(i) as MapObject;
					if (child != null)
					{
						child.Select(true);
						selected_object.push(child);
					}
				}
			}
		}
		
		private function SwitchTeamSelection(team:int):void
		{
			for (var i:int = 0; i < selected_object.length;++i)
			{
				selected_object[i].SwitchTeam(team);
			}
		}
		private function ShiftSelection(dx:int, dy:int):void
		{
			for (var i:int = 0; i < selected_object.length;++i)
			{
				selected_object[i].Shift(dx, dy);
			}
		}
		
		public function hasSelection():Boolean
		{
			return selected_object.length;
		}
		
		public function Load(json:String):void
		{
			removeChildren();
			
			var data:Object = JSON.parse(json);
			
			layers = new Object;
			
			loadMap(data);
			
			this.graphics.clear();
			this.graphics.beginFill(0xffffff);
			this.graphics.drawRect(0, 0, mapWidth, mapHeight);
			this.graphics.endFill();
			
			updateGrid();
			addChild(grid);
		}
		
		public function Data(stringify:Boolean=true):*
		{
			var data:Object = new Object;
			for (var k in layers)
			{
				if (layers[k].numChildren>0)
				{
					trace("save layer: "+k);
					for (var i:int = 0; i < layers[k].numChildren; ++i)
					{
						var child:DisplayObject = layers[k].getChildAt(i);
						if (child is Arc)
						{
							if (!data["arcs"]) data["arcs"] = new Array();
							data.arcs.push((child as Arc).Data());
						}
						else
						if (child is Gate)
						{
							if (!data["gates"]) data["gates"] = new Array();
							data.gates.push((child as Gate).Data());
						}
						else
						if (child is Ball)
						{
							if (!data["balls"]) data["balls"] = new Array();
							data.balls.push((child as Ball).Data());
						}
						else
						if (child is Line)
						{
							if (!data["lines"]) data["lines"] = new Array();
							data.lines.push((child as Line).Data());
						}
						else
						if (child is MapSprite)
						{
							if (!data["sprites"]) data["sprites"] = new Array();
							data.sprites.push((child as MapSprite).Data());
						}
						else
						if (child is PlayerSpot)
						{
							if (!data["start_positions"]) data["start_positions"] = new Array();
							data.start_positions.push((child as PlayerSpot).Data());
						}
					}
				}
			}
			var teams:Object = new Object;
			if(data.start_positions)
				for (var i:int = 0; i < data.start_positions.length; ++i)
					teams[data.start_positions[i].team]=true;
			var team_count:int = 1;
			for (var t in teams) team_count++;
 
			data["type"] = type;
			data["team_count"] = team_count;
			data["width"] = Main.ConvertFromPixels(mapWidth);
			data["height"] = Main.ConvertFromPixels(mapHeight);
			data["texture_url"] = texture_url;
			data["banner_top"] = banner_top;
			data["banner_bottom"] = banner_bottom;
			data["banner_left"] = banner_left;
			data["banner_right"] = banner_right;
			data["bg_sound_url"] = bg_sound_url;
			data["markup_url"] = markup_url;
			data["minimap"] = minimap;
			data["team_colors"] = MapObject.team_colors;
			data["friction"] = friction;
			return stringify ? JSON.stringify(data) : data;
		}
	}

}