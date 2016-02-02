package gm2d.skin;

import nme.filters.BitmapFilter;
import nme.filters.GlowFilter;
import nme.display.BitmapData;
import nme.display.Shape;
import nme.display.Graphics;
import nme.geom.Matrix;
import gm2d.ui.Widget;


class DefaultBitmaps
{

   public static function factory(inButton:String, inState:Int) : BitmapData
   {
      var down = (inState & Widget.DOWN) > 0;


      var sizeX = Skin.scale(16);
      var sizeY = Skin.scale(16);
      var effects = true;

      if (inButton==Skin.Checkbox)
      {
         sizeY = Skin.scale(24);
         sizeX = Skin.scale(48);
      }

      var bmp = new BitmapData(sizeX,sizeY,true, gm2d.RGB.CLEAR );
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

      var s1 = Skin.scale(1);
      var s2 = Skin.scale(2);
      var s3 = Skin.scale(3);
      var s4 = Skin.scale(4);
      var s5 = Skin.scale(5);
      var s6 = Skin.scale(6);
      var s7 = Skin.scale(7);
      var s8 = Skin.scale(8);
      var s9 = Skin.scale(9);
      var s10 = Skin.scale(10);
      var s11 = Skin.scale(11);
      var s12 = Skin.scale(12);
      var s14 = Skin.scale(14);
      var s15 = Skin.scale(15);
      var s16 = Skin.scale(16);
      var s17 = Skin.scale(17);
      var s32 = Skin.scale(32);
      var s40 = Skin.scale(40);

      if (inButton==Skin.Close)
      {
         gfx.moveTo(s3,s3);
         gfx.lineTo(s12,s12);
         gfx.moveTo(s12,s3);
         gfx.lineTo(s3,s12);
      }
      if (inButton==Skin.Minimize)
      {
         gfx.moveTo(s3,s12);
         gfx.lineTo(s12,s12);
      }
      else if (inButton==Skin.Maximize)
      {
         gfx.drawRect(s3,s3,s11,s11);
      }
      else if (inButton==Skin.Restore)
      {
         gfx.drawRect(s3,s3,s6,s6);
         gfx.drawRect(s8,s8,s6,s6);
      }
      else if (inButton==Skin.Expand)
      {
         gfx.drawRect(s4,s2,s8,s12);
      }
      else if (inButton==Skin.Popup)
      {
         gfx.beginFill(0xffffff);
         gfx.moveTo(s5,s7);
         gfx.lineTo(s11,s7);
         gfx.lineTo(s8,s10);
         gfx.lineTo(s5,s7);
      }

      else if (inButton==Skin.Pin)
      {
         gfx.moveTo(s1,s7);
         gfx.lineTo(s5,s7);
         gfx.drawRect(s5,s3,s2,s9);
         gfx.drawRect(s7,s5,s6,s5);
      }

      else if (inButton==Skin.Add)
      {
         gfx.lineStyle(1,0x000000);
         gfx.beginFill(0x00ff00);
         gfx.moveTo(s3,s5);
         gfx.lineTo(s5,s5);
         gfx.lineTo(s5,s3);
         gfx.lineTo(s9,s3);
         gfx.lineTo(s9,s5);
         gfx.lineTo(s11,s5);
         gfx.lineTo(s11,s9);
         gfx.lineTo(s9,s9);
         gfx.lineTo(s9,s11);
         gfx.lineTo(s5,s11);
         gfx.lineTo(s5,s9);
         gfx.lineTo(s3,s9);
         gfx.lineTo(s3,s5);
      }
      else if (inButton==Skin.Remove)
      {
         gfx.lineStyle(1,0x000000);
         gfx.beginFill(0xff0000);
         gfx.moveTo(s3,s5);
         gfx.lineTo(s11,s5);
         gfx.lineTo(s11,s9);
         gfx.lineTo(s3,s9);
         gfx.lineTo(3,s5);
      }
      else if (inButton==Skin.Resize)
      {
         var w = Skin.scale(16);
         var h = Skin.scale(16);
         gfx.lineStyle(1,Skin.guiDark);
         for(o in 0...4)
         {
            var dx = (o+2)*3;
            gfx.moveTo(w-dx,h);
            gfx.lineTo(w,h-dx);
         }
      }
      else if (inButton==Skin.Checkbox)
      {
         effects = false;
         gfx.lineStyle(1,0x000000);
         gfx.beginFill(Skin.guiDark);
         gfx.drawRoundRect(0,0,sizeX-1,sizeY-1,s12,s12);
         gfx.beginFill(Skin.guiLight);
         gfx.drawCircle(down ? Skin.scale(36) : s11 + 0.5, s11 + 0.5, s10 );
         gfx.endFill();
         gfx.lineStyle(2,Skin.guiLight);
         if (down)
         {
            gfx.moveTo(s6,s12);
            gfx.lineTo(s11,s17);
            gfx.lineTo(s17,s6);
         }
         else
         {
            gfx.moveTo(s32,s8);
            gfx.lineTo(s40,s16);
            gfx.moveTo(s32,s16);
            gfx.lineTo(s40,s8);
         }
      }
      else if (inButton==Skin.Grip)
      {
         effects = false;
         gfx.beginFill(Skin.guiLight);
         gfx.drawRect(s2,s2, s14-s2, s4-s2);
         gfx.drawRect(s2,s7, s14-s2, s9-s7);
         gfx.drawRect(s2,s12, s14-s2, s14-s12);
      }


      if (down && effects)
         matrix.tx = matrix.ty = 1.5;
      else
         matrix.tx = matrix.ty = 0.5;

      if ((inState&Widget.CURRENT)>0)
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


