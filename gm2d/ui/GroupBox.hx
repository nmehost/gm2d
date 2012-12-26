package gm2d.ui;

import gm2d.ui.Layout;
import gm2d.skin.Skin;
import gm2d.display.BitmapData;
import gm2d.text.TextField;


class GroupBox extends Control
{
   var icon:BitmapData;
   var top:Float;
   var bottom:Float;
   var left:Float;
   var right:Float;
   var title:TextField;
   var tw:Float;
   var topLayout:Layout;

   public function new(inTitle:String, inIcon:BitmapData)
   {
      super();
      icon = inIcon;
      name = inTitle;

      top = 22;
      bottom = 4;
      left = right = 4;

      wantFocus = false;

      cacheAsBitmap = true;

      tw = 0.0;

      if (inTitle!="")
      {
         title = new TextField();
         title.text = inTitle;
         title.x = 2;
         title.y = -20;
         tw = title.textWidth + 4;
         Skin.current.styleLabel(title);
         addChild(title);
      }
   }

   override public function createLayout() : Layout
   {
      var layout = new ChildStackLayout( );
      layout.name = "GroupBox " + (title==null ? "?" : title.text);
      layout.setBorders(left,top,right,bottom);
      var meLayout = new DisplayLayout(this).setOrigin(0,0);
      meLayout.mAlign = Layout.AlignStretch | Layout.AlignPixel;
      layout.add( meLayout );
      return layout;
   }

   public function getItemLayout() : Layout
   {
      return topLayout;
   }

   public function setLayout(inLayout:Layout)
   {
      topLayout = inLayout;
      topLayout.name = "GroupBox contents " + (title==null ? "?" : title.text);
      var layout = getLayout();
      layout.add(inLayout);
      return layout;
   }

   override public function layout(inW:Float,inH:Float):Void
   {
      var gfx = graphics;
      gfx.clear();
      gfx.lineStyle(1,0);
      gfx.beginFill(0xffffff);
      gfx.moveTo(4,-11);
      gfx.lineTo(-2,-11);
      gfx.lineTo(-2,inH + 2);
      gfx.lineTo(inW + 2,inH + 2);
      gfx.lineTo(inW + 2, - 11);
      gfx.endFill();

      gfx.beginFill(0xffffff);
      gfx.drawRoundRect(2,-22,tw,22,5,5);
   }
}

