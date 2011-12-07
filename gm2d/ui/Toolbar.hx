package gm2d.ui;
import gm2d.display.Sprite;
import gm2d.display.BitmapData;
import gm2d.display.DisplayObject;

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
      super(root, inTitle, Pane.RESIZABLE  | Pane.TOOLBAR );
   }

   public function add(inTool:DisplayObject,?inWidth:Int, ?inHeight:Int)
   {
      root.addChild(inTool);
      var w = inWidth!=null ? inWidth : inTool.width;
      var h = inHeight!=null ? inHeight : inTool.height;
      items.push(new ToolbarItem(inTool,w,h));
   }

   override public function layout(inW:Float, inH:Float)
   {
      var max = inW-padX;
      var x = padX;
      var y = padY;
      var row_height = 0.0;
      for(item in items)
      {
         if (row_height>0 && x+item.w>max)
         {
            y+=row_height + padY*2;
            x = padX;
            row_height = 0;
         }
         // TODO: center-y?
         item.win.x=x;
         item.win.y=y;
         if (item.h>row_height)
            row_height = item.h;
         x+=item.w+padX*2;
      }
   }

}


