package gm2d.input;

import gm2d.Screen;
import nme.display.*;

class Input extends Sprite
{
   var screen:Screen;
   var active:Bool;
   var running:Bool;
   var eventStage:Stage;

   public function new()
   {
      super();
      active = false;
      running = false;
   }

   public function layout(w:Int, h:Int)
   {
   }


   public function onUpdated()
   {
   }
 
   public function updateDelta(inDT:Float)
   {
   }

   public function addEventListeners()
   {
   }

   public function removeEventListeners()
   {
   }

   public function setRunning(inRunning:Bool)
   {
      running = inRunning;
   }

   public function onActivate(inScreen:Screen, inActive:Bool)
   {
      screen = inScreen;
      active = inActive;
      if (active)
      {
         eventStage = screen.stage;
         if (eventStage!=null)
            addEventListeners();
      }
      else
      {
         if (eventStage!=null)
            removeEventListeners();
      }
   }
}



