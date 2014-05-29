package game;

import nme.display.Shape;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.DisplayObjectContainer;
import nme.native.ImageBuffer;
import nme.native.ARGB;
import cpp.Pointer;
import cpp.ConstPointer;
import cpp.UInt8;

class Paddle
{
   inline static var DEBUG = false;
   inline static var FIND_COLOUR_THRESH = 64.0;
   inline static var UPDATE_COLOUR_THRESH = 12.0;

   var display:Shape;
   var isLeft:Bool;
   var gameWidth:Int;
   var gameHeight:Int;
   // In video coordinates
   var minX:Int;
   var maxX:Int;

   public var x:Float;
   public var y:Float;

   var r:Float;
   var g:Float;
   var b:Float;


   public function new(parent:DisplayObjectContainer, gw:Int, gh:Int, inIsLeft:Bool)
   {
      gameWidth = gw;
      gameHeight = gw;
      isLeft = inIsLeft;
      minX = (isLeft!=Game.reflect) ? 0 : (gw>>1);
      maxX = (isLeft!=Game.reflect) ? (gw>>1) : gw;

      x = (minX+maxX)*0.5;
      y = gh*0.5;
      display = new Shape();
      var gfx = display.graphics;
      gfx.lineStyle(1,isLeft ? 0xff0000 : 0x0000ff);
      gfx.beginFill(0xffffff);
      gfx.drawCircle( 0, 0, Game.BAT_RAD );
      parent.addChild(display);
      r = g = b = 200;
      display.cacheAsBitmap = true;
      updateDisplay();
   }

   public function updateDisplay()
   {
      display.x = x;
      display.y = y;
   }


   public function processFrame(src:cpp.Pointer<ImageBuffer>, prev:cpp.Pointer<ImageBuffer>)
   {
      if (!refine(src,false))
      {
         var w = src.value.Width();
         var h = src.value.Height();

         var srcPtr = src.value.GetBase();
         var prevPtr = prev.value.GetBase();
         //var debugPtr = debug.value.Edit();
   
         var sx = 0.0;
         var sy = 0.0;
         var sdr = 0.0;
         for(y in 0...h)
         {
            var s:ConstPointer<ARGB> = srcPtr.add( src.value.GetStride()*y ).reinterpret();
            var p:ConstPointer<ARGB> = prevPtr.add( prev.value.GetStride()*y ).reinterpret();
            //var d:Pointer<Int> = debugPtr.add( debug.value.GetStride()*y ).reinterpret();
   
            for(x in minX...maxX)
            {
               var dr:Int = s.at(x).g - p.at(x).g;
               if (dr<0) dr = -dr;
               if (dr>20)
               {
                  dr*=p.at(x).g;
                  sx += x*dr;
                  sy += y*dr;
                  sdr+=dr;
               }
               //d.add(x).ref = dr>20 ? 0xff00ff00 : 0;
            }
         }
         //debug.value.Commit();
         
         if (sdr>0)
         {
            x = videoToGame(sx/sdr);
            y = sy/sdr;
            refine(src,true);
         }
      }

      updateDisplay();
   }

   function gameToVideo(inX:Float):Float
   {
      if (Game.reflect)
         return gameWidth-inX;
      return inX;
   }
   function videoToGame(inX:Float):Float { return gameToVideo(inX); }


   function clip(inVal:Float,inMin:Int, inMax:Int) : Int
   {
      if (inVal<inMin) return inMin;
      if (inVal>=inMax) return inMax;
      return Std.int(inVal);
   }


   function refine(src:cpp.Pointer<ImageBuffer>, reinit:Bool) : Bool
   {
      var w = src.value.Width();
      var h = src.value.Height();

      var srcPtr = src.value.GetBase();
      var stride = src.value.GetStride();
      var cx = gameToVideo(x);
      var cy = y;
      var bRad = h/20.0;
      var scale = 1.0/(bRad*bRad);
      var search = h/10.0;
     
      var gfx = Game.overlay.graphics;
      gfx.lineStyle(0,0x00ff00);
      
      for(pass in 0...10)
      {
         var x0 = clip(cx-bRad-search,minX,maxX);
         var x1 = clip(cx+bRad+search,minX,maxX);
         var y0 = clip(cy-bRad-search,0,h);
         var y1 = clip(cy+bRad+search,0,h);
       
         //trace('$x0,$y0,$x1,$y1)');
         if (DEBUG)
            gfx.drawRect(Game.reflect ? w-x1 : x0,y0,x1-x0,y1-y0);

         var same = true;
         if (!reinit)
         {
            // Update position...
            var sX = 0;
            var sY = 0;
            var sN = 0;
   
            for(y in y0...y1)
            {
               var s:ConstPointer<ARGB> = srcPtr.add( stride*y ).reinterpret();
               for(x in x0...x1)
               {
                  var argb = s.at(x);
                  var dr = r-argb.r;
                  var dg = g-argb.g;
                  var db = b-argb.b;
                  if (dr*dr + dg*dg + db*db < FIND_COLOUR_THRESH)
                  {
                     sX  += x;
                     sY  += y;
                     sN ++;
                  }
               }
            }
   
            if (sN==0)
            {
               trace('No position ($r,$g,$b  $x0,$y0,$x1,$y1)');
               return false;
            }
   
            var nx = sX/sN;
            var ny = sY/sN;

            if (DEBUG)
            {
               gfx.lineStyle(1,0xff0000);
               gfx.drawCircle(videoToGame(nx),ny,bRad);
            }

            same = Math.abs(nx-cx)<1 && Math.abs(ny-cy)<1;
            cx = nx;
            x = videoToGame(cx);
            y = cy = ny;
         }

         // Update colour...
         //if (reinit)
         {
            var x0 = clip(cx-bRad*2,minX,maxX);
            var x1 = clip(cx+bRad*2,minX,maxX);
            var y0 = clip(cy-bRad*2,0,h);
            var y1 = clip(cy+bRad*2,0,h);
   
            var sR = 0.0;
            var sG = 0.0;
            var sB = 0.0;
            var sW = 0.0;
   
            for(y in y0...y1)
            {
               var s:ConstPointer<ARGB> = srcPtr.add( stride*y ).reinterpret();
               var yw = Math.exp( -(y-cy)*(y-cy)*scale );
               for(x in x0...x1)
               {
                  var argb = s.at(x);
                  var dr = r-argb.r;
                  var dg = g-argb.g;
                  var db = b-argb.b;
                  if (reinit || dr*dr + dg*dg + db*db < UPDATE_COLOUR_THRESH)
                  {
                     var w = yw*Math.exp( -(x-cx)*(x-cx)*scale );
        
                     sR += w*argb.r;
                     sG += w*argb.g;
                     sB += w*argb.b;
                     sW += w;
                  }
               }
            }
   
            if (sW==0)
            {
               trace("No colour");
               return false;
            }
   
            var nr = sR/sW;
            var ng = sG/sW;
            var nb = sB/sW;
            same = same && (Math.abs(nr-r) + Math.abs(ng-g) + Math.abs(nb-b)) < 3;
            r = nr;
            g = ng;
            b = nb;
         }

         if (same) 
         {
            gfx.lineStyle();
            gfx.beginFill( (Std.int(r)<<16) | (Std.int(g)<<8) | Std.int(b) );
            gfx.drawCircle( x, y, bRad );
            return true;
         }

         reinit = false;
      }

      //trace("No converge");
      return false;
   }

}


