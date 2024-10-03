package gm2d.ui;

import nme.display.DisplayObjectContainer;

import gm2d.Screen;
import gm2d.Game;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.display.Sprite;
import nme.text.TextField;
import nme.events.MouseEvent;
import nme.events.KeyboardEvent;
import nme.text.TextFieldAutoSize;
import gm2d.skin.Skin;
import gm2d.ui.IDock;
import gm2d.ui.DockPosition;
import gm2d.ui.Layout;

#if (waxe && !nme_menu)
import wx.Menu;
#end

interface Menubar
{
   public function layout(inWidth:Float) : Float;
   #if (waxe && !nme_menu)
   public function addItems(inMenu:Menu,inItem:MenuItem) : Void;
   #end
   public function add(inItem:MenuItem) : Void;
   public function closeMenu(inItem:MenuItem):Void;
} 

class SpriteMenubar extends Widget implements Menubar implements IDock
{
   var mWidth:Float;
   var mHeight:Float;
   var mNextX:Float;
   var mCurrentItem:Int;
   var mNormalParent:DisplayObjectContainer;

   var mItems:Array<MenuItem>;
   var mButtons:Array<Button>;

   var extraWidgets:Array<Widget>;

   public function new(inParent:DisplayObjectContainer,?dummy:Int,?inLineage:Array<String>,?inAttribs:{})
   {
      super( Widget.addLines(inLineage,["Menubar"]), inAttribs);
      if (inParent!=null)
         inParent.addChild(this);
      mItems = [];
      mButtons = [];
      mNextX = 2;
      mCurrentItem = -1;
      mNormalParent = null;
      extraWidgets = [];
      var layout = new HorizontalLayout();
      setItemLayout(layout);
      applyStyles();
   }


   public function add(inItem:MenuItem)
   {
      var pos = mItems.length;
      mItems.push(inItem);
      
      var nx = mNextX;
      var but = Button.TextButton(inItem.text,function() showMenu(pos), ["MenubarItem", "SimpleButton" ]);
      but.isToggle = true;
      mButtons.push(but);
      but.addEventListener(MouseEvent.MOUSE_OVER, function(_) onMouseItem(pos) );

      but.x = mNextX;
      mNextX += but.width + 10;
      addChild(but);

      var layout = getItemLayout();
      layout.add( but.getLayout() );
   }

   override public function onKeyDown(event:KeyboardEvent ) : Bool
   {
      for(item in mItems)
         if (item.onKey(event))
            return true;
      return false;
   }


   function onMouseItem(inPos:Int)
   {
      if (mCurrentItem>=0  && mCurrentItem!=inPos)
         showMenu(inPos);
   }

   public function showMenu(inPos:Int)
   {
      Game.closePopup();
      mCurrentItem = inPos;
      for(b in 0...mButtons.length)
      {
         mButtons[b].isCurrent = b==mCurrentItem;
         mButtons[b].down = b==mCurrentItem;
      }

      if (mNormalParent==null)
      {
         mNormalParent = parent;
         Game.moveToPopupLayer(this);
      }

      var yPos = mHeight > 0 ? mHeight : mRect.height;

      var stagePos = localToGlobal( new nme.geom.Point(mButtons[inPos].x, yPos) );
      Game.popup( new PopupMenu(mItems[inPos],this), stagePos.x, stagePos.y );
      Game.onClosePopup = function() mCurrentItem = -1;
   }

   public function closeMenu(inItem:MenuItem)
   {
      if (mNormalParent!=null)
      {
         mNormalParent.addChildAt(this,0);
         mNormalParent = null;
      }
      for(b in 0...mButtons.length)
         mButtons[b].down = false;
   }

   public function getLayoutWidth() return mNextX;

   public function layout(inWidth:Float) : Float
   {
      var layout = getLayout();
      var size = layout.getBestSize();
      mHeight = size.y;
      mWidth = inWidth;
      for(w in extraWidgets)
      {
         var th = w.getLayout().getBestHeight();
         if (th>mHeight)
             mHeight = th;
      }

      var w = layout.getBestWidth();

      layout.setRect(0,0,mWidth,mHeight);

      /*
       //Skin.renderMenubar(this,mWidth,mHeight);
       for(but in mButtons)
       {
          var butHeight = but.getLayout().getBestHeight();
          but.y = Std.int( (mHeight-butHeight)/2 );
       }
      */

       var x = w;
       for(w in extraWidgets)
       {
          var tw = w.getLayout().getBestWidth();
          w.align( x, 0, tw, mHeight);
          x+= tw+2;
       }

       return mHeight;
   }

   
   public function setWidgets(inWidgets:Array<Widget>)
   {
      for(w in extraWidgets)
      {
         removeChild(w);
      }

      extraWidgets = [];

      if (inWidgets!=null)
         for(w in inWidgets)
         {
            addChild(w);
            extraWidgets.push(w);
         }
   }


   // IDock....
   public function getDock():IDock { return this; }
   public function canAddDockable(inPos:DockPosition):Bool { return inPos==DOCK_OVER; }
   public function addDockable(child:IDockable,inPos:DockPosition,inSlot:Int):Void
   {
   }
   public function getDockablePosition(child:IDockable):Int
   {
      return -1;
   }
   public function removeDockable(child:IDockable):IDockable
   {
      return null;
   }
   public function raiseDockable(child:IDockable):Bool
   {
      return false;
   }
   public function minimizeDockable(child:IDockable):Bool
   {
      return false;
   }
   public function addSibling(inReference:IDockable,inIncoming:IDockable,inPos:DockPosition):Void
   {
   }
   public function getSlot():Int
   {
      return -1;
   }
   public function setDirty(inLayout:Bool, inChrome:Bool):Void
   {
   }
   #if (waxe && !nme_menu)
   public function addItems(inMenu:Menu,inItem:MenuItem) : Void
   {
      throw "Not wx menubar";
   }
   #end

}




#if (waxe && !nme_menu)



class WxMenubar implements Menubar
{
   var mWxMenuBar:wx.MenuBar;
   var mAdded:Bool;

   public function new(inParent:DisplayObjectContainer)
   {
      mAdded = false;
      mWxMenuBar = new wx.MenuBar();
   }

   public function layout(inWidth:Float) : Float
   {
      if (!mAdded)
      {
         mAdded = true;
         ApplicationMain.frame.menuBar = mWxMenuBar;
      }
      return 0;
   }

   public function addItems(inMenu:Menu,inItem:MenuItem) : Void
   {
      for(child in inItem.children)
      {
         if (child==null)
         {
            inMenu.appendSeparator();
         }
         else
         {
            var text = child.text;
            if (child.shortcut!=null)
                text += "\t" + child.shortcut;
            var bmp:wx.Bitmap = null;
            if (child.icon!=null)
               bmp = wx.Bitmap.fromBytes( child.icon.encode(BitmapData.PNG) );

            if (child.onSelect!=null)
            {
               if (child.wxId<0)
                  child.wxId = wx.Lib.nextID();
               ApplicationMain.frame.handle(child.wxId, function(_) child.onSelect(child) );
            }
            if (child.checkable)
            {
               inMenu.append(child.wxId, text, Menu.CHECK, bmp);
               if (child.checked)
                  inMenu.check(child.wxId, true);
            }
            else
               inMenu.append(child.wxId, text, bmp);
         }
      }
   }
   public function closeMenu(inItem:MenuItem):Void { }

   public function add(inItem:MenuItem)
   {
      //var menu = new Menu(inItem.gmText);
      var menu = new Menu();
      addItems(menu,inItem);
      mWxMenuBar.append(menu,inItem.text);
   }

}


#end


