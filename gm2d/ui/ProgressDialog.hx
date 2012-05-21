package gm2d.ui;

import gm2d.ui.Button;

class ProgressDialog extends Dialog
{
   var progress:ProgressBar;

   function new(inPane:Pane,inProgress:ProgressBar) { super(inPane); progress = inProgress; }

   public static function create(inTitle:String, inLabel:String, inMax:Float, ?inOnCancel:Void->Void)
   {
      var panel = new Panel(inTitle);

      panel.addLabel(inLabel);
      var progress = new ProgressBar(inMax);
      panel.addUI(progress);

      if (inOnCancel!=null)
         panel.addButton( Button.TextButton("Cancel", inOnCancel, true ) );

      return new ProgressDialog(panel.getPane(),progress);
   }


   public function update(inValue:Float)
   {
      progress.update(inValue);
   }
}
