package gm2d.ui;

class VerticalLayout extends GridLayout
{
   public function new(?inRowStretch:Array<Float>,inColStretch = 1.0,inName="VLayout")
   {
      super(1,inName);
      if (inRowStretch!=null)
         rowStretch(inRowStretch);
      setColStretch(0,inColStretch);
   }

   override public function toString() return 'VerticalLayout($name)';
}
