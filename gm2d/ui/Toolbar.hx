package gm2d.ui;
import gm2d.display.Sprite;
import gm2d.display.BitmapData;
import gm2d.display.DisplayObject;
import gm2d.ui.DockPosition;

import gm2d.ui.Pane;

class ToolbarItem
{
   public function new(inWin:DisplayObject, inWidth:Float, inHeight:Float)
   {
     win = inWin;
     w = inWidth;
     h = inHeight;
   }
   public var win:DisplayObject;
   public var w:Float;
   public var h:Float;
}

class Toolbar extends Pane
{
   var root:Sprite;
   var items:Array<ToolbarItem>;
   public var padX:Float;
   public var padY:Float;

   public function new(inTitle:String)
   {
      root = new Sprite();
      items = new Array<ToolbarItem>();
      padX = 2.0;
      padY = 2.0;
      super(root, inTitle, Dock.RESIZABLE  | Dock.TOOLBAR );
   }

   public function addTool(inTool:DisplayObject,?inWidth:Int, ?inHeight:Int)
   {
      root.addChild(inTool);
      var w = inWidth!=null ? inWidth : inTool.width;
      var h = inHeight!=null ? inHeight : inTool.height;
      items.push(new ToolbarItem(inTool,w,h));
   }

   public function layout(inW:Float, inH:Float,inDoMove:Bool, inLimitX:Bool)
   {
      var max = inW-padX;
      var x = padX;
      var y = padY;
      var row_height = 0.0;
      var maxX = 0.0;
      for(item in items)
      {
         if (row_height>0 && x+item.w>max)
         {
            y+=row_height + padY*2;
            x = padX;
            row_height = 0;
         }
         // TODO: center-y?
         if (inDoMove)
         {
            item.win.x=x;
            item.win.y=y;
         }
         if (item.h>row_height)
            row_height = item.h;
         x+=item.w+padX;
         if (x>maxX)
            maxX = x;
         x+=padX;
      }
      bestWidth = maxX;
      bestHeight = y+row_height+padY;
   }
   /*
   override public function getMinSize():Size
   {
      return new Size(bestWidth,bestHeight);
   }
   */
  
   override public function getBestSize(inPos:DockPosition):Size
   {
      if (inPos==DOCK_TOP || inPos==DOCK_BOTTOM)
         layout(10000,1,false,false);
      else
         layout(1,10000,false,true);
      return new Size(bestWidth,bestHeight);
   }


   override public function getLayoutSize(w:Float,h:Float,inLimitX:Bool):Size
   {
      layout(w,h,false,inLimitX);
      return new Size(bestWidth,bestHeight);
   }
   override public function setRect(x:Float,y:Float,w:Float,h:Float):Void
   {
      layout(w,h,true,true);
      super.setRect(x,y,w,h);
   }
}


