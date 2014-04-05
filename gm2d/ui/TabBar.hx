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
   public var current:IDockable;
   public var isMaximised:Bool;

   var tabsWidth:Float;
   var tabsHeight:Float;
   var mHitBoxes:HitBoxes;
   var mDockables:Array<IDockable>;
   var tabRenderer:TabRenderer;

   public function new(inDockables:Array<IDockable>, inOnHitBox: HitAction->MouseEvent->Void)
   {
      super(["TabBar"] );
      mDockables = inDockables;
      tabRenderer = Skin.tabRenderer( ["Tabs","TabRenderer"] );
      mLayout = new DisplayLayout(this, 20,20);
      mLayout.setAlignment(Layout.AlignStretch | Layout.AlignTop);
      mLayout.setMinSize(20,18);
      tabsWidth = tabsHeight = 0;
      mHitBoxes = new HitBoxes(this,inOnHitBox);
      build();
   }

   override public function redraw()
   {
      super.redraw();

      mHitBoxes.clear();

      var flags =   TabRenderer.SHOW_TEXT | TabRenderer.SHOW_ICON | TabRenderer.SHOW_POPUP;
      if (isMaximised)
         flags |=  TabRenderer.SHOW_RESTORE;
      tabRenderer.renderTabs(mChrome, new Rectangle(0,0,tabsWidth,tabsHeight),
          mDockables, current, mHitBoxes, TabRenderer.TOP, flags);
   }

   public function setTop(inCurrent:IDockable, inIsMaximised:Bool)
   {
      current = inCurrent;
      isMaximised = inIsMaximised;
      redraw();
   }


   override public function onLayout(inX:Float, inY:Float, inW:Float, inH:Float)
   {
      tabsWidth = inW;
      tabsHeight = inH;
   }
}
