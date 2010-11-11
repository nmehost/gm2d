package gm2d.ui;
import gm2d.display.BitmapData;
import gm2d.text.TextField;
import gm2d.blit.Tile;
import gm2d.blit.Tilesheet;
import gm2d.filters.BitmapFilter;
import gm2d.filters.GlowFilter;
import gm2d.geom.Rectangle;

class TileInfo
{
   public function new(inTile,inAdvance) { mTile = inTile; mAdvance = inAdvance; }
   public var mTile:Tile;
   public var mAdvance:Float;
}

typedef Factory = BitmapFont -> Int -> Void;

class BitmapFont
{
   var mGlyphs : Array<TileInfo>;
   var mFactory:Factory;
   var height(default,null):Float;
   var leftToRight(default,null):Bool;
   var mConstructTilesheet:Tilesheet;

   public function new(inNominalHeight:Float, inLeftToRight:Bool = true, ?inFactory:Factory )
   {
      mGlyphs = [];
      height = inNominalHeight;
      mFactory = inFactory;
      leftToRight = inLeftToRight;
   }

   public static function create(inFont:String, inHeight:Float=12, inCol=0x000000, inLeftToRight:Bool=true)
   {
      var fmt = new gm2d.text.TextFormat();
      fmt.size = inHeight;
      fmt.font = inFont;
      var tf = new TextField( );
      tf.textColor = inCol;
      tf.defaultTextFormat = fmt;
      tf.autoSize = gm2d.text.TextFieldAutoSize.LEFT;

      var filters:Array<BitmapFilter> = [];
      filters.push( new GlowFilter(0xff0000,1,6,6,2,1) );

      return new BitmapFont(inHeight,  inLeftToRight, function(font,char)
         {
            tf.text = String.fromCharCode(char);
            var w = Std.int(tf.textWidth)+5;
            var h = Std.int(tf.textHeight);
            var bmp = new BitmapData(w,h,true, gm2d.RGB.CLEAR );
            tf.filters = null;
            bmp.draw(tf);
            var rect = bmp.getColorBoundsRect( gm2d.RGB.BLACK, gm2d.RGB.CLEAR, false ); // Not clear
            if (rect.width==0 || rect.height==0)
               font.addGlyph(char,null,0);
            else
            {
               var frect = rect;
               for(filter in filters)
                  frect = bmp.generateFilterRect(frect,filter);
               //trace(frect);

               var tight = new BitmapData( Std.int(frect.width), Std.int(frect.height),true, gm2d.RGB.CLEAR );
               tf.filters = filters;
               tight.draw(tf,new gm2d.geom.Matrix(1,0,0,1,-frect.x,-frect.y) );
               var tile = font.addBitmap(char,tight,rect.width+1);
               tile.hotX = -(frect.x-rect.x);
               tile.hotY = -frect.y;
            }
         } );
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
      return mGlyphs[inGlyph].mAdvance;
   }

   public function addGlyph(inGlyph:Int,inTile:Tile,inAdvance:Float)
   {
      mGlyphs[inGlyph] = new TileInfo(inTile,inAdvance);
   }

   function NextPOT(inVal:Int)
   {
      var result = 1;
      while(result<inVal)
         result<<=1;
      return result;
   }

   public function addBitmap(inGlyph:Int,inData:BitmapData,inAdvance:Float)
   {
      var tile:Tile = null;
      for(pass in 0...2)
      {
         if (mConstructTilesheet==null)
         {
            var w = NextPOT(inData.width * 10);
            if (w>512) w = 512;
            if (w<inData.width) w = inData.width;
            var h = NextPOT(inData.height * 10);
            if (h>512) h = 512;
            if (h<inData.height) h = inData.height;
            mConstructTilesheet = Tilesheet.create(w,h,Tilesheet.BORDERS_TRANSPARENT);
         }
         tile = mConstructTilesheet.addTile(inData);
         if (tile==null)
            mConstructTilesheet = null;
         else
            break;
      }
      mGlyphs[inGlyph] = new TileInfo(tile,inAdvance);
      return tile;
   }
}


