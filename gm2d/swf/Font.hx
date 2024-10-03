package gm2d.swf;

import gm2d.swf.SWFStream;
import nme.display.Graphics;
import nme.geom.Matrix;

#if !flash
import nme.text.NMEFont;
import nme.display.BitmapData;
#end

typedef FontCommand = Graphics -> Matrix -> Void;
typedef FontCommands = Array<FontCommand>;

typedef Glyph =
{
   var mCommands : FontCommands;
   var mAdvance  : Float;
}

typedef Glyphs = Array<Glyph>;

class Font
{
   var mGlyphs:Glyphs;
   var mCodeToGlyph:Glyphs;
   var mName:String;
   var mAscent:Float;
   var mDescent:Float;
   var mLeading:Float;
   var mAdvance:Array<Float>;


   public function new(inStream:SWFStream, inVersion:Int)
   {
      mGlyphs = [];

      inStream.AlignBits();
      var has_layout = (inVersion>1) && inStream.ReadBool();
      var has_jis = (inVersion>1) && inStream.ReadBool();
      var small_text = (inVersion>1) && inStream.ReadBool();
      var is_ansi = (inVersion>1) && inStream.ReadBool();
      var wide_offsets = (inVersion>1) && inStream.ReadBool();
      var wide_codes = (inVersion>1) && inStream.ReadBool();
      var italic = (inVersion>1) && inStream.ReadBool();
      var bold = (inVersion>1) && inStream.ReadBool();
      var lang_code = (inVersion>1) ? inStream.ReadByte() : 0;
      mName = (inVersion>1) ?  inStream.ReadPascalString() : "font";
      //trace("Font name : " + mName);
      
      var n:Int;
      var s0:Int;
      var offsets = new Array<Int>();
      var code_offset = 0;

      var v3scale = inVersion>2 ?  1.0 : 0.05;

      if (inVersion>1)
      {
         n = inStream.ReadUI16();
         s0 = inStream.BytesLeft();
         for(i in 0...n)
         {
            offsets.push( wide_offsets ? inStream.ReadInt() :
                                         inStream.ReadUI16() );
         }
         if (n>0)
         {
            code_offset = wide_offsets ? inStream.ReadInt() : inStream.ReadUI16();
            code_offset = s0-code_offset;
         }
      }
      else
      {
         s0 = inStream.BytesLeft();
         var o0 = inStream.ReadUI16();
         // Deduce N from first offset ...
         n = o0 >> 1;

         offsets.push(o0);
         for(i in 1...n)
            offsets.push( inStream.ReadUI16() );
      }

      var access_last = mGlyphs[n-1];

      inStream.AlignBits();
      // Now read glyphs ...
      for(i in 0...n)
      {
         if (inStream.BytesLeft() != (s0-offsets[i]))
            throw("bad offset in font stream (" +
                    inStream.BytesLeft() +"!="+ (s0-offsets[i]) + ")");

         var moved = false;
         var pen_x = 0.0;
         var pen_y = 0.0;
         var commands = new FontCommands();

         inStream.AlignBits();
         var fill_bits = inStream.Bits(4);
         var line_bits = inStream.Bits(4);


         while(true)
         {
            var edge = inStream.ReadBool();
            if (!edge)
            {
                var new_styles = inStream.ReadBool();
                var new_line_style = inStream.ReadBool();
                var new_fill_style1 = inStream.ReadBool();
                var new_fill_style0 = inStream.ReadBool();
                var move_to = inStream.ReadBool();

                if (new_styles || new_styles || new_fill_style1)
                   throw("fill style can't be changed here " +
                        new_styles +","+ new_styles +","+ new_fill_style0);

                // Done ?
                if (!move_to)
                   break;

                if (!new_fill_style0 && commands.length==0)
                   throw("fill style should be defined");

                var bits = inStream.Bits(5);
                pen_x = inStream.Twips(bits)*v3scale;
                pen_y = inStream.Twips(bits)*v3scale;
                var px = pen_x;
                var py = pen_y;

                //trace("Move : " + pen_x + "," + pen_y);
                commands.push( function(g:Graphics,m:Matrix)
                   { g.moveTo(px*m.a+py*m.c+m.tx, px*m.b+py*m.d+m.ty);} );

                if (new_fill_style0)
                {
                   var fill_style = inStream.Bits(1);
                }

            }
            else
            {
               // Straight
               if (inStream.ReadBool())
               {
                  var delta_bits = inStream.Bits(4) + 2;
                  if (inStream.ReadBool())
                  {
                     pen_x += inStream.Twips(delta_bits)*v3scale;
                     pen_y += inStream.Twips(delta_bits)*v3scale;
                  }
                  else if (inStream.ReadBool())
                     pen_y += inStream.Twips(delta_bits)*v3scale;
                  else
                     pen_x += inStream.Twips(delta_bits)*v3scale;
      
                  var px = pen_x;
                  var py = pen_y;
                  //trace("Line to : " + px + "," + py );
                  commands.push( function(g:Graphics,m:Matrix)
                     { g.lineTo(px*m.a+py*m.c+m.tx, px*m.b+py*m.d+m.ty);} );
               }
               // Curved ...
               else
               {
                  var delta_bits = inStream.Bits(4) + 2;
                  var cx = pen_x + inStream.Twips(delta_bits)*v3scale;
                  var cy = pen_y + inStream.Twips(delta_bits)*v3scale;
                  var px = cx + inStream.Twips(delta_bits)*v3scale;
                  var py = cy + inStream.Twips(delta_bits)*v3scale;
                  // Can't push "pen_x/y" in closure because it uses a reference
                  //  to the member variable, not a copy of the current value.
                  pen_x = px;
                  pen_y = py;
                  //trace("Curve to : " + px + "," + py );
                  commands.push( function(g:Graphics,m:Matrix)
                     { g.curveTo(cx*m.a+cy*m.c+m.tx, cx*m.b+cy*m.d+m.ty,
                         px*m.a+py*m.c+m.tx, px*m.b+py*m.d+m.ty);} );
               }
            }
         }

         commands.push(  function(g:Graphics,m:Matrix) { g.endFill(); } );

         mGlyphs[i] = { mCommands:commands, mAdvance:1024.0 };
      }



      // And codes ...
      if (code_offset!=0)
      {
         inStream.AlignBits();

         if (inStream.BytesLeft() != code_offset)
            throw("Code offset miscaculation, bytesLeft=" + inStream.BytesLeft() + " code_offset=" + code_offset);

         mCodeToGlyph = new Glyphs();

         for(i in 0...n)
         {
            var code = wide_codes ? inStream.ReadUI16() : inStream.ReadByte();
            //trace("Char " + Std.chr(code) + "=" + i);
            mCodeToGlyph[code] = mGlyphs[i];
         }

      }
      else
         mCodeToGlyph = mGlyphs;

      if (has_layout)
      {
         mAscent = inStream.ReadSTwips();
         mDescent = inStream.ReadSTwips();
         mLeading = inStream.ReadSTwips();

         mAdvance = new Array<Float>();
         for(i in 0...n)
            mGlyphs[i].mAdvance = inStream.ReadSTwips();
      }
      else
      {
         mAscent = 800;
         mDescent = 224;
         mLeading = 0;
      }

      //RenderGlyph( new gm2d.display.DebugGfx(), 1, new Matrix() );

      #if !flash
      nme.text.NMEFont.registerFont(mName, function(def) return new NmeSwfFont(def,this) );
      #end
   }

