package gm2d.ui;
import gm2d.display.BitmapData;
import gm2d.display.Bitmap;
import gm2d.text.TextField;
import gm2d.blit.Tile;
import gm2d.blit.Tilesheet;
import gm2d.filters.BitmapFilter;
import gm2d.filters.GlowFilter;
import gm2d.geom.Rectangle;
import gm2d.geom.Point;
import gm2d.display.BitmapDataChannel;

class TileInfo
{
   public function new(inTile,inAdvance) { mTile = inTile; mAdvance = inAdvance; }
   public var mTile:Tile;
   public var mAdvance:Float;
}

typedef Factory = BitmapFont -> Int -> Void;

class BitmapFont extends gm2d.blit.Tilesheets
{
   var mGlyphs : Array<TileInfo>;
   var mFactory:Factory;

   public var height(default,null):Float;
   public var leftToRight:Bool;
   public var packing:Float;

   public function new(inNominalHeight:Float, inLeftToRight:Bool = true, ?inFactory:Factory )
   {
	   super();
      mGlyphs = [];
      height = inNominalHeight;
      mFactory = inFactory;
      leftToRight = inLeftToRight;
      packing = 0;
   }

   public static function createFilters(inFont:String, inHeight:Float, inCol, inLeftToRight:Bool,inFilters:Array<BitmapFilter>, inMask:BitmapData )
   {
      var fmt = new gm2d.text.TextFormat();
      fmt.size = inHeight;
      fmt.font = inFont;
      var tf = new TextField( );
      #if flash
      for(f in flash.text.Font.enumerateFonts(false) )
         if (f.fontName == inFont )
         {
            tf.embedFonts = true;
            break;
         }
      #end

      tf.textColor = inCol;
      tf.defaultTextFormat = fmt;
      tf.autoSize = gm2d.text.TextFieldAutoSize.LEFT;

      return new BitmapFont(Std.int(inHeight*1.5),  inLeftToRight, function(font,ch)
         {
            tf.text = String.fromCharCode(ch);
            var w = Std.int(tf.textWidth)+5;
            var h = Std.int(tf.textHeight);
            var bmp = new BitmapData(w,h,true, gm2d.RGB.CLEAR );
            tf.filters = null;
            bmp.draw(tf);
            var rect = bmp.getColorBoundsRect( gm2d.RGB.BLACK, gm2d.RGB.CLEAR, false ); // Not clear
            if (inMask!=null)
            {
               var r = new Rectangle(0,0,bmp.width,bmp.height);
               var p = new Point(0,0);
               bmp.copyChannel(inMask,r,p, BitmapDataChannel.RED, BitmapDataChannel.RED );
               bmp.copyChannel(inMask,r,p, BitmapDataChannel.GREEN, BitmapDataChannel.GREEN );
               bmp.copyChannel(inMask,r,p, BitmapDataChannel.BLUE, BitmapDataChannel.BLUE );
            }

            if (rect.width==0 || rect.height==0)
               font.addGlyph(ch,null,ch!=32 ? 0 : ((h>>3)+1));
            else
            {
               var frect = rect;
               if (inFilters!=null)
                  for(filter in inFilters)
                     frect = bmp.generateFilterRect(frect,filter);
               //trace(frect);

               var tight = new BitmapData( Std.int(frect.width), Std.int(frect.height),true, gm2d.RGB.CLEAR );

               var bitmap = new Bitmap(bmp);
               bitmap.filters = inFilters;
               tight.draw(bitmap,new gm2d.geom.Matrix(1,0,0,1,-frect.x,-frect.y) );
               var tile = font.addBitmap(ch,tight,rect.width+1);
               tile.hotX = -(frect.x-rect.x);
               tile.hotY = -frect.y;
            }
         } );
   }
   public static function create(inFont:String, inHeight:Float=12, inCol=0x000000, inLeftToRight:Bool=true)
   {
      var filters:Array<BitmapFilter> = [];
      filters.push( new GlowFilter(0x000000,1,3,3,3) );

      var h = Std.int( Math.ceil(inHeight) );
      var bmp:BitmapData = null;
      bmp  = new BitmapData(h,Std.int(h*1.5),true, gm2d.RGB.YELLOW );

		var shape = new gm2d.display.Shape();
		var gfx = shape.graphics;
		var mtx = new gm2d.geom.Matrix();
		mtx.createGradientBox(inHeight,inHeight,Math.PI*0.5,0,inHeight*0.25);

		var cols:Array<Int> = [0xff0000, 0xffffff, 0xffff00 ];
      var alphas:Array<Float> = [1.0, 1.0, 1.0];
      var ratio:Array<Int> = [0, 128, 255];
      gfx.beginGradientFill(gm2d.display.GradientType.LINEAR, cols, alphas, ratio, mtx );
      gfx.drawRect(0,0,inHeight,inHeight*1.5);
		bmp.draw(shape);

      return createFilters(inFont,inHeight,0x000000,inLeftToRight,filters, bmp);
   }

