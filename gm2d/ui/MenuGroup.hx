package gm2d.ui;


class MenuGroup<Key>
{
   public var onItem:String->Void;
   public var items:Array<MenuItem>;
   public var callbacks:Array<Void->Void>;
   public var menu:MenuItem;
   public var current:String;
   public var bitmapFactory: String->Int->nme.display.BitmapData;
   public var defaultValue:String;

   public function new(inMenu:MenuItem,?inOnItem:String->Void,defaultValue:String=null)
   {
      menu = inMenu;
      onItem = inOnItem;
      items = [];
      callbacks = [];
      current = defaultValue;
   }
   public function onSelect(inItem:MenuItem)
   {
      var key = inItem.id;
      setState(key);
      if (onItem!=null)
         onItem(current);
      for(i in 0...items.length)
         if (items[i].id==key)
         {
            if (callbacks[i]!=null)
               callbacks[i]();
            break;
         }
      Game.closePopup();
   }
   public function setState(inKey:String)
   {
      current = inKey;
      for(i in 0...items.length)
         items[i].checked = current==items[i].id;
   }

   public function add(inText:String, ?inKey:String, ?inOnItem:Void->Void,?inShortcut:String) : MenuItem
   {
      var item = new MenuItem(inText, onSelect);
      item.id = inKey!=null ? inKey : inText;
      item.shortcut = inShortcut;

      if (inKey!=null && nme.Assets.exists(inKey) )
      {
         var bmp = gm2d.skin.Skin.createBitmapData(inKey,16);
         item.icon = bmp;
      }
      item.checkable = true;
      if (current==null)
         current = item.id;
      item.checked = current==item.id;
      callbacks.push(inOnItem);
      items.push(item);
      menu.add(item);
      return item;
   }
}



