package gm2d.ui;

import gm2d.ui.Button;
import gm2d.skin.Skin;


class CheckButtons extends Button
{
   public function new(inValue:Bool, ?inCheck:Bool->Void,?inLineage:Array<String>,?inAttribs:Attribs)
   {
      super(null,inCheck==null ? null : () -> inCheck(down),Widget.addLine(inLineage,"CheckButton"),inAttribs);
      setChecked(inValue);
      //build();
      //getItemLayout().setAlignment(Layout.AlignLeft | Layout.AlignCenterY);
   }

   public function setChecked(inCheck:Bool)
      down = inCheck;



   override public function set(inValue:Dynamic) : Void
   {
      if ( (inValue!=null && inValue!="") )
         setChecked(inValue);
   }

   override public function get(inValue:Dynamic) : Void
   {
      if (Reflect.hasField(inValue,name))
         Reflect.setField(inValue, name, down );
   }


}

