package {
	import flashx.textLayout.formats.Float;
	import flash.display.FrameLabel;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import vk.gui.ScrollBar;

	import flash.net.URLLoaderDataFormat;
	import flash.events.IOErrorEvent;
	import flash.external.ExternalInterface;
	import flash.ui.Keyboard;

	/**
	 * ...
	 * @author MZ
	 */
	[Frame(factoryClass="Preloader")]
	public class Main extends Sprite {
		static private const PIXELS_PER_SIZE : Number = Number(20);
		private var scroll : ScrollBar;
		private var code_field_tf : TextField;
		private var code_field_buttons : Sprite;
		private var default_map_code : String = "{\"width\":54,\"height\":27,\"team_colors\": [231,14373483,27055]}";
		private var map : MapField;
		private var menu_bar : Menu;
		private var map_settings : Window;
		private var map_list : Window;
		private var help_window : Window;
		private var code_field : Sprite;
		private var settings_data : Object;
		private var accept_but : TextButton;
		private var update_but : TextButton;
		private var show_hide_text_but : TextButton
		private var update_text_but : TextButton;
		private var pretty_code_but : TextButton;
		public var openSettings : Boolean;
		private var code_field_h : Number = 250;
		private var last_opened_filename : String = "new_map.json";
		static private var _instance : Main;

		public static function get instance() : Main {
			return _instance;
		}

		public static function set instance(val : Main) : void {
			_instance = val;
		}

		static public function ConvertFromPixels(pixels : Number) : Number {
			return pixels / PIXELS_PER_SIZE;
		}

		static public function NewY(val : Number) : Number {
			return Main.instance.map.mapHeight - val;
		}

		static public function OldY(val : Number) : Number {
			return Main.instance.map.mapHeight - val;
		}

		static public function ConvertToPixels(value : Number) : Number {
			return value * PIXELS_PER_SIZE;
		}

		public function Main() : void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);

			Main.instance = this;
		}

		private function init(e : Event = null) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point

			// scroll
			scroll = new ScrollBar(stage.stageWidth - ScrollBar.W, 2, code_field_h, stage.stageWidth, stage.stageHeight, true);
			scroll.visible = false;

			scroll.addEventListener(Event.SCROLL, function(e : Event) : void {
				code_field_tf.scrollV = scroll.scrollPosition + 1;
			});

			map = new MapField();
			addChild(map);

			menu_bar = new Menu();
			menu_bar.Draw(stage.stageWidth);
			addChild(menu_bar);

			accept_but = new TextButton(12, "Сохранить", false, true);
			accept_but.addEventListener(MouseEvent.CLICK, function(e : MouseEvent) : void {
				ApplySettings();
			});

			var load_but : TextButton = new TextButton(12, "Открыть...");
			load_but.on_click = openFileDialog;
			menu_bar.addItem(load_but);

			var save_as_but : TextButton = new TextButton(12, "Сохранить как...");
			save_as_but.on_click = saveFileDialog;
			menu_bar.addItem(save_as_but);

			var save_in_bd_but : TextButton = new TextButton(12, "Сохранить в БД");
			save_in_bd_but.on_click = function(but : *) : void {
				if (ExternalInterface.available) {
					ExternalInterface.call("function(s){ if(console)console.log(s); }", "SaveMap");
					ExternalInterface.call("SaveMap", map.Data(false));
				}
			};
			menu_bar.addItem(save_in_bd_but);
			var map_list_but : TextButton = new TextButton(12, "Список карт");
			map_list_but.on_click = function(but : *) : void {
				LoadMapList();
			};
			menu_bar.addItem(map_list_but);

			var help_but : TextButton = new TextButton(12, "Справка...");
			help_but.on_click = function(but : *=null) : void {
				help_window.visible = true;
			};
			menu_bar.addItem(help_but);

			var tfmt : TextFormat = new TextFormat("Courier New", 14, 0);
			code_field_tf = new TextField();
			code_field_tf.x = 1;
			code_field_tf.y = 2;
			code_field_tf.width = stage.stageWidth - scroll.width - 3;
			code_field_tf.height = code_field_h;
			code_field_tf.multiline = true;
			code_field_tf.visible = false;
			code_field_tf.type = "input";
			code_field_tf.border = true;
			code_field_tf.background = true;
			code_field_tf.defaultTextFormat = tfmt
			code_field_tf.text = MUtils.StringToPrettyJSON(default_map_code);
			code_field_tf.addEventListener(Event.CHANGE, function(e : Event) : void {
				scroll.init(code_field_tf.maxScrollV - 1, code_field_tf.textHeight / code_field_tf.numLines);
			});

			scroll.init(0, code_field_tf.textHeight / code_field_tf.numLines);

			code_field_tf.addEventListener(Event.SCROLL, function(e : Event) : void {
				scroll.scrollPosition = code_field_tf.scrollV - 1;
				trace(scroll.scrollPosition);
			});

			code_field = new Sprite();
			code_field.addChild(scroll);

			code_field_buttons = new Sprite;

			show_hide_text_but = new TextButton(14, "Показать код");
			show_hide_text_but.y = 5;
			show_hide_text_but.x = 5;
			show_hide_text_but.addEventListener(MouseEvent.CLICK, function(e : MouseEvent) : void {
				ShowCode(!code_field_tf.visible);
			});
			code_field_buttons.addChild(show_hide_text_but);

			update_but = new TextButton(14, "Загрузить из кода");
			update_but.y = 5;
			update_but.x = show_hide_text_but.x + show_hide_text_but.width + 5;
			update_but.visible = false;
			update_but.addEventListener(MouseEvent.CLICK, function(e : MouseEvent) : void {
				map.Load(code_field_tf.text);
			});
			code_field_buttons.addChild(update_but);
			update_text_but = new TextButton(14, "Считать в код");
			update_text_but.y = 5;
			update_text_but.x = update_but.x + update_but.width + 5;
			update_text_but.visible = false;
			update_text_but.addEventListener(MouseEvent.CLICK, function(e : MouseEvent) : void {
				code_field_tf.text = MUtils.StringToPrettyJSON(map.Data());
				scroll.init(code_field_tf.maxScrollV - 1, code_field_tf.textHeight / code_field_tf.numLines);
			});
			code_field_buttons.addChild(update_text_but);

			pretty_code_but = new TextButton(14, "Красивый код");
			pretty_code_but.y = 5;
			pretty_code_but.x = update_text_but.x + update_text_but.width + 5;
			pretty_code_but.visible = false;
			pretty_code_but.addEventListener(MouseEvent.CLICK, function(e : MouseEvent) : void {
				code_field_tf.text = MUtils.StringToPrettyJSON(code_field_tf.text);
				scroll.init(code_field_tf.maxScrollV - 1, code_field_tf.textHeight / code_field_tf.numLines);
			});
			code_field_buttons.addChild(pretty_code_but);

			code_field_buttons.y = 0;
			code_field.addChild(code_field_buttons);
			code_field.addChild(code_field_tf);

			RedrawCodeField();

			code_field.y = stage.stageHeight - 30;
			addChild(code_field);

			stage.addEventListener(Event.RESIZE, function(e : Event) : void {

				trace("Resize to:" + stage.stageWidth + "x" + stage.stageHeight);

				RedrawCodeField();

				menu_bar.Draw(stage.stageWidth);
				map_list.Resize(stage.stageWidth, stage.stageHeight);
				map_settings.Resize(stage.stageWidth, stage.stageHeight);
				help_window.Resize(stage.stageWidth, stage.stageHeight);

				checkMapView();
			});
			// map list
			map_list = new Window(stage.stageWidth, stage.stageHeight);
			map_list.visible = false;
			addChild(map_list);

			// settings
			map_settings = new Window(stage.stageWidth, stage.stageHeight);
			map_settings.visible = false;
			addChild(map_settings);

			help_window = new Window(stage.stageWidth, stage.stageHeight);
			help_window.visible = false;
			var legend : TextField = new TextField;
			legend.defaultTextFormat = tfmt;
			legend.multiline = true;
			legend.width = 450;
			// legend.border = true;
			legend.wordWrap = "normal";
			legend.htmlText = "<p align='center'><b><font size='22'>Справка</font></b></p>";
			legend.htmlText += "<p align='center'><b><font size='14' color='#dd0000'>Версия: 1.0.14</font></b></p>";
			legend.htmlText += "<b><font size='16' color='#0000dd'>Редактирование</font></b>\n<b>Колесико</b> - прокрутка по вертикали\n<b>Колесико+Alt</b> - прокрутка по горизонтали";
			legend.htmlText += "<b>Левая кнопка мыши</b> - выделить и перетащить\n<b>Shift</b> - фиксация оси\n<b>Ctrl</b> - отмена привязки к сетке\n<b>E + клик на объект</b> - редактирование";
			legend.htmlText += "\n<b>0,1,2,3</b> - смена команды у линии, ворот, позиции игрока";
			legend.htmlText += "\n<b>WASD/Стрелки</b> - сдвиг вида или объекта на шаг сетки";
			legend.htmlText += "<b>WASD/Стрелки + Shift</b> - сдвиг объекта попиксельно";
			legend.htmlText += "\n<b><font size='16' color='#0000dd'>Создание</font></b>";
			legend.htmlText += "<b>L</b> - линия\n<b>G</b> - ворота\n<b>B</b> - мяч\n<b>P</b> - позиция игрока\n<b>M</b> - спрайт\n<b>R</b> - дуга\n\n";

			legend.htmlText += "<b><font size='16' color='#0000dd'>Другое</font></b>\n";
			legend.htmlText += "<b>N</b> - показать/скрыть сетку\n";
			legend.htmlText += "<b>H</b> - выделить все\n";
			legend.htmlText += "<b>U</b> - убрать выделение\n";
			legend.htmlText += "<b>Shift+O</b> - открыть файл\n";
			legend.htmlText += "<b>Shift+S</b> - сохранить файл\n";
			legend.htmlText += "\n<b><font size='16' color='#0000dd'>Что нового?</font></b>";
			legend.htmlText += "<b><font size='14' color='#dd0000'>Версия 1.0.14</font></b>";
			legend.htmlText += "+ Добавлено special для StartPosition";
			legend.htmlText += "<b><font size='14' color='#dd0000'>Версия 1.0.13</font></b>";
			legend.htmlText += "+ Добавлена поддержка боковых баннеров";
			legend.htmlText += "<b><font size='14' color='#dd0000'>Версия 1.0.12</font></b>";
			legend.htmlText += "+ Добавлена поддержка баннеров (верх и низ)";
			legend.htmlText += "<b><font size='14' color='#dd0000'>Версия 1.0.11</font></b>";
			legend.htmlText += "+ Возможность убирать выделение с элемента";
			legend.htmlText += "<b><font size='14' color='#dd0000'>Версия 1.0.10</font></b>";
			legend.htmlText += "+ Добавлено трение для поверхности карты";
			legend.htmlText += "<b><font size='14' color='#dd0000'>Версия 1.0.9</font></b>";
			legend.htmlText += "+ Загрузка карт при нажатии на <i>Список карт</i>";
			legend.htmlText += "<b><font size='14' color='#dd0000'>Версия 1.0.8</font></b>";
			legend.htmlText += "- Текстура мяча теперь не скейлится (т.к. и не должна была)";
			legend.htmlText += "<b><font size='14' color='#dd0000'>Версия 1.0.7</font></b>";
			legend.htmlText += "+ Прокрутка в окнах на колесико";
			legend.htmlText += "- Смена цвета команды у ворот";
			legend.htmlText += "- Загрузка и сохранение дуг";
 

			legend.height = legend.textHeight + 10;
			help_window.content.addChild(legend);
			help_window.Draw();
			addChild(help_window);

			map.Load(default_map_code);

			map.addEventListener(MouseEvent.MOUSE_WHEEL, function(e : MouseEvent) : void {
				var dx : int = 0;
				var dy : int = 0;
				if (e.altKey) {
					dx = e.delta * 15;
					var bx : int = map.x += dx;
					checkMapView();
					dx -= bx - map.x;
				} else {
					dy = e.delta * 15;
					var by : int = map.y += dy;
					checkMapView();
					dy -= by - map.y;
				}

				// map.Shift(dx,dy);
			});

			stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e : KeyboardEvent) : void {
				if (map_settings.visible) return;
				if (stage.focus == code_field_tf) return;

				if (e.keyCode == Keyboard.O && e.shiftKey) {
					openFileDialog();
				} else if (e.keyCode == Keyboard.S && e.shiftKey) {
					saveFileDialog();
				} else if (e.keyCode == Keyboard.E) {
					openSettings = true;
				} else {
					map.KeyDown(e.keyCode, e.shiftKey);
					checkMapView();
				}
			});

			stage.addEventListener(KeyboardEvent.KEY_UP, function(e : KeyboardEvent) : void {
				if (e.keyCode == Keyboard.E) {
					openSettings = false;
				}
			});

			// Контекстное меню
			var cmenu : ContextMenu = new ContextMenu();
			cmenu.hideBuiltInItems();

			var item : ContextMenuItem = new ContextMenuItem("Открыть...              Shift+O");
			cmenu.customItems.push(item);
			item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(e : ContextMenuEvent) : void {
				openFileDialog();
			});

			item = new ContextMenuItem("Сохранить как...    Shift+S");
			cmenu.customItems.push(item);
			item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(e : ContextMenuEvent) : void {
				saveFileDialog();
			});

			item = new ContextMenuItem("Справка...", true);
			cmenu.customItems.push(item);
			item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(e : ContextMenuEvent) : void {
				help_window.visible = true;
			});

			this.contextMenu = cmenu;
		}

		private function LoadMapList() : void {
			map_list.content.removeChildren();
			var label : Label = new Label("Загрузка...", 0, 0, 14, 0);
			map_list.content.addChild(label);
			map_list.Draw();
			map_list.visible = true;

			var loader : URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(e : IOErrorEvent) : void {
				trace("Error:" + e.errorID);
				map_list.content.removeChildren();
				var label : Label = new Label("ПОТРАЧЕНО", 0, 0, 18, 0, true);
				map_list.content.addChild(label);
				map_list.Draw();
			});
			loader.addEventListener(Event.COMPLETE, function(e : Event) : void {
				map_list.content.removeChildren();

				if ((loader.data as String).charAt(0) != '[') {
					var label : Label = new Label("ПОТРАЧЕНО", 0, 0, 18, 0, true);

					map_list.content.addChild(label);
					map_list.Draw();
					return;
				}
 
				var maps : Array = JSON.parse(loader.data) as Array;
				var but_y : int = 0;
				if (maps) {
					for (var i : int = 0; i < maps.length; ++i) {
						var map_but : TextButton = new TextButton(14, "Карта №" + maps[i]);
						map_but.userData = {id:maps[i]};
						map_but.on_click = function(but : TextButton) : void {
							LoadMapById(but.userData.id);
						};

						map_but.y = but_y;
						map_list.content.addChild(map_but);
						but_y += map_but.height + 10;
					}
					map_list.Draw();
				}
			});
 

			if (ExternalInterface.available) loader.load(new URLRequest("/maps"));
			else loader.load(new URLRequest("http://dev.r3studio.ru:8081/maps"));
		}

		private function LoadMapById(id : int) : void {
			var loader : URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(e : IOErrorEvent) : void {
				trace("Error:" + e.errorID);
			});
			loader.addEventListener(Event.COMPLETE, function(e : Event) : void {
				var map_data : Object = JSON.parse(loader.data);
				if (map_data && map_data._id) {

					map_list.visible = false;
					map.Load(loader.data);
				}
			});
 
			if (ExternalInterface.available) loader.load(new URLRequest("/map/" + id));
			else loader.load(new URLRequest("http://dev.r3studio.ru:8081/map/" + id));
		}

		private function RedrawCodeField() : void {

			scroll.x = stage.stageWidth - scroll.width;
			code_field_tf.width = stage.stageWidth - scroll.width - 3;

			code_field.graphics.clear();
			code_field.graphics.lineStyle(1);
			code_field.graphics.beginFill(0xeeeeee);
 
			code_field.graphics.drawRect(-1, 0, stage.stageWidth + 2, 30 + (code_field_tf.visible ? code_field_h : 0));
			code_field.graphics.endFill();

			code_field.y = stage.stageHeight - 30 - (code_field_tf.visible ? code_field_h : 0);
			code_field_buttons.y = (code_field_tf.visible ? code_field_h : 0)
		}

		private function ShowCode(show : Boolean) : void {

			update_but.visible = show;
			update_text_but.visible = show;
			pretty_code_but.visible = show;
			code_field_tf.visible = show;
			scroll.visible = show;
 
			show_hide_text_but.update(14, show ? "Скрыть код" : "Показать код");
			RedrawCodeField();
			checkMapView();
		}

		private function ApplySettings() : void {

			map_settings.visible = false;
			map.UpdateData(settings_data);
			checkMapView();
		}
 

		public function LoadSettings(data : Object) : void {
			map_settings.content.removeChildren();

			var settings : Array = new Array;
			for (var k in data.settings) settings.push({key:k, value:data.settings[k]});
			settings.sortOn("key");

			settings_data = data;

			var wrap_left : Sprite = new Sprite;
			var wrap_right : Sprite = new Sprite;
			var cy : int = 0;
			for (var i : int = 0; i < settings.length; ++i) {
				var peer : Object = settings[i];
				var key : String = peer.key;
				var val : * = peer.value;

				var label : Label = new Label(key + ":", 0, cy, 12);
				label.x = - label.width;
				wrap_left.addChild(label);
				if (val is Boolean) {
					var button : TextButton = new TextButton(12, val);
					button.y = cy;
					button.userData = peer;
					button.addEventListener(MouseEvent.CLICK, function(e : MouseEvent) : void {
						var tb : TextButton = (e.currentTarget as TextButton);
						tb.userData.value = !(tb.userData.value as Boolean);
						trace(tb.userData.key, "=", tb.userData.value);
						tb.update(12, tb.userData.value);
						UpdateSettingsOption(tb.userData.key, tb.userData.value, "boolean");
					});
					wrap_right.addChild(button);
				} else if (val is Array) {
					var str : String = "";
					var ar : Array = (val as Array);
					for (var j : int = 0; j < ar.length; ++j) {
						if (j > 0) str += ",";
						var v : Number = ar[j];
						str += v > 255 ? "0x" + v.toString(16) : v;
					}
					var input : Input = new Input(key, str, 0, cy, 250, 12);
					input.type = "array";
					input.on_change_cb = UpdateSettingsOption;
					wrap_right.addChild(input);
				} else {
					var input : Input = new Input(key, val, 0, cy, 250, 12);

					input.type = val is Number ? "number" : "string";
					input.on_change_cb = UpdateSettingsOption;
					wrap_right.addChild(input);
				}
				cy += 25;
			}
 

			var title : Label = new Label(data.name, 0, 0, 12, 0, true);
			map_settings.content.addChild(title);

			wrap_left.y = wrap_right.y = 20 + title.height;
			// контент
			wrap_left.x = wrap_left.width;
			wrap_right.x = wrap_left.x;
			if (wrap_right.width < wrap_left.width) {
				wrap_right.graphics.moveTo(0, 0);
				wrap_right.graphics.lineTo(wrap_left.width, 0);
			}

			map_settings.content.addChild(wrap_left);
			map_settings.content.addChild(wrap_right);

			accept_but.y = map_settings.content.height + 20;
			map_settings.content.addChild(accept_but);

			map_settings.Draw();

			accept_but.x = (map_settings.content.width - accept_but.width) / 2;
			title.x = (map_settings.content.width - title.width) / 2;

			map_settings.visible = true;
		}

		private function UpdateSettingsOption(key : String, value : *, type : String) {
			trace("UpdateSettingsOption():", key, "=", value, "(", type, ")");

			if (type == "boolean") settings_data.settings[key] = value;
			else if (type == "string") settings_data.settings[key] = value;
			else if (type == "number") settings_data.settings[key] = MUtils.readNumber(value);
			else if (type == "array") {
				var ar : Array = (value as String).split(",");
				for (var i : int = 0; i < ar.length; ++i) {

					ar[i] = MUtils.readNumber(ar[i]);
				}
				settings_data.settings[key] = ar;
			}
		}
 

		private function checkMapView() : void {
			var banner_left_w : Number = 0;
			if (map.banner_left_texture) banner_left_w = map.banner_left_texture.width;
			var banner_right_w : Number = 0;
			if (map.banner_right_texture) banner_right_w = map.banner_right_texture.width;

			if (map.mapWidth + banner_left_w + banner_right_w > stage.stageWidth) {
				if (map.x < stage.stageWidth - map.mapWidth - banner_right_w) map.x = stage.stageWidth - map.mapWidth - banner_right_w;
				if (map.x > banner_left_w) map.x = banner_left_w;
			} else {
				map.x = (stage.stageWidth - map.mapWidth) * 0.5;
			}

			var banner_top_h : Number = 0;
			if (map.banner_top_texture) banner_top_h = map.banner_top_texture.height;
			var banner_bottom_h : Number = 0;
			if (map.banner_bottom_texture) banner_bottom_h = map.banner_bottom_texture.height;

			if (map.mapHeight + banner_top_h + banner_bottom_h > stage.stageHeight) {
				var viewH : Number = (stage.stageHeight - 30 - (code_field_tf.visible ? code_field_h : 0));
				if (map.y < viewH - map.mapHeight - banner_bottom_h) map.y = viewH - map.mapHeight - banner_bottom_h;
				if (map.y > menu_bar.height + banner_top_h) map.y = menu_bar.height + banner_top_h;
			} else {
				map.y = (stage.stageHeight - map.mapHeight) * 0.5;
			}
		}

		private function saveFile() : void {
		}

		private function saveFileDialog(but : *=null) : void {
			var fileToOpen : FileReference = new FileReference();
			fileToOpen.save(map.Data(), last_opened_filename);
		}

		private function openFileDialog(but : *=null) : void {
			var fileToOpen : FileReference = new FileReference();
			var filter : FileFilter = new FileFilter("Файл карты в формате JSON", "*.json;*.txt");
			fileToOpen.browse([filter]);
			fileToOpen.addEventListener(Event.SELECT, function(event : Event) : void {
				trace("Loading file: " + fileToOpen.name);
				fileToOpen.load();
				// load it
			});
			fileToOpen.addEventListener(Event.COMPLETE, function(event : Event) : void {
				trace("Load complete: " + fileToOpen.name);
				last_opened_filename = fileToOpen.name;
				var data : String = fileToOpen.data.toString();
				code_field_tf.text = MUtils.StringToPrettyJSON(data);
				scroll.init(code_field_tf.maxScrollV - 1, code_field_tf.textHeight / code_field_tf.numLines);

				map.Load(data);
			});
		}
	}
}