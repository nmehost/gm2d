package gm2d.ui;

import gm2d.ui.Button;

class ProgressDialog extends Dialog
{
   var progress:ProgressBar;
   var statusCtrl:TextLabel;
   var button:Button;

   function new(inPane:Pane,inProgress:ProgressBar, inStatus:TextLabel, inButton:Button)
   {
      super(inPane);
      progress = inProgress;
      statusCtrl = inStatus;
      button = inButton;
   }

   public static function create(inTitle:String, inLabel:String, ?statusText:String, inMax:Float, ?inOnCancel:Void->Void)
   {
      var panel = new Panel(inTitle);

      var status = statusText==null ? null : new TextLabel(statusText);
      if (status!=null)
         panel.addLabelUI("Status", status);

      var progress = new ProgressBar(inMax);
      panel.addLabelUI(inLabel, progress);

      var button:Button = null;
      if (inOnCancel!=null)
         panel.addButton( button = Button.TextButton("Cancel", inOnCancel ) );



      panel.setSizeHint(500);

      return new ProgressDialog(panel.getPane(),progress, status, button);
   }

   public function setStatus(text:String)
   {
      if (statusCtrl!=null)
         statusCtrl.setText(text);
   }

   public function setButton(text:String, ?onClick:Void->Void)
   {
      if (button!=null)
      {
         button.setText(text);
         if (onClick!=null)
            button.mCallback = onClick;
      }
   }

   public function update(inValue:Float)
   {
      progress.update(inValue);
   }
}
