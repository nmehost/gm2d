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
   public var layoutRows:Int;

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

   public function layout(inW:Float, inDoMove:Bool)
   {
      var max = inW-padX;
      var x = padX;
      var y = padY;
      var row_height = 0.0;
      var maxX = 0.0;
      layoutRows = 1;
      for(item in items)
      {
         if (row_height>0 && x+item.w>max)
         {
            y+=row_height + padY*2;
            x = padX;
            row_height = 0;
            layoutRows++;
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

   override public function isLocked():Bool { return true; }


   /*
   override public function getMinSize():Size
   {
      return new Size(bestWidth,bestHeight);
   }
   */
  
   override public function getBestSize(inSlot:Int):Size
   {
      if (bestSize[inSlot]==null)
      {
         if (inSlot==Dock.DOCK_SLOT_VERT)
            layout(10000,false);
         else
            layout(1,false);

         bestSize[inSlot] = new Size(bestWidth, bestHeight);
      }
      return bestSize[inSlot].clone();
   }


   override public function getLayoutSize(w:Float,h:Float,inLimitX:Bool):Size
   {
      if (inLimitX)
         layout(w,false);
      else
      {
          // Calculate minimum width while keeping height <= h

          // Start with 1 column...
          var minWidth = 0.0;
          for(item in items)
             if (item.w>minWidth)
                minWidth = item.w;

          var tryWidth = minWidth;
          layout(tryWidth,false);
          while(bestHeight>h && layoutRows>1)
          {
             tryWidth += minWidth;
             layout(tryWidth,false);
          }

          //trace("Find " + h + " = " + bestHeight + " -> width " + bestWidth );
      }
      return new Size(bestWidth,bestHeight);
   }
   override public function setRect(x:Float,y:Float,w:Float,h:Float):Void
   {
      layout(w,true);
      //trace("Set size " + w + "x" + h);
      super.setRect(x,y,w,h);
   }
}


