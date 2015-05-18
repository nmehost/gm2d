package gm2d.ui;

import nme.display.Sprite;

class TileControl extends ScrollWidget
{
   public var onSelect:Int->Void;

   var columns:Int;
   var inner:Sprite;
   var controlWidth:Float;
   var controlHeight:Float;
   var holdUpdateCount:Int;
   var items:Array<Widget>;

   public function new(?inOnSelect:Int->Void,?inLineage:Array<String>,?inAttribs:{})
   {
      super(inLineage, inAttribs);
      onSelect = inOnSelect;
      columns = attribInt("columns",0);


      holdUpdateCount = 0;
      var width = attribFloat("width",0);
      var height = attribFloat("height",0);

      inner = new Sprite();
      addChild(inner);
      scrollTarget = inner;
      controlWidth = controlHeight = 0.0;
      items = [];

      var internalLayout = new Layout().setMinSize(width,height).stretch();
      internalLayout.onLayout = layoutControl;
      setItemLayout(internalLayout);
      setScrollRange(width,width,height,height);
      build();
   }


   public function layoutControl(inX:Float, inY:Float, inW:Float, inH:Float)
   {
      inner.x = inX;
      inner.y = inY;
      controlWidth = inW;
      controlHeight = inH;
      recalcPos();
      redraw();
   }

   public function holdUpdates(inHold:Bool)
   {
      if (inHold)
         holdUpdateCount++;
      else
         holdUpdateCount--;
      if (holdUpdateCount==0)
      {
         recalcPos();
         redraw();
      }
   }

   public function clear()
   {
      while(inner.numChildren>0)
         inner.removeChildAt(0);
      items = [];
     
      if (holdUpdateCount==0)
      {
         recalcPos();
         redraw();
      }
   }

   public function add(widget:Widget)
   {
      inner.addChild(widget);
      items.push(widget);
      if (holdUpdateCount==0)
      {
         recalcPos();
         redraw();
      }
   }


   public function recalcPos()
   {
      if (columns==0)
      {
         var x = 0.0;
         var colStart = 0;
         var colWidth = 0.0;
         var colHeight = 0.0;
         var heights = new Array<Float>();

         var c = 0;
         while(c < items.length)
         {
            var item = items[c];
            var itemLayout = item.getLayout();
            var h = itemLayout.getBestHeight( );
            var nextHeight = colHeight + h;
            if (c>colStart && nextHeight>controlHeight)
            {
               var y = 0.0;
               // New column
               for(cid in colStart...c)
               {
                  items[cid].align(x,y,colWidth,heights[cid-colStart]);
                  y += heights[cid-colStart];
               }
               x+=colWidth;
               colStart = c;
               colWidth = 0;
               colHeight = 0;
               heights = new Array<Float>();
            }

            colHeight += h;
            colWidth = Math.max(colWidth, itemLayout.getBestWidth() );
            heights.push(h);
            c++;
         }

         var y = 0.0;
         // Last column
         for(cid in colStart...c)
         {
            items[cid].align(x,y,colWidth,heights[cid-colStart]);
            y += heights[cid-colStart];
         }
         x+= colWidth;

         setScrollRange(x, controlWidth, controlHeight,controlHeight);
      }
      else
      {
      }

   }

   


}


