package gm2d.ui;

import nme.geom.Rectangle;
import nme.display.Sprite;
import nme.display.Shape;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.DisplayObjectContainer;
import nme.text.TextField;
//import gm2d.ui.HitBoxes;
import nme.geom.Point;
import nme.events.MouseEvent;
import gm2d.ui.HitBoxes;
import gm2d.ui.Dock;
import gm2d.ui.DockPosition;
import gm2d.Game;
import gm2d.skin.Skin;
import gm2d.skin.TabRenderer;
import gm2d.ui.WidgetState;
import gm2d.ui.Layout;


class TabBar extends Widget
{
   public var currentDockable:IDockable;
   public var isMaximised:Bool;

   var tabsWidth:Float;
   var tabsHeight:Float;
   var mHitBoxes:HitBoxes;
   var mDockables:Array<IDockable>;
   var tabRenderer:TabRenderer;
   var allowRestore:Bool;

   public function new(inDockables:Array<IDockable>, inOnHitBox: HitAction->MouseEvent->Void, inAllowRestore:Bool)
   {
      super(["TabBar"] );
      mDockables = inDockables;
      tabRenderer = Skin.tabRenderer();
      mHitBoxes = new HitBoxes(this,inOnHitBox);
      var layout = new Layout();
      layout.setAlignment(Layout.AlignStretch);
      layout.onLayout = layoutTabs;
      setItemLayout(layout);
      mLayout.setAlignment(Layout.AlignStretch | Layout.AlignTop);
      tabsWidth = tabsHeight = 0;
      allowRestore = inAllowRestore;
      //build();
   }

   override public function redraw()
   {
      super.redraw();

      mHitBoxes.clear();

      var flags =   TabRenderer.SHOW_TEXT | TabRenderer.SHOW_ICON | TabRenderer.SHOW_POPUP | TabRenderer.SHOW_CLOSE;
      if (isMaximised && allowRestore)
         flags |=  TabRenderer.SHOW_RESTORE;
      tabRenderer.renderTabs(mChrome, new Rectangle(0,0,tabsWidth,tabsHeight),
          mDockables, currentDockable, mHitBoxes, TabRenderer.TOP, flags);
   }

   public function setTop(inCurrent:IDockable, inIsMaximised:Bool)
   {
      currentDockable = inCurrent;
      isMaximised = inIsMaximised;
      redraw();
   }


   function layoutTabs(inX:Float, inY:Float, inW:Float, inH:Float)
   {
      tabsWidth = inW;
      tabsHeight = inH;
   }
}
