package gm2d.skin;

import nme.filters.BitmapFilter;
import nme.filters.GlowFilter;
import nme.display.BitmapData;
import nme.display.Shape;
import nme.display.Graphics;
import nme.geom.Matrix;
import gm2d.ui.HitBoxes;


class DefaultBitmaps
{

   public static function factory(inButton:String, inState:Int) : BitmapData
   {
      var bmp = new BitmapData(16,16,true, gm2d.RGB.CLEAR );
      var shape = new nme.display.Shape();
      var gfx = shape.graphics;

      if (false)
      {
         var cols = [ 0xff0000, 0x00ff00, 0x0000ff ];
         gfx.beginFill(cols[inState]);
         gfx.drawRect(0,0,16,16);
         gfx.endFill();
      }


      gfx.lineStyle(1,0xffffff);
      var matrix = new Matrix();

      if (inButton==Skin.Close)
      {
         gfx.moveTo(3,3);
         gfx.lineTo(12,12);
         gfx.moveTo(12,3);
         gfx.lineTo(3,12);
      }
      if (inButton==Skin.Minimize)
      {
         gfx.moveTo(3,12);
         gfx.lineTo(12,12);
      }
      else if (inButton==Skin.Maximize)
      {
         gfx.drawRect(3,3,11,11);
      }
      else if (inButton==Skin.Restore)
      {
         gfx.drawRect(3,3,6,6);
         gfx.drawRect(8,8,6,6);
      }
      else if (inButton==Skin.Expand)
      {
         gfx.drawRect(4,2,8,12);
      }
      else if (inButton==Skin.Popup)
      {
         gfx.beginFill(0xffffff);
         gfx.moveTo(5,7);
         gfx.lineTo(11,7);
         gfx.lineTo(8,10);
         gfx.lineTo(5,7);
      }

      else if (inButton==Skin.Pin)
      {
         gfx.moveTo(1,7);
         gfx.lineTo(5,7);
         gfx.drawRect(5,3,2,9);
         gfx.drawRect(7,5,6,5);
      }

      else if (inButton==Skin.Add)
      {
         gfx.lineStyle(1,0x000000);
         gfx.beginFill(0x00ff00);
         gfx.moveTo(3,5);
         gfx.lineTo(5,5);
         gfx.lineTo(5,3);
         gfx.lineTo(9,3);
         gfx.lineTo(9,5);
         gfx.lineTo(11,5);
         gfx.lineTo(11,9);
         gfx.lineTo(9,9);
         gfx.lineTo(9,11);
         gfx.lineTo(5,11);
         gfx.lineTo(5,9);
         gfx.lineTo(3,9);
         gfx.lineTo(3,5);
      }
      else if (inButton==Skin.Remove)
      {
         gfx.lineStyle(1,0x000000);
         gfx.beginFill(0xff0000);
         gfx.moveTo(3,5);
         gfx.lineTo(11,5);
         gfx.lineTo(11,9);
         gfx.lineTo(3,9);
         gfx.lineTo(3,5);
      }
      else if (inButton==Skin.Resize)
      {
         var w = 16;
         var h = 16;
         gfx.lineStyle(1,Skin.guiDark);
         for(o in 0...4)
         {
            var dx = (o+2)*3;
            gfx.moveTo(w-dx,h);
            gfx.lineTo(w,h-dx);
         }
      }


      if (inState==HitBoxes.BUT_STATE_DOWN)
         matrix.tx = matrix.ty = 1.5;
      else
         matrix.tx = matrix.ty = 0.5;

      if (inState!=HitBoxes.BUT_STATE_UP)
      {
         // todo: why does this not work in flash
         // - flash ignores transforms in top-level object in draw - need to nest?
         var glow:BitmapFilter = new GlowFilter(0x0000ff, 1.0, 3, 3, 2, 2, false, false);
         shape.filters = [ glow ];
      }
        
      bmp.draw(shape,matrix);
      return bmp;
   }


}


