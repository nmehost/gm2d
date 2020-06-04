package gm2d.ui;

import nme.display.Sprite;

class TileControl extends ScrollWidget
{
   var columns:Int;
   var inner:Sprite;
   var controlWidth:Float;
   var controlHeight:Float;
   var holdUpdateCount:Int;
   var items:Array<Widget>;

   public var count(get,null):Int;

   public function new(?inLineage:Array<String>,?inAttribs:{})
   {
      super(Widget.addLine(inLineage,"TileControl"), inAttribs);
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
      //build();
   }


   function get_count() return items.length;

   public function isDown(idx:Int)
   {
      return idx>=0 && items[idx]!=null && items[idx].down;
   }

   public function getDownWidgets()
   {
      var result = new Array<Widget>();
      for(i in items)
         if (i.down)
            result.push(i);
      return result;
   }

   public function setDownInclusive(t0:Int, t1:Int, inDown=true)
   {
     if (t1<t0)
     {
        var t = t0;
        t0 = t1;
        t1 = t;
     }
     if (t0>=0 && t1<items.length)
        for(t in t0...t1+1)
           items[t].down = inDown;
   }


   public function layoutControl(inX:Float, inY:Float, inW:Float, inH:Float)
   {
      var columnWidth = attribFloat("columnWidth",0);
      if (columnWidth>0)
      {
         columns = Std.int( controlWidth/gm2d.skin.Skin.scale(columnWidth) );
         if (columns<1)
            columns = 1;
      }
      else
      {
         columns = attribInt("columns",0);
      }

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
         var colSize = Std.int(controlWidth/columns);

         var rows = Std.int( (items.length+columns-1)/columns );
         var y = 0.0;
         for(r in 0...rows)
         {
            var rowHeight = 0.0;
            for(col in 0...columns)
            {
               var idx = r*columns + col;
               var item = items[idx];
               if (item!=null)
                  rowHeight = Math.max(rowHeight,item.getLayout().getBestHeight(colSize));
            }

            for(col in 0...columns)
            {
               var idx = r*columns + col;
               var item = items[idx];
               if (item!=null)
               {
                  item.align( col*colSize, y, colSize, rowHeight );
               }
            }
            y+=rowHeight;
         }
         setScrollRange(controlWidth, controlWidth, y,controlHeight);
      }
   }

}


