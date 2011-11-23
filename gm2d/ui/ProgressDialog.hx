package gm2d.ui;

import gm2d.ui.Button;

class ProgressDialog extends Dialog
{
   //var progress:ProgressBar;

   public function new(inTitle:String, inLabel:String, inMax:Float)
   {
      super(inTitle);

      panel.addLabel(inLabel);
      //var progress = new ProgressBar(inMax);
      //panel.addUI(new gm2d.ui.ProgressPar(inMax) );

      mPanel.addButton( Button.TextButton("Cancel", function() trace("Cancel!"), true ) );

   }
}