   // Extract a font from a set of rectangles surrounded by bright pink, such as
   //  those generated by http://www.ironstarmedia.co.uk/blog/fancy-bitmap-font-generator/
   public static function createFromActiveRects(inBMP:BitmapData,inFirstGlyph:Int)
   {
      var rects = new Array<Rectangle>();

      var w = inBMP.width;
      var h = inBMP.height;
      var bytes = inBMP.getPixels( new Rectangle(0,0,w,h) );

      var last_starts:Array<Int> = [];
      var last_stops:Array<Int> = [];
      var last_start_row = 0;

      var max_width = 0;
      var total_height = 0;
      var max_height = 0;

      bytes.position = 0;

      for(y in 0...h)
      {
         var last_data = false;
         var starts = new Array<Int>();
         var stops = new Array<Int>();
         for(x in 0...w)
         {
            var a = bytes.readUnsignedByte();
            var r = bytes.readUnsignedByte();
            var g = bytes.readUnsignedByte();
            var b = bytes.readUnsignedByte();

            //if (x<60 && y==20)
               //trace("r=" + r + " g=" + g + " b=" + b + " a=" + a);


            // WTF - flash gives values of 254?
            if (r<254 || g!=0 || b<254 /*|| a<254*/)
            {
               if (!last_data) // new rect !
                  starts.push(x);
               last_data = true;
            }
            else
            {
               if (last_data)
                  stops.push(x);
               last_data = false;
            }
         }

         if (last_starts.length>0 && starts.length==0)
         {
            var w = 0;
            var h = y-last_start_row;
            for(i in 0...last_starts.length)
            {
               rects.push( new Rectangle(last_starts[i],last_start_row,
                       last_stops[i]-last_starts[i], h ) );
               w += last_stops[i]-last_starts[i];
            }
            total_height += h;
            if (h>max_height) max_height = h;
            if (w>max_width) max_width = w;
         }
         else if (last_starts.length==0 && starts.length>0)
         {
            last_start_row = y;
         }

         last_starts = starts;
         last_stops = stops;
      }

      var font = new BitmapFont(max_height, true);
      var sheet = Tilesheet.create(max_width,total_height);
      var glyph_id = inFirstGlyph;
      for(rect in rects)
      {
          var tile = sheet.addTileRect(inBMP,rect);
          //trace(glyph_id + ":" + (tile==null ? null : tile.rect) );
          font.addGlyph(glyph_id++,tile,rect.width);
      }
      return font;

      //trace("Active area :" + max_width + "x" + total_height);
      //trace(rects);
   }

   public function getGlyph(inGlyph:Int) : Tile
   {
      if (mGlyphs[inGlyph]==null)
      {
         if (mFactory!=null)
            mFactory(this,inGlyph);
         if (mGlyphs[inGlyph]==null)
            return null;
      }
      return mGlyphs[inGlyph].mTile;
   }

   public function getAdvance(inGlyph:Int) : Float
   {
      if (mGlyphs[inGlyph]==null)
      {
         if (mFactory!=null)
            mFactory(this,inGlyph);
         if (mGlyphs[inGlyph]==null)
            return 0;
      }
      var a = mGlyphs[inGlyph].mAdvance + packing;
      return a<0 ? 0 : a;
   }

   public function addGlyph(inGlyph:Int,inTile:Tile,inAdvance:Float)
   {
      mGlyphs[inGlyph] = new TileInfo(inTile,inAdvance);
   }

   public function addBitmap(inGlyph:Int,inData:BitmapData,inAdvance:Float)
   {
      var tile = addData(inData);
      mGlyphs[inGlyph] = new TileInfo(tile,inAdvance);
      return tile;
   }
}