   public function toString() return 'Font($mName)';

   function RestoreLineStyle(g:Graphics)
   {
      //g.lineStyle(1,0x000000);
   }

   public function Ok() { return true; }


   // GlyphRenderer API
   public function GetName() : String { return mName; }

   public function RenderChar(inGraphics:Graphics,inChar:Int,m:Matrix) : Float
   {
      if (mCodeToGlyph.length>inChar)
      {
         var glyph = mCodeToGlyph[inChar];
         if (glyph!=null)
         {
            for(c in glyph.mCommands)
               c(inGraphics,m);
            return glyph.mAdvance;
         }
      }
      return 0;
   }


   static var first = true;
   public function RenderGlyph(inGraphics:Graphics,inGlyph:Int,m:Matrix) : Void
   {
      if (mGlyphs.length>inGlyph)
      {
         var commands = mGlyphs[inGlyph].mCommands;
         for(c in commands)
            c(inGraphics,m);
      }
      else
      {
         trace("Unsupported glyph: " + String.fromCharCode(inGlyph) );
      }
   }

   public function GetAdvance(inChar:Int, ?inNext:Null<Int>) : Float
   {
      if (mCodeToGlyph.length>inChar)
      {
         var glyph = mCodeToGlyph[inChar];
         if (glyph!=null)
            return glyph.mAdvance;
      }

      return 1024.0;
   }

