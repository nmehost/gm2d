package gm2d.ui;

class HorizontalLayout extends GridLayout
{
   public function new(?inColStretch:Array<Float>,inRowStretch=1.0,inName="HLayout")
   {
      super(null,inName);
      if (inColStretch!=null)
         colStretch(inColStretch);
      setRowStretch(0,inRowStretch);
   }

   override public function toString() return 'HorizontalLayout($name)';
}
