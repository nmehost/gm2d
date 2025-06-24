package gm2d.ui;

import gm2d.ui.Button;
import gm2d.skin.ProgressStyle;

class ProgressDialog extends Dialog
{
   var progress:ProgressBar;
   var statusCtrl:TextLabel;
   var button:Button;
   var ipsText:TextLabel;
   var timeText:TextLabel;
   var time0:Float;
   var maxVal:Float;

   function new(inPane:Pane,inProgress:ProgressBar, inStatus:TextLabel, inButton:Button, inMaxVal:Float,inIps:TextLabel, inTime:TextLabel)
   {
      super(inPane);
      progress = inProgress;
      statusCtrl = inStatus;
      button = inButton;
      ipsText = inIps;
      maxVal = inMaxVal;
      timeText = inTime;
      time0 = haxe.Timer.stamp();
   }

   public static function create(inTitle:String, inLabel:String, ?statusText:String, inMax:Float, ?inOnCancel:Void->Void, showTime = false, ?inStyle:ProgressStyle )
   {
      var panel = new Panel(inTitle);

      var status = statusText==null ? null : new TextLabel(statusText);
      if (status!=null)
         panel.addLabelUI("Status", status);

      var attribs:{ } = null;
      if (inStyle!=null)
         attribs = { progressStyle : inStyle }
      var progress = new ProgressBar(inMax, attribs );
      panel.addLabelUI(inLabel, progress);

      var button:Button = null;
      if (inOnCancel!=null)
         panel.addButton( button = Button.TextButton("Cancel", inOnCancel ) );

      var ipsText:TextLabel = null;
      var timeText:TextLabel = null;
      if (showTime)
      {
         if (inMax>1)
         {
            ipsText = new TextLabel("0ms" );
            ipsText.getLayout().stretch();
            panel.addLabelObj("Item Time:",ipsText);
         }

         timeText = new TextLabel("0:0" );
         timeText.getLayout().stretch();
         panel.addLabelObj("Total Time:",timeText);
      }


      panel.setSizeHint(500);

      return new ProgressDialog(panel.getPane(),progress, status, button, inMax, ipsText, timeText);
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

   public static function formatTime(t:Float)
   {
      var sec = Std.int(t);
      if (sec<60)
         return '$sec' + 's';
      var min = Std.int(sec/60);
      sec = sec%60;
      var ssec = sec<10 ? '0' +sec : Std.string(sec);
      if (min<60)
         return '$min:$ssec';
      var hours = Std.int(min/60);
      min = min%60;
      var smin = min<10 ? '0' +min : Std.string(min);

      return '$hours:$smin:$ssec';
   }


   public function update(inValue:Float)
   {
      progress.update(inValue);

      var now = haxe.Timer.stamp();
      var dt = now-time0;
      if (ipsText!=null)
      {
         var ti = dt/Math.max(inValue,1);
         ipsText.setText( Std.int(ti*1000) + "ms" );
      }

      if (timeText!=null)
      {
         var frac = inValue/maxVal;
         if (frac>0)
         {
            var estTime = dt/frac - dt;
            timeText.setText( formatTime(dt) + " : " + formatTime(estTime) );
         }
      }
   }
}