   public function GetAscent() : Float { return mAscent; }
   public function GetDescent() : Float { return mDescent; }
   public function GetLeading() : Float { return mLeading; }


}

#if !flash
class NmeSwfGlyphInfo
{
   public function new() { }

   public var width:Int;
   public var height:Int;
   public var advance:Int;
   public var offsetX:Int;
   public var y0:Int;
   public var offsetY:Int;
}

class NmeSwfFont extends NMEFont
{
   var scaledFont:ScaledFont;
   var shape:nme.display.Shape;
   var reference:nme.display.Sprite;
   var lastShapeChar:Int;
   var glyphInfo:Array<NmeSwfGlyphInfo>;

   public function new(inDef:NMEFontDef, inFont:Font)
   {
      scaledFont = new ScaledFont(inFont, inDef.height);
      super(inDef.height, scaledFont.GetAscent(), scaledFont.GetDescent(), false);
      shape = new nme.display.Shape();
      reference = new nme.display.Sprite();
      reference.addChild(shape);
      glyphInfo = [];
      lastShapeChar = -1;
   }

   override public function getGlyphInfo(inChar:Int):NmeSwfGlyphInfo 
   {
      if (glyphInfo[inChar]==null)
      {
         var info = new NmeSwfGlyphInfo();
         if (lastShapeChar!=inChar)
         {
            var gfx = shape.graphics;
            gfx.clear();
            gfx.beginFill(0xffffff);
            scaledFont.Render(gfx,inChar,0,0, false);
            lastShapeChar = inChar;
         }
         shape.x = shape.y = 0.0;
         var bounds = shape.getBounds(reference);

         info.offsetX = Std.int(Math.floor(bounds.x))-1;
         info.y0 = Std.int(Math.floor(bounds.y))-1;
         info.offsetY = info.y0 - scaledFont.GetAscent();
         info.width = Std.int(Math.ceil(bounds.x+bounds.width)) - info.offsetX + 1;
         info.height = Std.int(Math.ceil(bounds.y+bounds.height)) - info.y0 + 1;
         info.advance = scaledFont.GetAdvance(inChar);
         glyphInfo[inChar] = info;
      }
      return glyphInfo[inChar];
   }

   override public function renderGlyph(inChar:Int) : BitmapData 
   {
      var info = getGlyphInfo(inChar);
      var w = info.width;
      var h = info.height;
      shape.x = -info.offsetX;
      shape.y = -(info.y0);
      if (lastShapeChar!=inChar)
      {
         var gfx = shape.graphics;
         gfx.clear();
         gfx.beginFill(0xffffff);
         scaledFont.Render(gfx,inChar,0,0, false);
         lastShapeChar = inChar;
      }
      var bitmap = new BitmapData(w, h, true, 0x000000);
      bitmap.draw(reference);
      return bitmap;
   }
}
#end
