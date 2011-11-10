package gm2d.ui;

import gm2d.Screen;
import gm2d.Game;
import gm2d.display.BitmapData;
import gm2d.display.Graphics;
import gm2d.events.MouseEvent;

class MenuItem
{
   public function new(inText:String,inOnSelect:MenuItem->Void=null)
   {
      gmText = inText;
      gmCheckable = false;
      gmChecked = false;
      onSelect = inOnSelect;
      gmID = -1;
   }
   public var onSelect:MenuItem->Void;

   public function add(inItem:MenuItem)
   {
      if (mChildren==null)
         mChildren = [];
      mChildren.push(inItem);
   }

   public var gmText:String;
   public var gmData:Dynamic;
   public var gmShortcut:String;
   public var gmIcon:BitmapData;
   public var gmCheckable:Bool;
   public var gmChecked:Bool;
   public var gmID:Int;
   //public var gmPopup:PopupMenu;
   public var mChildren:Array<MenuItem>;
}
