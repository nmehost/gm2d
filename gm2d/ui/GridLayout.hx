package gm2d.ui;

import nme.display.DisplayObject;
import nme.geom.Point;

class GridLayout extends Layout
{
   var mCols:Null<Int>;
   var mColInfo : Array<ColInfo>;
   var mRowInfo : Array<RowInfo>;
   var mSpaceX:Float;
   var mSpaceY:Float;
   var mPos:Int;
   public var mDbgObj:DisplayObject;

   public function new(?inCols:Null<Int>,?inName:String)
   {
      super();
      mSpaceX = 0;
      mSpaceY = 0;
      mCols = inCols;
      if (inName!=null)
          name = inName;
      clear();
   }

   override public function clear( )
   {
      mColInfo = [];
      mRowInfo = [];
      if (mCols!=null)
      {
         for(i in 0...mCols)
            mColInfo[i] = new ColInfo(0);
      }
      else
      {
         mRowInfo[0] = new RowInfo(0);
      }
      mPos = 0;
   }

   public function setDebugOwner(inObj:DisplayObject) : GridLayout
   {
      mDbgObj = inObj;
      return this;
   }


   /*
   public static function createKeepAspect(inMinWidth:Float, inMinHeight:Float, inBase:Layout)
   {
      var result = new GridLayout(1,"KeepAspect");
      result.minWidth = inMinWidth;
      result.minHeight = inMinHeight;
      result.add(inBase);
      inBase.mAlign |= Layout.AlignKeepAspect;
      return result;
   }
   */

   public override function add(inLayout:Layout) : Layout
   {
      var row = 0;
      if (mCols!=null && mCols>0)
      {
         row = Std.int(mPos / mCols);
         if (row>=mRowInfo.length)
            mRowInfo.push(new RowInfo(0));
      }
      else
      {
         while(mColInfo.length<=mPos)
            mColInfo.push(new ColInfo(0));
      }
      if (mRowInfo[row]==null)
         mRowInfo[row]=new RowInfo(0);
      var col = mRowInfo[row].mCols.length;

      mRowInfo[row].mCols.push(inLayout);
      mPos++;
      return this;
   }

   public override function insert(inPos:Int, inLayout:Layout) : Layout
   {
      if (inPos>=mPos)
         return add(inLayout);

      if (mCols==1)
      {
         var stretch = inLayout==null ? 0 :
             (inLayout.mAlign & Layout.AlignMaskY)==Layout.AlignStretch ? 1: 0;
         mRowInfo.insert(inPos,new RowInfo(stretch));
         mRowInfo[inPos].mCols.push(inLayout);
      }
      else if (mCols==null)
      {
         var stretch = inLayout==null ? 0 :
             (inLayout.mAlign & Layout.AlignMaskX)==Layout.AlignStretch ? 1: 0;
         mRowInfo[inPos].mCols.insert(inPos,inLayout);
      }
      else // TODO:
         throw("Can only insert in 1xN or Nx1");

      return this;
   }


   public override function setSpacing(inX:Float,inY:Float) : Layout
   {
      mSpaceX = inX; mSpaceY = inY;
      return this;
   }


   public function rowStretch(inValues:Array<Float>)
   {
      for(i in 0...inValues.length)
         setRowStretch(i,inValues[i]);
      return this;
   }


   public function setRowStretch(inRow:Int,inStretch:Float,inShrinkOnly=false)
   {
      if (mRowInfo[inRow]==null)
         mRowInfo[inRow] = new RowInfo(inStretch);
      mRowInfo[inRow].mStretch = inStretch;
      mRowInfo[inRow].mShrinkOnly = inShrinkOnly;
      return this;
   }

   public function colStretch(inValues:Array<Float>)
   {
      for(i in 0...inValues.length)
         setColStretch(i,inValues[i]);
      return this;
   }

   public function setColStretch(inCol:Int,inStretch:Float)
   {
      if (mColInfo[inCol]==null)
         mColInfo[inCol] = new ColInfo(inStretch);
      mColInfo[inCol].mStretch = inStretch;
      return this;
   }

   public function setMinColWidth(inCol:Int,inMin:Float)
   {
      if (mColInfo[inCol]==null)
         mColInfo[inCol] = new ColInfo(0);
      mColInfo[inCol].mMinSpecWidth = inMin;
      return this;
   }


   public static var indent = "";

