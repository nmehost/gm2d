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
   static var cache = new Map<String, BitmapData>();

   public static function createBitmap(skin:Skin, inButton:String, inState:Int, lineCol:Int, fillCol:Int ) : BitmapData
   {
      var down = (inState & Widget.DOWN) > 0;
      var sizeX = skin.scale(16);
      var sizeY = skin.scale(16);
      var effects = true;

      if (inButton==Skin.Checkbox)
      {
         sizeY = skin.scale(24);
         sizeX = skin.scale(48);
      }

      if (inButton==Skin.ComboPopup)
      {
         sizeY = skin.scale(22);
         sizeX = skin.scale(22);
      }


      var invert = true;

      var bmp = new BitmapData(sizeX,sizeY,true, 0x00000000 );
      //var bmp = new BitmapData(sizeX,sizeY,true, 0xffff00ff );
      var shape = new nme.display.Shape();
      shape.pixelSnapping = nme.display.PixelSnapping.NEVER;
      var gfx = shape.graphics;

      gfx.lineStyle( skin.scale(1),lineCol );
      switch(inButton)
      {
         case Skin.Maximize, Skin.Popup, Skin.Restore:
            gfx.beginFill(fillCol);
         default:
      }
      var matrix = new Matrix();

      var s1 = skin.scale(1);
      var s2 = skin.scale(2);
      var s3 = skin.scale(3);
      var s4 = skin.scale(4);
      var s5 = skin.scale(5);
      var s6 = skin.scale(6);
      var s7 = skin.scale(7);
      var s8 = skin.scale(8);
      var s9 = skin.scale(9);
      var s10 = skin.scale(10);
      var s11 = skin.scale(11);
      var s12 = skin.scale(12);
      var s14 = skin.scale(14);
      var s15 = skin.scale(15);
      var s16 = skin.scale(16);
      var s17 = skin.scale(17);
      var s32 = skin.scale(32);
      var s40 = skin.scale(40);

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
         var w = skin.scale(16);
         var h = skin.scale(16);
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
         gfx.lineStyle(1,skin.guiTrim);
         gfx.beginFill(skin.guiMedium);
         var r = (sizeY-1)*0.5;
         gfx.drawRoundRect(0,0,sizeX-1,sizeY-1,r*2,r*2);
         gfx.lineStyle(1,skin.guiTrim);
         gfx.beginFill(skin.guiLight);
         gfx.drawCircle(down ? sizeX-1-r : r, r,  r );
         gfx.endFill();
         for(pass in 0...2)
         {
            var o = pass==0 ? -0.5 : 0;
            if (pass==0)
               gfx.lineStyle(3,skin.guiDark, 0.2);
            else
               gfx.lineStyle(2,skin.guiLight);
            if (down)
            {
               gfx.moveTo(s6+o,s12+o);
               gfx.lineTo(s11+o,s17+o);
               gfx.lineTo(s17+o,s6+o);
            }
            else
            {
               gfx.moveTo(s32+o,s8+o);
               gfx.lineTo(s40+o,s16+o);
               gfx.moveTo(s32+o,s16+o);
               gfx.lineTo(s40+o,s8+o);
            }
         }
      }
      else if (inButton==Skin.Grip)
      {
         effects = false;
         gfx.beginFill(skin.guiLight);
         gfx.drawRect(s2,s2, s14-s2, s4-s2);
         gfx.drawRect(s2,s7, s14-s2, s9-s7);
         gfx.drawRect(s2,s12, s14-s2, s14-s12);
      }
      else if (inButton==Skin.ComboPopup)
      {
          effects = false;
          gfx.lineStyle();
          gfx.beginFill(skin.guiTrim);
          gfx.moveTo(s8,s8);
          gfx.lineTo(s16,s8);
          gfx.lineTo(s12,s14);
          gfx.lineTo(s8,s8);
       }


      if (down && effects)
         matrix.tx = matrix.ty = 1.5;
      else
         matrix.tx = matrix.ty = 0.5;

      if ((inState&Widget.CURRENT)>0 && false)
      {
         // todo: why does this not work in flash
         // - flash ignores transforms in top-level object in draw - need to nest?
         var glow:BitmapFilter = new GlowFilter(0x0000ff, 1.0, 3, 3, 2, 2, false, false);
         shape.filters = [ glow ];
      }

      bmp.draw(shape,matrix,null);

      return bmp;
   }


}


