package gm2d.tween;

import haxe.Timer;

class Timeline
{
   public var time(default,null):Float;
   var tweens:Array<Tween>;
   var timer:Timer;

   public function new( )
   {
      tweens = new Array<Tween>();
      time = 0;
   }
   public function onActivate(isActive:Bool)
   {
      if (isActive)
      {
         if (timer!=null)
         {
            timer.stop();
            timer = null;
         }
      }
      else
      {
         // Huh?
         if (timer!=null)
             return;
         checkTimer();
      }
   }

   function checkTimer()
   {
      if ( (timer!=null) != (tweens.length>0) )
      {
         if (tweens.length>0)
         {
            timer = new Timer(50);
            timer.run = Game.update;
         }
         else
         {
            timer.stop();
            timer = null;
         }
      }
   }

   public function clearAll(inWithCallback = true)
   {
      if (inWithCallback)
         for(tween in tweens)
            if (tween.onComplete!=null)
               tween.onComplete();
      tweens = new Array<Tween>();
      checkTimer();
   }
   public function remove(inName:String, inWithCallback = true)
   {
      for(i in 0...tweens.length)
      {
         var tween = tweens[i];
         if (tween.name==inName)
         {
            tweens.splice(i,1);
            if (inWithCallback && tween.onComplete!=null)
               tween.onComplete();
            checkTimer();
            return;
         }
      }
   }
   public function update(inDT:Float)
   {
      //if (inDT>0.2) trace(inDT);
      time += inDT;
      if (tweens.length>0)
      {
         var curr_tweens = tweens;
         tweens = new Array<Tween>();
         for(tween in curr_tweens)
         {
            if (tween.t1>time)
            {
               if (tween.onUpdate!=null)
                  tween.onUpdate( (time-tween.t0)/(tween.t1-tween.t0) );
               tweens.push(tween);
            }
            else
            {
               if (tween.onUpdate!=null)
                  tween.onUpdate(1.0);
               if (tween.onComplete!=null)
                  tween.onComplete();
            }
         }
      }
      checkTimer();
   }


   public function createTween(inName:String,inVal0:Float,inVal1:Float,
                     inSeconds:Float,
                     inOnUpdate:Float->Void,
                     ?inOnComplete:Void->Void,
                     ?inEasing:Float->Float )
   {
      var tween = new Tween(inName, time, time+inSeconds, null, inOnComplete);
      if (inOnUpdate!=null)
      {
         if (inEasing==null)
            tween.onUpdate = function(x:Float) inOnUpdate( inVal0 + x*(inVal1-inVal0) );
         else
            tween.onUpdate = function(x:Float) inOnUpdate( inVal0 + inEasing(x)*(inVal1-inVal0) );
         tween.onUpdate(0);
      }
      tweens.push(tween);
      checkTimer();
   }
}


