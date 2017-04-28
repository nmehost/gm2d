import nme.display.Sprite;
import gm2d.blit.Tilesheet;
import gm2d.blit.Tile;
import gm2d.blit.Layer;
import gm2d.blit.Grid;
import nme.text.TextField;
import gm2d.Game;
import nme.events.Event;
import gm2d.Screen;

#if !flash
import nme.ui.Accelerometer;
#end

import nme.ui.Keyboard;

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

    public function new(inX:Float, inY:Float)
    {
       x = inX;
       y = inY;
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
    function Rand(inR0:Float, inR1:Float)
    {
        return inR0 + Math.random()*(inR1-inR0);
    }
}


class Particles extends Screen
{
   var mResources:Hash<Dynamic>;
   var mTilesheet:Tilesheet;
   var mTiles:Array<Tile>;
   var mViewport:gm2d.blit.Viewport;
   var mParticleLayer:Layer;
   var mParticles : Array<Particle>;
   var mText:TextField;
   var addParticles:Int;

   function new()
   {
      super();
      mParticles = [];

      var bmp:nme.display.BitmapData = gm2d.reso.Resources.loadBitmap("Blobs.png");
      mTilesheet = new Tilesheet(bmp);
      mTiles = mTilesheet.partition(16,16);
      for(tile in mTiles)
         tile.hotX = tile.hotY = 8;

      mViewport = gm2d.blit.Viewport.create(400, 300, gm2d.blit.Viewport.BG_DONT_CARE, 0x000000);
      mViewport.x = 40;
      mViewport.y = 10;
      addChild(mViewport);

      addParticles = 50;

      mParticleLayer = mViewport.createLayer();
      mParticleLayer.dynamicRender = renderParticles;
      mParticleLayer.blendAdd = true;

      mText = new TextField();
      mText.textColor = 0xffffff;
      mText.x = 10;
      mText.y = 50;
      mText.selectable = false;

      addChild(mText);
      

      makeCurrent();
   }

   override public function getScaleMode() return gm2d.ScreenScaleMode.CENTER_SCALED;

   function renderParticles(inX,inY)
   {
      mParticleLayer.clear();
      for(particle in mParticles)
          mParticleLayer.drawTile(mTiles[particle.tile], particle.x, particle.y );
   }

   override public function updateDelta(inDT:Float)
   {
      var alive = new Array<Particle>();

      #if !flash
      var acc = Accelerometer.get();
      if (acc!=null)
      {
         Particle.GRAVITY_X = acc.y*9.8;
         Particle.GRAVITY_Y = acc.x*9.8;
      }
      #end

      for(p in mParticles)
      {
         if (p.move(inDT))
           alive.push(p);
      }

      if (inDT>0.020)
         addParticles--;
      else
         addParticles++;

      mParticles = alive;
      var mx = mViewport.mouseX;
      var my = mViewport.mouseY;
      for(p in 0...addParticles)
         mParticles.push( new Particle(mx+(Math.random()*10-5),my+(Math.random()*10-5)) );

      mText.text = "Particles: " + mParticles.length;

      mViewport.invalidate();
   }


   static public function main()
   {
      Game.showFPS = true;
      Game.fpsColor = 0xffffff;
      Game.backgroundColor = 0x202040;
      new Particles();
   }
}

