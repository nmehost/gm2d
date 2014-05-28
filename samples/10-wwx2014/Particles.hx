import nme.geom.Point;
import nme.geom.Rectangle;
import nme.display.Sprite;
import nme.display.DisplayObject;
import nme.display.BitmapData;
import gm2d.blit.Tile;
import gm2d.blit.Tilesheet;
import nme.Assets;

class Particle
{
    public var x:Float;
    public var y:Float;
    public var dx:Float;
    public var dy:Float;
    public var phase:Float;
    public var dphase:Float;
    public var tile:Int;

    public static var GRAVITY_X = 0.0;
    public static var GRAVITY_Y = -9.8;

    public function new(inP:Point)
    {
       x = inP.x;
       y = inP.y;
       phase = 0;
       dphase = Rand(0.5,2.5);
       var theta = Rand(0,Math.PI*2.0);
       var vel = Rand(5,10);
       dx = Math.cos(theta)*vel;
       dy = Math.sin(theta)*vel;
       tile = 0;
    }
    public function move(inDT:Float):Bool
    {
       phase += dphase*inDT;
       tile = Std.int(phase);
       if (tile>=4)
          return false;
       x+=dx*inDT;
       y+=dy*inDT;
       if (phase<2)
       {
          dx += GRAVITY_X*inDT;
          dy += GRAVITY_Y*inDT;
       }

       return true;
    }
    public function pushTo(outData:Array<Float>)
    {
       outData.push(x);
       outData.push(y);
       outData.push(tile);
    }

    function Rand(inR0:Float, inR1:Float)
    {
        return inR0 + Math.random()*(inR1-inR0);
    }
}


class Particles extends Sprite
{
   var mTiles:Array<Tile>;
   var mTilesheet:Tilesheet;
   var mParticles:Array<Particle>;
   var mSeeds:Array<Point>;
   var mViewport:gm2d.blit.Viewport;
   var mParticleLayer:gm2d.blit.Layer;

   public function new(inWidth:Int, inHeight:Int)
   {
      super();
      mParticles = [];
      mSeeds = [];

      var bmp = Assets.getBitmapData("Blobs.png");
      mTilesheet = new Tilesheet(bmp);
      mTiles = mTilesheet.partition(16,16);
      for(tile in mTiles)
         tile.hotX = tile.hotY = 0;

      mViewport = gm2d.blit.Viewport.create(inWidth, inHeight, gm2d.blit.Viewport.BG_DONT_CARE, 0x000000);
      addChild(mViewport);

      mParticleLayer = mViewport.createLayer();
      mParticleLayer.dynamicRender = renderParticles;
      mParticleLayer.blendAdd = true;

   }

   public function setDisplaySource(inObj:DisplayObject)
   {
      mSeeds = [];
      var x0 = inObj.x;
      var y0 = inObj.y;
      var w = Std.int(inObj.width);
      var h = Std.int(inObj.height);
      var bmp = new BitmapData(w,h,false,0xffffff);
      bmp.draw(inObj);
      var pixels = bmp.getPixels(new Rectangle(0,0,w,h) );
      pixels.position = 0;
      for(y in 0...h)
         for(x in 0...w)
            if ( (pixels.readInt() & 0x0000ff) < 128 )
               mSeeds.push( new Point(x+x0, y+y0) );
   }

   function renderParticles(inX,inY)
   {
      mParticleLayer.clear();
      for(particle in mParticles)
          mParticleLayer.drawTile(mTiles[particle.tile], particle.x, particle.y );
   }


   public function update()
   {
      var alive = new Array<Particle>();

      var dt = 0.020;
      for(p in mParticles)
      {
         if (p.move(dt))
           alive.push(p);
      }

      mParticles = alive;
      if (mSeeds.length>0)
      {
         for(p in 0...50)
            mParticles.push( new Particle(mSeeds[ Std.int(Math.random() * mSeeds.length) ] ) );
      }

      mViewport.invalidate();

      /*
      var gfx = graphics;
      gfx.clear();

      var n = mParticles.length;
      if (n>0)
      {
         var data = new Array<Float>();
         for(particle in mParticles)
            particle.pushTo(data);
         mTilesheet.drawTiles(gfx, data, false, nme.display.Graphics.TILE_BLEND_ADD);
      }
      */
   }
}

