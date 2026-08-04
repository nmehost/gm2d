package gm2d.ui;

class PagedLayout extends StackLayout
{
   public function new()
   {
      super();
   }

   public override function add(inLayout:Layout) : Layout
   {
      var result = super.add(inLayout);
      var display = inLayout.getDisplayObject();
      if (display!=null)
         display.visible = mChildren.length == 1;
      return result;
   }

   public function setPage(inIndex:Int) : Void
   {
      for(c in 0...mChildren.length)
      {
         var display = mChildren[c].getDisplayObject();
         if (display!=null)
            display.visible = inIndex==c;
      }
   }
   override public function toString() return 'PagedLayout($name)';
}
