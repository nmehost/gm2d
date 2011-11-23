package gm2d.ui;

import gm2d.ui.Button;

class ProgressDialog extends Dialog
{
   var progress:ProgressBar;

   public function new(inTitle:String, inLabel:String, inMax:Float, ?inOnCancel:Void->Void)
   {
      super(inTitle);

      panel.addLabel(inLabel);
      progress = new ProgressBar(inMax);
      panel.addUI(progress);

      if (inOnCancel!=null)
         panel.addButton( Button.TextButton("Cancel", inOnCancel, true ) );
   }

   public function update(inValue:Float)
   {
      progress.update(inValue);
   }
}
