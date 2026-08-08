package gm2d.ui;

import nme.display.BitmapData;
import gm2d.skin.BitmapStyle;

class BitmapButton extends Button
{
   var wasEnabled = true;

   public function new(inSource:BitmapStyle, ?inOnClick:Void->Void, ?inLineage:Array<String>, ?inAttribs:Attribs)
   {
      // Icon resolution/rescale/disabled-transform all live in Button.resolveIcon() now, driven
      // entirely by these attribs - nothing bitmap-specific left to do here beyond keeping
      // mouseEnabled in sync with the disabled state (Control has no generic hook for that).
      var attribs:Attribs = { bitmapStyle:inSource, contents:"icon" };
      if (inAttribs!=null)
         attribs = Widget.addAttribs(attribs, inAttribs);
      super(null, inOnClick, Widget.addLine(inLineage,"BitmapButton"), attribs);
   }

   override function rebuildState(?wasCurrent:Bool)
   {
      if (wasEnabled!=enabled)
      {
         wasEnabled = enabled;
         mouseEnabled = enabled;
      }
      super.rebuildState(wasCurrent);
   }
}
