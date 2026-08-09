package gm2d.ui;
import gm2d.skin.ProgressStyle;
import nme.events.Event;


class ProgressBar extends Widget
{
   var mMax:Float;
   var mFraction:Float;
   var ball:nme.display.Shape;
   var ballRad:Float;
   var t0:Float;

   public function new(inMax:Float,?inLineage:Array<String>,?inAttribs:Attribs)
   {
      super(Widget.addLine(inLineage,"ProgressBar"),inAttribs);
      mMax = inMax;
      mFraction = 0.0;
      //build();
   }

   public function update(inValue:Float)
   {
      mFraction = inValue / mMax;
      if (mFraction>1) mFraction = 1;
      if (mFraction<0) mFraction = 0;
      redraw();
   }

   function updateBallPos()
   {
      if (mFraction<1)
      {
         var w = mRect.width - ballRad*2;
         var h = mRect.height - ballRad*2;

         var bpos = ((haxe.Timer.stamp()-t0)*0.5) % 2;
         if (bpos>1)
            bpos = 2-bpos;
         ball.x = ballRad + w*bpos;
         ball.y = ballRad + h*0.5;

         if (stage!=null)
            stage.invalidate();
      }
   }

   override public function redraw()
   {
      var gfx = graphics;

      gfx.clear();
      var style:ProgressStyle = attribDynamic("progressStyle",null);
      if (style==null)
         return;
      switch(style)
      {
        case ProgressRoundRect(outline, fill, empty, lineWidth, radius):
           var w = mRect.width;
           var h = mRect.height;
           var lw = skin.toPixels(lineWidth);
           var rad = skin.toPixels(radius);
           var outlineCol = skin.resolveLineColour(outline);
           var fillCol = skin.resolveFillColour(fill);
           var emptyCol = skin.resolveFillColour(empty);

           var off = (Std.int(lw) & 1) > 0 ? 0.5 : 0.0;
           gfx.beginFill(emptyCol);
           gfx.drawRoundRect(off,off,w,h,rad,rad);
           gfx.lineStyle();
           gfx.beginFill(fillCol);
           gfx.drawRoundRect(off,off,w*mFraction,h,rad,rad);
           gfx.endFill();
           gfx.lineStyle(lw,outlineCol);
           gfx.drawRoundRect(off,off,w,h,rad,rad);

        case ProgressRoundRectBall(outline, fill, empty, lineWidth, radius):
           var w = mRect.width;
           var h = mRect.height;
           var lw = skin.toPixels(lineWidth);
           var rad = skin.toPixels(radius);
           var outlineCol = skin.resolveLineColour(outline);
           var fillCol = skin.resolveFillColour(fill);
           var emptyCol = skin.resolveFillColour(empty);

           var off = (Std.int(lw) & 1) > 0 ? 0.5 : 0.0;
           gfx.beginFill(emptyCol);
           gfx.lineStyle(lw,outlineCol);
           gfx.drawRoundRect(off,off,w,h,rad,rad);

           if (ball==null && mFraction<1)
           {
              ball = new nme.display.Shape();
              addChild(ball);
              ballRad = rad;
              var g = ball.graphics;
              g.beginFill(fillCol);
              g.drawCircle(0,0,rad);
              t0 = haxe.Timer.stamp();

              addEventListener( Event.ENTER_FRAME, (_) -> updateBallPos() );
              addEventListener( Event.RENDER, (_) -> updateBallPos() );

              updateBallPos();
           }
      }
   }
}