   // Updates col.mBestWidth, col.mMinWidth, row.mMinHeight
   function calcWidthsMinAndBest()
   {
       var key = "cw:" + layoutId;
       if (isCached(key))
          return;
      //trace(indent + "calcWidthsMinAndBest..." + mColInfo.length);
      //var oindent = indent;
      //indent += "  ";
      var cid = 0;
      for(col in mColInfo)
      {
         col.mBestWidth = col.mMinWidth = col.mMinSpecWidth;
         if (debug)
            trace(' $key col ' + (cid++) + " " + col.mMinWidth );
      }
      var thickest = 0.0;
      for(row in mRowInfo)
      {
         row.mMinHeight = 0;
         //trace(indent + " cols : "  + row.mCols.length);
         for(i in 0...row.mCols.length)
         {
            var col =  row.mCols[i];
            if (col!=null)
            {
               var w = col.getBestWidth();
               if (w>mColInfo[i].mBestWidth)
               {
                  mColInfo[i].mBestWidth = w;
                  if (w>thickest)
                     thickest = w;
                  //trace(indent + " -> [" + i + "] = " + w);
               }
               var s = col.getMinSize(w);
               if (s.x>mColInfo[i].mMinWidth)
               {
                  mColInfo[i].mMinWidth = s.x;
                  if (debug)
                     trace(' $i] -> ${s.x}');
               }
               if (s.y>row.mMinHeight)
                  row.mMinHeight = s.y;
            }
         }
      }
      if ( (mAlign & Layout.AlignEqual)!=0 )
         for(c in mColInfo)
            c.mBestWidth = thickest;
      setCache(key,true,false);
      //indent = oindent;
   }

   /*
   function calcRowMinBest()
   {
       var key = "minBest:" + layoutId + ":" + inWidth;
       if (Layout.cache.exists(key) )
          return;

      var tallest = 0.0;
      for(r in 0...mRowInfo.length)
      {
         var row = mRowInfo[r];
         row.mHeight = 0;
         var minHeight = 0.0;
         for(i in 0...row.mCols.length)
         {
            var col =  row.mCols[i];
            if (col!=null)
            {
               var h = col.getBestHeight();
               if (h>row.mHeight)
                  row.mHeight = h;
               if (h>tallest)
                  tallest = h;
               var minH = col.getMinSize().y;
               if (minH>minHeight)
                  minHeight = minH;
            }
         }

         row.mMinHeight = minHeight;
         //if (debug)
         //   Sys.println('   $name $r] h=$minHeight');
         if (row.mHeight>minHeight)
            row.mShrink = row.mHeight-minHeight;
         else
            row.mShrink = 0.0;
      }
      if ( (mAlign & Layout.AlignEqual)!=0 )
         for(r in mRowInfo)
            r.mHeight = tallest;
      Layout.cache.set(key,true);
   }
   */

   function distribute(width:Float, dmin:Array<Float>, dbest:Array<Float>, dstretch:Array<Float> )
   {
      var min = 0.0;
      var best = 0.0;
      var totalStretch = 0.0;
      var n = dmin.length;
      for(c in 0...n)
      {
         min += dmin[c];
         best += dbest[c];
         totalStretch += dstretch[c];
      }
      if (width>=best)
      {
         var size = [ ];
         var extra = width-best;
         for(c in 0...n)
         {
            var w = dbest[c];
            if (dstretch[c]>0)
            {
               var e = Std.int(extra * dstretch[c]/totalStretch + 0.5);
               w += e;
               extra -= e;
               totalStretch -= dstretch[c];
            }
            size.push(w);
         }
         return size;
      }

      var size = dbest;
      var missing = best-width;
      for(pass in 0...10)
      {
         for(cid in 0...n)
         {
            if (dstretch[cid]>0 && size[cid]>dmin[cid])
            {
               var e = missing * dstretch[cid]/totalStretch;
               if (size[cid]-e < dmin[cid])
                  e = size[cid] - dmin[cid];
               size[cid] -= e;
               missing -= e;
               totalStretch -= dstretch[cid];
            }
         }
         if (missing<0.5)
           break;

         totalStretch = 0.0;
         for(cid in 0...n)
         {
            if ( size[cid]>dmin[cid] && dstretch[cid] > 0 )
                 totalStretch += dstretch[cid];
         }
      }
      return size;
   }

   function distributeWidth(width:Float)
   {
      var min = [for(c in mColInfo) c.mMinWidth ];
      var best = [for(c in mColInfo) c.mBestWidth ];
      var stretch = [for(c in mColInfo) c.mStretch ];

      width -= borderLeft + borderRight;
      if (min.length>1)
         width -= (min.length-1) * mSpaceX;

      return distribute(width, min, best, stretch);
   }


