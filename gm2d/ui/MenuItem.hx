package gm2d.ui;

import gm2d.Screen;
import gm2d.Game;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.events.MouseEvent;
import nme.events.KeyboardEvent;

class MenuItem
{
   public var text:String;
   public var data:Dynamic;
   public var shortcut(get,set):String;
   public var icon:BitmapData;
   public var checkable:Bool;
   public var checked:Bool;
   public var enabled:Bool;
   public var id:String;
   public var wxId:Int;
   public var onSelect:MenuItem->Void;
   var keyboardAccel:KeyboardAccel;

   //public var gmPopup:PopupMenu;
   public var children:Array<MenuItem>;


   public function new(inText:String,inOnSelect:MenuItem->Void=null)
   {
      text = inText;
      checkable = false;
      checked = false;
      onSelect = inOnSelect;
      enabled = true;
      id = null;
      wxId = -1;
   }

   public function set_shortcut(inShortcut:String) : String
   {
      if (inShortcut==null || inShortcut=="")
         keyboardAccel = null;
      else
         keyboardAccel = new KeyboardAccel(inShortcut);
      return inShortcut;
   }

   public function get_shortcut() : String
   {
      if (keyboardAccel==null)
          return null;
      return keyboardAccel.shortcutText;
   }

   public function onKey(key:KeyboardEvent) : Bool
   {
      if (enabled && keyboardAccel!=null && keyboardAccel.matches(key))
      {
         if (checkable)
            checked = !checked;
         if (onSelect!=null)
            onSelect(this);
         return true;
      }
      if (enabled && children!=null)
          for(child in children)
             if (child!=null && child.onKey(key))
                return true;
      return false;
   }


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

}
