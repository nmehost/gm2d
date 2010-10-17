package gm2d.ui;

import gm2d.Screen;
import gm2d.Game;
import gm2d.display.BitmapData;
import gm2d.display.Graphics;
import gm2d.display.Sprite;
import gm2d.text.TextField;
import gm2d.events.MouseEvent;
import gm2d.text.TextFieldAutoSize;

class MenuItem
{
   public function new(inText:String,inOnSelect:MenuItem->Void=null)
   {
      gmText = inText;
      gmCheckable = false;
      gmChecked = false;
      onSelect = inOnSelect;
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
   public var gmPopup:PopupMenu;
   public var mChildren:Array<MenuItem>;
}

class PopupMenu extends Window
{
   var mItem:MenuItem;
   var mBar:Menubar;
   var mButtons:Array<Button>;
   var mWidth:Float;
   var mHeight:Float;
   
   public function new(inItem:MenuItem,inBar:Menubar)
   {
      super();
      mItem = inItem;
      mBar = inBar;
      mButtons = [];
      var gfx = graphics;
      var c = inItem.mChildren;
      var w = 10.0;
      var ty = 5.0;
      var me=this;

      if (c!=null)
      {
         for(item in c)
         {
            var id = mButtons.length;
            var but = Button.TextButton(item.gmText,function(){
               Game.closePopup();
               if (item.onSelect!=null) item.onSelect(item);
               });
            but.onCurrentChanged = function(inCurrent:Bool)  { if(inCurrent) me.setItem(id); }
            var l = but.getLabel();
            but.addEventListener(MouseEvent.MOUSE_OVER, function(_) me.setItem(id) );
            mButtons.push(but);
            addChild(but);
            var tw = l.textWidth;
            var th = l.textHeight;
            but.x = 10;
            but.y = ty;
            ty+=th;
            if (tw>w) w = tw;
         }
      }
      mWidth = w+20;
      mHeight = ty;
      setItem(0);
   }

   public function setItem(inIDX:Int)
   {
      for(i in 0...mButtons.length)
      {
         var l = mButtons[i].getLabel();
         l.textColor = i==inIDX ? 0xffffff : 0x000000;
      }
 
      var gfx = graphics;
      gfx.clear();
      gfx.beginFill(0xffffff);
      gfx.drawRoundRect(0.5,0.5,mWidth,mHeight+5,6);
      if (mButtons.length>inIDX)
      {
         gfx.beginFill(0x4040a0);
         var b = mButtons[inIDX];
         gfx.drawRect(0,b.y,mWidth,b.height);
      }
      gfx.endFill();
      gfx.lineStyle(1,0x000000);
      gfx.drawRoundRect(0.5,0.5,mWidth,mHeight+5,6);
   }

   public override function destroy()
   {
      super.destroy();
      if (mBar!=null) mBar.closeMenu(mItem);
   }
}

class Menubar extends Sprite
{
   var mWidth:Float;
   var mHeight:Float;
   var mNextX:Float;
   var mCurrentItem:Int;

   var mItems:Array<MenuItem>;
   var mButtons:Array<Button>;

   public function new()
   {
      super();
      mItems = [];
      mButtons = [];
      mNextX = 2;
      mCurrentItem = -1;
   }


   public function add(inItem:MenuItem)
   {
      var pos = mItems.length;
      mItems.push(inItem);
      
      var me = this;
      var nx = mNextX;
      var but = Button.TextButton(inItem.gmText,function(){me.popup(pos);});
      mButtons.push(but);
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
      but.getLabel().backgroundColor = 0x4040a0;
      but.getLabel().textColor = 0x000000;
      but.addEventListener(MouseEvent.MOUSE_OVER, function(_) me.onMouseItem(pos) );

      but.x = mNextX;
      mNextX += but.width + 10;
      addChild(but);
   }

   function onMouseItem(inPos:Int)
   {
      if (mCurrentItem>=0  && mCurrentItem!=inPos)
         popup(inPos);
   }

   public function popup(inPos:Int)
   {
      Game.closePopup();
      mCurrentItem = inPos;
      mButtons[mCurrentItem].getLabel().background = true;
      mButtons[mCurrentItem].getLabel().textColor = 0xffffff;
      Game.popup( new PopupMenu(mItems[inPos],this), mButtons[inPos].x, mHeight );
   }

   public function closeMenu(inItem:MenuItem)
   {
      if (mCurrentItem>=0 && mItems[mCurrentItem]==inItem)
      {
         mButtons[mCurrentItem].getLabel().background = false;
         mButtons[mCurrentItem].getLabel().textColor = 0x000000;
         mCurrentItem = -1;
      }
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