   override public function getColWidths() : Array<Float>
   {
      return calcColWidths(null);
   }

   // GridLayout
   function calcColWidths(inWidth:Null<Float>) : Array<Float>
   {
      var key = "ccw:" + layoutId + ":" + inWidth;
      if (isCached(key))
         return getCached(key);

      var destroyCache = beginCache();
      try
      {
         calcWidthsMinAndBest();
         var result:Array<Float> = null;
         if (inWidth==null)
         {
            result = [for(c in mColInfo) c.mBestWidth ];
         }
         else
            result = distributeWidth(inWidth);

         return setCache(key,result,destroyCache);
      }
      catch (e:Dynamic)
      {
         endCache(destroyCache);
         throw e;
      }
   }

/*
            [for(c in mColInfo) c.mBestWidth ] :
            distributeWidth(inWidth);

     calcRowHeights(width);

     var height = 0.0;
     for(row in mRowInfo)
        height+=row.mHeight;
     //if (debug)
     //   Sys.println("  row heights: " + [ for(row in mRowInfo) row.mHeight ] );
     height += borderTop + borderBottom;
     if (mRowInfo.length>0)
        height += (mRowInfo.length -1)*mSpaceY;

     //if (debug)
     //   Sys.println(' Layout H $name: $height / $inHeight $mAlign');

     if (inHeight!=null)
     {
        var extra = inHeight-height;
        if (extra!=0)
        {
           var stretch = 0.0;
           var stretches = new Array<Float>();
           for(row in mRowInfo)
           {
              if (extra<0 || !row.mShrinkOnly)
              {
                 stretches.push(row.mStretch);
                 stretch += row.mStretch;
              }
              else
                 stretches.push(0.0);
           }

           var remaining = extra;
           while(stretch>0 && Math.abs(extra)>=1 )
           {
              var clamped = false;
              for(rid in 0...mRowInfo.length)
              {
                 if (stretches[rid]!=0)
                 {
                    var row = mRowInfo[rid];
                    var delta = Std.int(stretches[rid] * extra / stretch + 0.5);
                    if (row.mHeight+delta < row.mMinHeight)
                    {
                       delta = Std.int(row.mMinHeight-row.mHeight);
                       row.mHeight = row.mMinHeight;
                       stretches[rid] = 0.0;
                       clamped = true;
                    }
                    else
                    {
                       row.mHeight += delta;
                    }
                    remaining -= delta;
                 }
              }

              if (!clamped)
                 break;
              stretch = 0;
              for(s in stretches)
                 stretch+=s;
              extra = remaining;
           }

           if (remaining<0)
           {
              remaining = -remaining;
              var total = 0.0;
              for(row in mRowInfo)
                 total += row.mShrink;

              if (total>0)
              {
                 for(row in mRowInfo)
                 {
                    var delta = row.mShrink * remaining/total;
                    row.mHeight = Std.int(row.mHeight - delta + 0.5);
                 }
              }
           }
        }

        height = inHeight;
     }
     Layout.endCache(destroyCache);
   }
*/

   override public function findTextLayout() : TextLayout
   {
      for(row in mRowInfo)
      {
         if (row==null)
             continue;
         var result = Layout.findTextLayoutInList(row.mCols);
         if (result!=null)
            return result;
      }
      return null;
   }
   override public function visitChildren(onChild:Layout->Dynamic,inRecurse=true) : Dynamic
   {
      for(row in mRowInfo)
      {
         if (row==null)
             continue;
         var result = Layout.visitChildList(row.mCols,onChild,inRecurse);
         if (result!=null)
            return result;
      }
      return null;
   }


   // Grid
   public override function getBestWidth() : Float
   {
      if (bestWidth!=null)
         return clampBestWidth(bestWidth);

      var key = 'gbw:$layoutId';
      if (isCached(key))
         return getCached(key);

      var destroyCache = beginCache();
      try
      {
         calcWidthsMinAndBest();
         if (debug)
         {
            trace('$this best col width:' + [for(c in mColInfo) c.mBestWidth]);
            trace('$this min col width:' + [for(c in mColInfo) c.mMinWidth]);
         }
         var w = borderLeft + borderRight;
         if (mColInfo.length>0)
            w+=(mColInfo.length-1)*mSpaceX;
         for(col in mColInfo)
            w+= col.mBestWidth;

         return setCache(key,clampBestWidth(w),destroyCache);
      }
      catch (e:Dynamic)
      {
         endCache(destroyCache);
         throw e;
      }
   }

