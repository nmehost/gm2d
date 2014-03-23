package gm2d.ui2;

import gm2d.Screen;
import gm2d.Game;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.events.MouseEvent;

class PopupMenu extends Window
{
   var mItem:MenuItem;
   var mBar:Menubar;
   var mButtons:Array<Button>;
   var mWidth:Float;
   var mHeight:Float;
   
   public function new(inItem:MenuItem,inBar:Menubar=null)
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
            mButtons.push(but);
            addChild(but);
            var tw = but.widgetLayout.getBestWidth();
            var th = but.widgetLayout.getBestHeight();
            but.x = 10;
            but.y = ty;
            ty+=th;
            if (tw>w) w = tw;
         }
      }
      mWidth = w+20;
      mHeight = ty;
   }

   public override function destroy()
   {
      super.destroy();
      #if !waxe
      if (mBar!=null) mBar.closeMenu(mItem);
      #end
   }
}
