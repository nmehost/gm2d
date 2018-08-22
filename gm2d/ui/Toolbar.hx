package gm2d.ui;
import nme.display.Sprite;
import nme.display.BitmapData;
import nme.display.DisplayObject;
import gm2d.ui.DockPosition;
import nme.geom.Rectangle;

import gm2d.ui.Pane;

/*
class ToolbarItem
{
   public function new(inWin:Widget, inWidth:Float, inHeight:Float)
   {
     win = inWin;
     w = inWidth;
     h = inHeight;
   }
   public var win:Widget;
   public var w:Float;
   public var h:Float;
}
*/

class Toolbar extends Pane
{
   var root:Sprite;
   var items:Array<Widget>;
   public var padX:Float;
   public var padY:Float;
   public var layoutRows:Int;

   public function new(inTitle:String)
   {
      root = new Sprite();
      items = new Array<Widget>();
      padX = 2.0;
      padY = 2.0;
      super(root, inTitle, Dock.RESIZABLE  | Dock.TOOLBAR );
      getLayout().setAlignment( Layout.AlignTop | Layout.AlignLeft );
      getLayout().onLayout = setRect;
   }

   public function addTool(inTool:Widget)
   {
      root.addChild(inTool);
      items.push(inTool);
   }
   public function getRoot() { return root; }

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
         var size = item.getLayout().getBestSize();
         var w = size.x;
         var h = size.y;
         if (row_height>0 && x+w>max)
         {
            y+=row_height + padY*2;
            x = padX;
            row_height = 0;
            layoutRows++;
         }
         if (inDoMove)
            item.getLayout().setRect(x,y,w,h);
         if (h>row_height)
            row_height = h;
         x+=w+padX;
         if (x>maxX)
            maxX = x;
         x+=padX;
      }
      setBestSize(maxX,y+row_height+padY);
   }

   override public function isLocked():Bool { return true; }


   /*
   override public function getMinSize():Size
   {
      return new Size(bestWidth,bestHeight);
   }
  
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
   */


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
          {
             var w = getLayout().getBestSize().x;
             if (w>minWidth)
                minWidth = w;
          }

          var tryWidth = minWidth;
          layout(tryWidth,false);
          while(getLayout().getBestSize().y>h && layoutRows>1)
          {
             tryWidth += minWidth;
             layout(tryWidth,false);
          }

          //trace("Find " + h + " = " + bestHeight + " -> width " + bestWidth );
      }
      return getLayout().getBestSize();
      //return new Size(bestWidth,bestHeight);
   }

   public function setRect(x:Float,y:Float,w:Float,h:Float):Void
   {
      // todo:set best size...
      layout(w,true);

      /*
      if (dock!=null)
      {
         var slot = dock.getSlot();
         bestSize[slot] = getLayout().getBestSize();
      }
      if (displayObject!=null)
      {
         displayObject.x = x;
         displayObject.y = y;
         displayObject.scrollRect = new Rectangle(scrollX,scrollY,w,h);
      }
      */
   }
}


