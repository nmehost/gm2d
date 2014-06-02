package gm2d.ui;

import gm2d.Screen;
import gm2d.Game;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.events.MouseEvent;
import gm2d.ui.Layout;

class PopupMenu extends Window
{
   var mItem:MenuItem;
   var mBar:Menubar;
   var mButtons:Array<Widget>;
   
   public function new(inItem:MenuItem,inBar:Menubar=null)
   {
      super(["PopupMenu"] );

      mItem = inItem;
      mBar = inBar;
      var layout = new VerticalLayout();
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

            /*
            var but = Button.TextButton(item.gmText,function(){
               Game.closePopup();
               if (item.onSelect!=null) item.onSelect(item);
               }, ["PopupMenuItem","SimpleButton"]);
               */

            var but = new TextLabel(item.gmText,["PopupMenuItem"]);
            but.addEventListener(MouseEvent.CLICK, function(_) {
               Game.closePopup();
               if (item.onSelect!=null) item.onSelect(item);
               });
            but.addEventListener(MouseEvent.MOUSE_OVER, function(_) me.setItem(id) );
            mButtons.push(but);
            addChild(but);
            layout.add(but.getLayout());
         }
      }
      setItemLayout(layout);
      build();
      setItem(0);
   }

   public function setItem(inIDX:Int)
   {
      for(b in 0...mButtons.length)
         mButtons[b].isCurrent = inIDX==b;
   }

   public override function destroy()
   {
      super.destroy();
      #if !waxe
      if (mBar!=null) mBar.closeMenu(mItem);
      #end
   }
}