   function calcBestHeights(widths:Array<Float>) : Array<Float>
   {
      var key = 'cbh:$layoutId:$widths';
      if (isCached(key))
         return getCached(key);

      var result = new Array<Float>();
      for(r in mRowInfo)
      {
         var h = 0.0;
         for(cid in 0...r.mCols.length)
         {
            var c = r.mCols[cid];
            if (c!=null)
            {
               var ch = c.getBestHeight(widths[cid]);
               if (ch>h)
                  h = ch;
            }
         }
         result.push(h);
      }

      return setCache(key, result, false);
   }


   // Grid
   public override function getBestHeight(?inWidth:Null<Float>) : Float
   {
      if (bestHeight!=null)
         return clampBestHeight(bestHeight, inWidth);

      var key = "gbh:" + layoutId + ":" + inWidth;
      if (isCached(key))
         return getCached(key);

      var remove = beginCache();
      try
      {
         var colWidths = calcColWidths(inWidth);
         var rowHeights = calcBestHeights(colWidths);

         var h = borderTop + borderBottom;
         if (rowHeights.length>0)
            h+= (rowHeights.length-1)*mSpaceY;
         for(r in rowHeights)
            h+=r;

         return setCache(key, clampBestHeight(h, inWidth), remove);
      }
      catch (e:Dynamic)
      {
         endCache(remove);
         throw e;
      }
   }

   // GridLayout
   public override function getMinSize(?inWidth:Null<Float>) : Size
   {
      var key = 'gms:$layoutId';
      if (isCached(key))
         return getCached(key);

      var remove = beginCache();
      try
      {
         calcWidthsMinAndBest();


         var sx = (mColInfo.length-1)*mSpaceX + borderLeft + borderRight;
         for(c in mColInfo)
            sx+= c.mMinWidth;
         if (sx<minWidth)
            sx = minWidth;

         var sy = (mRowInfo.length-1)*mSpaceY + borderTop + borderBottom;
         for(r in mRowInfo)
            sy+= r.mMinHeight;
         if (sy<minHeight)
            sy = minHeight;

         var result = bestDefault(new Size( sx, sy ));

         if (debug) trace('dbg: $this  getMinSize ->' + result);

         return setCache(key,result,remove);
      }
      catch (e:Dynamic)
      {
         endCache(remove);
         throw e;
      }
   }


   public override function setRect(inX:Float,inY:Float,inW:Float,inH:Float) : Void
   {
      if (debug)
         trace('GridLayout $name setRect($inX,$inY,$inW,$inH) min=${getMinSize()}');
      var destroyCache = beginCache();
      try
      {
         var oindent = indent;
         indent += "   ";

         var widths = calcColWidths(inW);
         var bestHeights = calcBestHeights(widths);
         var minHeights = [for(r in mRowInfo) r.mMinHeight];
         var stretches = [for(r in mRowInfo) r.mStretch ];

         var h = inH - borderTop - borderBottom;
         if (mRowInfo.length>1)
            h -= (mRowInfo.length-1)*mSpaceY;
         var heights = distribute(h, minHeights, bestHeights, stretches );

         // distributeWidth
         // distributeHeight

         //for(col in mColInfo)
           //trace("Got col " + col.mBestWidth );
         indent = oindent;
         var y = inY + borderTop;
         for(rid in 0...mRowInfo.length)
         {
            var row = mRowInfo[rid];
            var row_h = heights[rid];
            var x = inX + borderLeft;
            for(c in 0...row.mCols.length)
            {
               var col_w = widths[c];

               var item = row.mCols[c];

               if (item!=null)
               {
                  if (debug)
                     trace('  alignChild($rid,$c,$item:  $x,$y,$col_w,$row_h)');
                  alignChild(item, x, y, col_w, row_h );
               }

               x+=col_w + mSpaceX;
            }
            y+= row_h + mSpaceY;
         }

         indent = oindent;

         if (Layout.mDebug!=null)
         {
            var p = new Point(inX,inY);
            if (mDbgObj!=null)
               p = Layout.mDebugObject.globalToLocal( mDbgObj.localToGlobal(p) );
            Layout.mDebug.lineStyle(1,0x0000ff);
            Layout.mDebug.drawRect(p.x,p.y,inW,inH);
         }

         super.setRect(inX, inY, inW, inH);
         endCache(destroyCache);
      }
      catch (e:Dynamic)
      {
         endCache(destroyCache);
         throw e;
      }
   }
   override public function toString() return 'GridLayout($name)';
}
