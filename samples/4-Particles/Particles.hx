import gm2d.display.Sprite;
import gm2d.blit.Tilesheet;
import gm2d.blit.Tile;
import gm2d.blit.Layer;
import gm2d.blit.Grid;
import gm2d.text.TextField;
import gm2d.Game;
import gm2d.events.Event;
import gm2d.Screen;

import gm2d.ui.Keyboard;

class Particle
{
    public var x:Float;
    public var y:Float;
    public var dx:Float;
    public var dy:Float;
    public var phase:Float;
    public var dphase:Float;
    public var tile:Int;

    public static var GRAVITY = 9.8;

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
          dy -= GRAVITY*inDT;

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
   static var MAX_PARTICLES = 250;

   function new()
   {
      super("Main");
      mParticles = [];
      var loader = new gm2d.game.Loader();
      loader.loadBitmap("Blobs.png","blobs");
      loader.Process(onLoaded);
   }

   function onLoaded(inResources:Hash<Dynamic>)
   {
      mResources = inResources;
      var bmp:gm2d.display.BitmapData = mResources.get("blobs");
      mTilesheet = new Tilesheet(bmp);
      mTiles = mTilesheet.partition(16,16);
      for(tile in mTiles)
         tile.hotX = tile.hotY = 0;

      mViewport = gm2d.blit.Viewport.create(400, 300, true, 0x000000);
      mViewport.x = 40;
      mViewport.y = 10;
      addChild(mViewport);

      mParticleLayer = mViewport.createLayer();
      mParticleLayer.dynamicRender = renderParticles;

      mText = new TextField();
      mText.textColor = 0xffffff;
      mText.x = 10;
      mText.y = 50;
      mText.selectable = false;

      addChild(mText);
      

      makeCurrent();
   }

   function renderParticles(inX,inY)
   {
      mParticleLayer.clear();
      for(particle in mParticles)
          mParticleLayer.drawTile(mTiles[particle.tile], particle.x, particle.y );
   }

   override public function updateDelta(inDT:Float)
   {
      var alive = new Array<Particle>();

      for(p in mParticles)
      {
         if (p.move(inDT))
           alive.push(p);
      }

      mParticles = alive;
      for(p in 0...10)
         mParticles.push( new Particle(mViewport.mouseX, mViewport.mouseY) );

      mText.text = "Particles: " + mParticles.length;

      mViewport.invalidate();
   }


   static public function main()
   {
      Game.useHardware = true;
      Game.title = "Particles";
      Game.showFPS = true;
      Game.fpsColor = 0xffffff;
      Game.backgroundColor = 0x202040;
      Game.iPhoneOrientation = 90;
      Game.create(function() new Particles());
   }
}

