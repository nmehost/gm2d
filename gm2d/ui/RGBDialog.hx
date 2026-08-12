package gm2d.ui;

import gm2d.RGBHSV;
import gm2d.ui.ColourControl;

class RGBDialog extends Dialog
{
   var control:ColourControl;

   public function new(inRGB:RGBHSV, inOnColour:RGBHSV->Int->Void, swatchSet:SwatchSet)
   {
      control = new ColourControl(inRGB, inOnColour, swatchSet, { padding:10});

      var pane = new Pane(control, "Select Colour", Dock.RESIZABLE );
      super(pane);
   }
   public function setColour(inRGB:RGBHSV)
   {
      control.setColour(inRGB);
   }
}

