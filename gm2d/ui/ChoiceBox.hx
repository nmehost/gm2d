package gm2d.ui;

class ChoiceBox extends ComboBox
{
   public function new(inVal="", ?inOptions:Array<String>, ?inDisplay:Array<Dynamic>,
       ?inOnSelectIndex:Int->Void, ?inOnSelectString:String->Void, ?inLineage:Array<String>, ?inAttribs:{})
   {
      super(inVal, inOptions, inDisplay, inOnSelectIndex, inOnSelectString, Widget.addLine(inLineage,"ChoiceBox"), inAttribs );
   }
}


