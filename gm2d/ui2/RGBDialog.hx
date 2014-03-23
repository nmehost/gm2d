package gm2d.ui2;

import gm2d.RGBHSV;

class RGBDialog extends Dialog
{
   var control:ColourControl;

   public function new(inRGB:RGBHSV, inOnColour:RGBHSV->Int->Void)
   {
      control = new ColourControl(inRGB, inOnColour);

      var pane = new Pane(control, "Select Colour", Dock.RESIZABLE);
      pane.itemLayout = control.getLayout().setMinSize(300,300);
      super(pane);
   }
   public function setColour(inRGB:RGBHSV)
   {
      control.setColour(inRGB);
   }
}

