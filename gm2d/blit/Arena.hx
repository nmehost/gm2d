package gm2d.blit;

import flash.geom.Rectangle;
import flash.display.BitmapData;


class GOB
{
    // Poistion in Arena coordinates
    public var mGX:Float;
    public var mGY:Float;
    // Current graphocs
    public var mCurrentTile:Blob;
    public var mLevel:ObjectLevel;

    // For object sorting
    public var mZSortPrev:GOB;
    public var mZSortNext:GOB;
    // For collision grid linkage
    public var mGridPrev:GOB;
    public var mGridNext:GOB;
    // Temp for results...
    public var mNext:GOB;


    public function new(inX:Float,inY:Float,inTile:Blob)
    {
       mGX = inX;
       mGY = inY;
       mCurrentTile = inTile;
    }
    public function SetLevel(inLevel:ObjectLevel)
    {
       mLevel = inLevel;
    }
    public function Move(inNewX:Float,inNewY:Float)
    {
    }

}


class ZLevel
{
   var mArena:Arena;

   public function new(inArena:Arena)
   {
      mArena = inArena;
   }
}


class ObjectLevel extends ZLevel
{
   var mWorldOffsetX:Int;
   var mWorldOffsetY:Int;
   var mWorldWidth:Int;
   var mWorldHeight:Int;
   var mZSort:Array<GOB>;

   public function new(inArena:Arena,inWorldWidth:Int, inWorldHeight:Int)
   {
      super(inArena);
      mWorldOffsetX = 0;
      mWorldOffsetY = 0;
      mWorldWidth = inWorldWidth;
      mWorldHeight = inWorldHeight;
      mZSort = [];
      mZSort[inWorldHeight-1] = null;
   }

   public function AddObject(inGOB:GOB)
   {
      inGOB.SetLevel(this);
      var pos = Std.int(inGOB.mGX) - mWorldOffsetX;
      // TODO:
      inGOB.mZSortNext = mZSort[pos];
      inGOB.mZSortPrev = null;
      mZSort[pos]==inGOB;
   }

}



#if flash

class Blob
{
   public var mData:BitmapData;
   public var mSrcRect:Rectangle;
   var mArena:Arena;
   var mHotX:Float;
   var mHotY:Float;

   public function new(inArena:Arena,inData:BitmapData,
                       ?inSrcRect:Rectangle,
                       ?inHotX:Null<Float>,
                       ?inHotY:Null<Float>)
   {
      mArena = inArena;
      mData = inData;
      mSrcRect = inSrcRect==null ? inData.rect : inSrcRect;
      mHotX = inHotX==null ? mSrcRect.width/2 : inHotX;
      mHotY = inHotY==null ? mSrcRect.height/2 : inHotY;
   }
   public function Width() { return mData.width; }
   public function Height() { return mData.height; }
   public function draw(inX:Float, inY:Float)
   {
      mArena.AddTile(this,inX-mHotX,inY-mHotY);
   }
}


class Arena  extends flash.display.Bitmap
{
   var mData:BitmapData;
   var mRect:Rectangle;
   var mRGBA:Int;

   public function new(inWidth:Int,inHeight:Int, inColour:Int, inAlpha:Int)
   {
      mRGBA = inColour | (inAlpha<<24);
      mRect = new Rectangle(0,0,inWidth,inHeight);
      mData = new flash.display.BitmapData(inWidth,inHeight,inAlpha==0,mRGBA);
      super(mData);
   }
   public function Width() { return mRect.width; }
   public function Height() { return mRect.height; }
   public function Clear()
   {
      mData.fillRect(mRect,mRGBA);
   }
   public function CreateTile(inImage:BitmapData,inX0:Int,inY0:Int,inWidth:Int,inHeight:Int,
        inHotX:Int=0, inHotY:Int=0)
   {
      return new Blob(this,inImage,new Rectangle(inX0,inY0,inWidth,inHeight),inHotX,inHotY);
   }
   public function AddTile(inTile:Blob,inX0:Float,inY0:Float)
   {
      mData.copyPixels(inTile.mData,inTile.mSrcRect,new flash.geom.Point(inX0,inY0));
   }


}

#else

import neash.display.Graphics;

class TileInstance
{
   public function new(inTile:Blob,inX:Float,inY:Float)
   {
      mTile = inTile;
      mX = inX;
      mY = inY;
      mTheta = 0;
      mScale = 1;
   }
   inline public function Blit() { mTile.Blit(mX,mY,mTheta,mScale); }
   var mTile:Blob;
   var mX:Float;
   var mY:Float;
   var mTheta:Float;
   var mScale:Float;
}

class Blob extends nme.TileRenderer
{
   var mArena:Arena;
   var mHotX:Float;
   var mHotY:Float;

   public function new(inArena:Arena,inTexture:nme.display.BitmapData,
                       ?inSrcRect:Rectangle,
                       ?inHotX:Null<Float>,
                       ?inHotY:Null<Float>)
   {
      mArena = inArena;
      var r = inSrcRect==null ? inTexture.rect : inSrcRect;
      var hx:Float = inHotX==null ? r.width/2 : inHotX;
      var hy:Float = inHotY==null ? r.height/2 : inHotY;
      super(inTexture,Std.int(r.x),Std.int(r.y), Std.int(r.width),Std.int(r.height), hx, hy );
   }
   public function Width() { return getWidth(); }
   public function Height() { return getHeight(); }
   public function draw(inX:Float, inY:Float)
   {
      mArena.AddTile(this,inX,inY);
   }
}

typedef Tiles = Array<TileInstance>;

class Arena extends neash.display.DisplayObject
{
   var mColour:Int;
   var mAlpha:Int;
   var mRect:Rectangle;
   var mTiles:Tiles;
   var mWorldX0:Int;
   var mWorldY0:Int;

   public function new(inWidth:Int,inHeight:Int, inColour:Int, inAlpha:Int)
   {
      super();
      mColour = inColour;
      mAlpha = inAlpha;
      mRect = new Rectangle(0,0,inWidth,inHeight);
      mScrollRect = new neash.geom.Rectangle(0,0,inWidth,inHeight);
      mTiles = new Tiles();
      name = "Arena";
      mWorldX0 = 0;
      mWorldY0 = 0;
   }
   public function Clear()
   {
      mTiles = [];
   }
   public function Width() { return mRect.width; }
   public function Height() { return mRect.height; }

   public override function __Render(inParentMask:Dynamic,inScrollRect:Rectangle,inTX:Int,inTY:Int):Dynamic
   {
      nme.Manager.SetBlitArea(mRect,mColour,mAlpha,mFullMatrix);
      for(tile in mTiles)
         tile.Blit();
      nme.Manager.UnSetBlitArea();
      return inParentMask;
   }


   public function CreateTile(inImage:BitmapData,inX0:Int,inY0:Int,inWidth:Int,inHeight:Int,
            inHotX:Int = 0, inHotY:Int = 0)
   {
      return new Blob(this,inImage,new Rectangle(inX0,inY0,inWidth,inHeight),inHotX,inHotY);
   }
   public inline function AddTile(inTile:Blob,inX:Float,inY:Float)
   {
      mTiles.push( new TileInstance(inTile,inX,inY) );
   }
}


#end

