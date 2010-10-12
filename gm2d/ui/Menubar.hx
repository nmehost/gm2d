package gm2d.ui;

import gm2d.Screen;
import gm2d.Game;
import gm2d.display.BitmapData;
import gm2d.display.Graphics;
import gm2d.text.TextField;
import gm2d.text.TextFieldAutoSize;

class MenuItem
{
   public function new(inText:String)
   {
      gmText = inText;
      gmCheckable = false;
      gmChecked = false;
   }
   public var onSelect:MenuItem->Void;

   public var gmText:String;
   public var gmData:Dynamic;
   public var gmShortcut:String;
   public var gmIcon:BitmapData;
   public var gmCheckable:Bool;
   public var gmChecked:Bool;
   public var gmPopup:PopupMenu;
}

class PopupMenu extends Window
{
   var mItem:MenuItem;
   
   public function new(inItem:MenuItem)
   {
      super();
      mItem = inItem;
      var gfx = graphics;
      gfx.lineStyle(1,0x000000);
      gfx.beginFill(0xffffff);
      gfx.drawRoundRect(0.5,0.5,100,200,5);
   }
}

class Menubar extends Base
{
   var mWidth:Float;
   var mHeight:Float;
   var mNextX:Float;

   var mItems:Array<MenuItem>;

   public function new()
   {
      super();
      mItems = [];
      mNextX = 2;
   }

   override function wantFocus() { return false; }

   public function add(inItem:MenuItem)
   {
      mItems.push(inItem);
      
      var me = this;
      var nx = mNextX;
      var but = Button.TextButton(inItem.gmText,function(){me.popup(inItem,nx,me.mHeight);});
      but.onCurrentChanged = function(inCurrent:Bool) 
      {
         if (inCurrent)
         {
            var glow:gm2d.filters.BitmapFilter = new gm2d.filters.GlowFilter(0x0000ff, 1.0, 1, 1, 1, 1, false, false);
            but.filters = [ glow ];
         }
         else
            but.filters = null;
      }

      but.x = mNextX;
      mNextX += but.width + 10;
      addChild(but);
   }

   public function popup(inItem:MenuItem,inX:Float,inY:Float)
   {
      Game.popup( new PopupMenu(inItem), inX, inY );
   }

   public function layout(inWidth:Float, inHeight:Float)
   {
       mWidth = inWidth;
       mHeight = inHeight;
       var gfx = graphics;
       gfx.clear();
       renderBackground(gfx,mWidth,mHeight);
   }

   public dynamic function renderBackground(inGfx:Graphics, inW:Float, inH:Float)
   {
       inGfx.beginFill(0xa0a0a0);
       inGfx.drawRect(0,0,inW,inH);
   }
}


