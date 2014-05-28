package game;

import nme.media.Camera;
import nme.display.Sprite;
import nme.display.Shape;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.geom.Matrix;
import nme.geom.Rectangle;
import nme.geom.Point;
import nme.native.ImageBuffer;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.events.KeyboardEvent;


class Game extends Sprite
{
   public inline static var BAT_RAD = 64;
   public inline static var PUCK_RAD = 30;
   public inline static var SAFE_TIME = 3;

   public static var reflect = #if windows false #else true #end;
   // For debug
   public static var overlay:Sprite;

   var camera:Camera;
   var display:Sprite;
   var board:Sprite;
   var goals:Shape;
   var gameWidth:Int;
   var gameHeight:Int;
   var prevFrame:BitmapData;
   var debugBitmap:BitmapData;
   var enableCam:Bool;

   var screenWidth:Int;
   var screenHeight:Int;

   var scoreLeft:Int = 0;
   var scoreLeftGfx:Shape;
   var scoreRight:Int = 0;
   var scoreRightGfx:Shape;

   var left:Paddle;
   var right:Paddle;
   var puck:Puck;
   var font:Array<String>;


   var t0:Float;
   var tLastScore:Float;

   public function new(inScreenWidth:Int, inScreenHeight:Int)
   {
      super();
      camera = Camera.getCamera();
      if (camera==null)
         return;

      enableCam = true;
      screenWidth = inScreenWidth;
      screenHeight = inScreenHeight;

      left = null;
      right = null;
      puck = null;
      font = [
      "000 1 2223334 45556  777888999",
      "0 0 1   2  34 45  6    78 89 9",
      "0 0 1 222333444555666  7888999",
      "0 0 1 2    3  4  56 6 7 8 8  9",
      "000 1 222333  4555666 7 888  9" ];


      camera.addEventListener(Event.VIDEO_FRAME,onFrame);
      addEventListener(Event.ENTER_FRAME, function(_) update() );
      addEventListener(MouseEvent.MOUSE_DOWN, function(_) enableCam=false );
      addEventListener(MouseEvent.MOUSE_UP, function(_) enableCam=true );
      addEventListener(MouseEvent.MOUSE_MOVE, onMouse );
      addEventListener(Event.REMOVED_FROM_STAGE, function(e) closeCamera() );
      nme.Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
   }

   public function ok() { return camera!=null; }

   function closeCamera( )
   {
      camera.removeEventListener(Event.VIDEO_FRAME,onFrame);
      nme.Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
   }

   function createVideoDisplay()
   {
      var data =  camera.bitmapData;
      var w = data.width;
      var h = data.height;
      // Video feed - possible reflected...
      var mtx = new Matrix();
      if (reflect)
      {
         mtx.a = -1;
         mtx.tx = w;
      }
      var gfx = display.graphics;
      gfx.clear();
      gfx.beginBitmapFill(data,mtx);
      gfx.drawRect(0,0,w,h);

      var gfx = overlay.graphics;
      gfx.clear();
      gfx.beginBitmapFill(debugBitmap,mtx);
      gfx.drawRect(0,0,w,h);
   }


   function onCreate()
   {
      var data =  camera.bitmapData;
      var w = gameWidth = data.width;
      var h = gameHeight = data.height;

      display = new Sprite();
      overlay = new Sprite();
      debugBitmap = new BitmapData(w,h,true,0x00000000);
      addChild(display);

      createVideoDisplay();

      // Show the game board - use alphs so video can be seen
      board = new Sprite();
      display.addChild(board);

      var gfx = board.graphics;
      board.cacheAsBitmap = true;
      gfx.beginFill(0xffffff,0.75);
      gfx.drawRect(0,0,gameWidth,gameHeight);
      gfx.endFill();
      gfx.lineStyle(5,0xff0000);
      gfx.drawRect(0,0,gameWidth,gameHeight);
      gfx.endFill();
      gfx.moveTo(gameWidth*0.5,0);
      gfx.lineTo(gameWidth*0.5,gameHeight);
      gfx.drawCircle(gameWidth/2, gameHeight/2, gameHeight*0.125);

      goals = new Shape();
      display.addChild(goals);
      var gfx = goals.graphics;
      gfx.lineStyle(5,0x0000ff);
      gfx.beginFill(0x8080ff);
      gfx.drawRect(-gameWidth*0.05,gameHeight*0.25,gameWidth*0.05,gameHeight*0.5);
      gfx.drawRect(gameWidth,gameHeight*0.25,gameWidth*0.05,gameHeight*0.5);

      // Game elements ...
      left = new Paddle(display,w,h,true);
      right = new Paddle(display,w,h,false);
      puck = new Puck(display);

      scoreLeftGfx = new Shape();
      addChild(scoreLeftGfx);
      scoreRightGfx = new Shape();
      addChild(scoreRightGfx);


      // Debug overlay
      display.addChild(overlay);

      startGame();
   }


   function time() { return haxe.Timer.stamp(); }

   function buildScoreGfx(shape:Shape, value:Int, inColour:Int)
   {
      shape.cacheAsBitmap = true;
      var gfx = shape.graphics;
      gfx.clear();
      gfx.beginFill(inColour);
      var chars = (value+"").split("");
      var x = 0;
      var scale = Std.int(screenWidth * 0.01);
      for(char in chars)
      {
         var index = char.charCodeAt(0) - "0".charCodeAt(0);
         if (index>=0 && index<=9)
         {
            for(cy in 0...5)
               for(cx in 0...3)
               {
                  if (font[cy].substr(cx+index*3,1)!=" ")
                     gfx.drawRect(x + cx*scale, y+cy*scale, scale*0.9, scale*0.9);
               }
            x+= Std.int(scale*3.4);
         }
      }
   }

