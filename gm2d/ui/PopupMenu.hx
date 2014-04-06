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
   var mButtons:Array<Button>;
   //var mWidth:Float;
   //var mHeight:Float;
   
   public function new(inItem:MenuItem,inBar:Menubar=null)
   {
      super(["Button"] );

      mItem = inItem;
      mBar = inBar;
      var layout = new GridLayout(1);
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
               }, ["SimpleButton"]);
            but.getLayout().setAlignment(Layout.AlignLeft);
            but.onCurrentChangedFunc = function(inCurrent:Bool)  { if(inCurrent) me.setItem(id); }
            var l = but.getLabel();
            but.addEventListener(MouseEvent.MOUSE_OVER, function(_) me.setItem(id) );
            mButtons.push(but);
            addChild(but);
            layout.add(new DisplayLayout(but) );
            /*
            var tw = l.textWidth;
            var th = l.height;
            but.x = 10;
            but.y = ty;
            ty+=th;
            if (tw>w) w = tw;
            */
         }
      }
      setItemLayout(layout);
      build();
      //mWidth = w+20;
      //mHeight = ty;
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
      gfx.drawRect(0.5,0.5,mRect.width,mRect.height+5);
      if (mButtons.length>inIDX)
      {
         gfx.beginFill(0x4040a0);
         var b = mButtons[inIDX];
         gfx.drawRect(0,b.y,mRect.width,b.height);
      }
      gfx.endFill();
      gfx.lineStyle(1,0x000000);
      gfx.drawRect(0.5,0.5,mRect.width,mRect.height+5);
   }

   public override function destroy()
   {
      super.destroy();
      #if !waxe
      if (mBar!=null) mBar.closeMenu(mItem);
      #end
   }
}
