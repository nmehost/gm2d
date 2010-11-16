package gm2d.ui;
import gm2d.geom.Rectangle;


class MDIParent extends Widget
{
   public function new()
	{
	   super();
	}

   override public function layout(inW:Float,inH:Float):Void
	{
	   scrollRect = new Rectangle(0,0,inW,inH);
	   Skin.current.renderMDI(this);
	}

}


