package gm2d.ui;

import gm2d.Screen;
import gm2d.Game;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.events.MouseEvent;

class MenuItem
{
   public function new(inText:String,inOnSelect:MenuItem->Void=null)
   {
      text = inText;
      checkable = false;
      checked = false;
      onSelect = inOnSelect;
      id = null;
   }
   public var onSelect:MenuItem->Void;

   public function addSeparator()
   {
      add(null);
   }
   public function add(inItem:MenuItem)
   {
      if (children==null)
         children = [];
      children.push(inItem);
   }

   public var text:String;
   public var data:Dynamic;
   public var shortcut:String;
   public var icon:BitmapData;
   public var checkable:Bool;
   public var checked:Bool;
   public var id:String;

   //public var gmPopup:PopupMenu;
   public var children:Array<MenuItem>;
}