   function showScore()
   {
      buildScoreGfx(scoreLeftGfx, scoreLeft, 0xff0000);
      buildScoreGfx(scoreRightGfx, scoreRight, 0xff0000);

      scoreLeftGfx.x = Std.int( screenWidth * 0.45 - scoreLeftGfx.width );
      scoreRightGfx.x = Std.int( screenWidth * 0.55 );
   }

   function startGame()
   {
      scoreLeft = 0;
      scoreRight = 0;
      showScore();
      startRound();
   }

   function startRound()
   {
      tLastScore = time();
      puck.init(gameWidth/2,gameHeight/2,
         (Math.random() - 0.5) * gameWidth * 0.2,
         (Math.random() - 0.5) * gameHeight * 0.2);
      t0 = time();
   }

   function win(inPlayer:Int)
   {
      if (inPlayer==0)
         scoreLeft++;
      else
         scoreRight++;
      showScore();
      startRound();
   }

   function update()
   {
      if (puck==null)
         return;

      var t = time();
      var dt = t-t0;
      t0 = t;
      if (dt>0.1) dt = 0.1;

      if (t>tLastScore + SAFE_TIME)
         goals.visible = true;
      else
         goals.visible = Std.int((t-tLastScore)*5) & 0x1 > 0;

      var edgeForce = 500.0;
      var paddleForce = 100.0;

      dt *= 0.1;
      for(pass in 0...10)
      {
         var forceX = 0.0;
         var forceY = 0.0;

         if (puck.x<5+PUCK_RAD)
            forceX += (5+PUCK_RAD-puck.x) * edgeForce;
         else if (puck.x>gameWidth-5-PUCK_RAD)
            forceX -= (puck.x-(gameWidth-5-PUCK_RAD))*edgeForce;

         if (puck.y<5+PUCK_RAD)
            forceY += (5+PUCK_RAD-puck.y) * edgeForce;
         else if (puck.y>gameHeight-5-PUCK_RAD)
            forceY -= (puck.y-(gameHeight-5-PUCK_RAD))*edgeForce;


         for(p in [left,right])
         {
            var dx = puck.x - p.x;
            var dy = puck.y - p.y;
            var dist = Math.sqrt(dx*dx+dy*dy);
            if (dist>0 && dist<PUCK_RAD+BAT_RAD)
            {
               dx/=dist;
               dy/=dist;
               forceX += paddleForce * dx * ( PUCK_RAD+BAT_RAD-dist);
               forceY += paddleForce * dy * ( PUCK_RAD+BAT_RAD-dist);
            }
         }

         puck.vx += forceX*dt;
         puck.vy += forceY*dt;
         puck.vx*=(1-dt*0.1);
         puck.vy*=(1-dt*0.1);
         puck.x += puck.vx * dt;
         puck.y += puck.vy * dt;
      }

      puck.updateDisplay();

      if (t>tLastScore+SAFE_TIME && puck.y>gameHeight*0.25 && puck.y<gameHeight*0.75)
      {
         if (puck.x<5+PUCK_RAD)
            win(1);
         else if (puck.x>gameWidth-5-PUCK_RAD)
            win(0);
      }
   }

   function setBmpSize()
   {
      if (display!=null)
      {
         var sw:Float = screenWidth*0.9;
         var sh:Float = screenHeight*0.75;
         var w = gameWidth;
         var h = gameHeight;
         if (w*sh > h*sw)
            sh = h*sw/w;
         else
            sw = w*sh/h;

         display.scaleX = sw/gameWidth;
         display.scaleY = sh/gameHeight;
         display.x = (screenWidth-sw)*0.5;
         display.y = (screenHeight*0.75-sh)*0.5 + screenHeight*0.2;

         scoreLeftGfx.y = screenHeight * 0.0;
         scoreRightGfx.y = screenHeight * 0.0;
      }
   }

   function onMouse(inEvent:MouseEvent)
   {
      if (!enableCam)
      {
         var pos = display.globalToLocal( new Point(inEvent.stageX, inEvent.stageY) );
         right.x = pos.x;
         right.y = pos.y;
         right.updateDisplay();
      }
   }

   function onKeyDown(event:KeyboardEvent)
   {
         trace("onKeyDown");
      if (event.keyCode=="R".charCodeAt(0))
      {
         reflect = !reflect;
         if (display!=null)
            createVideoDisplay();
      }
      else
         trace(event.keyCode);
   }

   public function onFrame(_)
   {
      if (puck==null)
      {
         onCreate();
         setBmpSize();
      }

      if (prevFrame!=null && enableCam)
      {
         var gfx = Game.overlay.graphics;
         gfx.clear();

         var src = ImageBuffer.fromBitmapData(camera.bitmapData);
         var prev = ImageBuffer.fromBitmapData(prevFrame);

         left.processFrame(src, prev);
         right.processFrame(src, prev);
      }

      var data = camera.bitmapData;
      var w = data.width;
      var h = data.height;
      if (prevFrame==null)
         prevFrame = new BitmapData(w,h);
      prevFrame.copyPixels(data, new Rectangle(0,0,w,h),new Point(0,0) );

  }
}


