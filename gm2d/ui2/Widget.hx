package gm2d.ui;

import nme.display.Sprite;
import nme.display.DisplayObject;
import nme.display.Graphics;
import nme.geom.Rectangle;
import nme.text.TextField;
import nme.text.TextFieldAutoSize;

import nme.display.Sprite;
import nme.display.DisplayObjectContainer;
import nme.geom.Point;
import gm2d.ui.Layout;
import gm2d.ui.SkinTitle;

class TitleBar extends Sprite
{
   public var titleField(default,null):TextField;
   public var layout(default,null):Layout;
   var skin:Skin;

   public function new(widgetName:String,className:String, title:String, buttons:Array<String>)
   {
      super();

      skin = Skin.create( className, null, widgetName );

      var titleStyle = skin.getEnumDefault("titleStyle",TITLE_LEFT,SkinTitle);
      var cols = buttons.length;

      var titleLayout:Layout = null;
      if (titleStyle==TITLE_LEFT || titleStyle==TITLE_RIGHT)
      {
         cols++;
         titleField = new TextField();
         titleField.autoSize = TextFieldAutoSize.LEFT;
         titleField.selectable = false;
         titleField.text = title==null ? "" : title;
         skin.styleText(titleField);
         addChild(titleField);
         titleLayout = skin.getTitleLayout(titleField);
      }

      var grid = new GridLayout(cols,"title",0);
      grid.setGap( skin.getScaledFloatDefault("gap",0) );
      if (titleStyle==TITLE_LEFT)
      {
         grid.add(titleLayout);
         grid.setColStretch(0,1);
      }

      for(but in buttons)
      {
         var button = new Button( { id:but}, "TitleBar" );
         addChild(button);
         grid.add( button.widgetLayout );
      }

      if (titleStyle==TITLE_RIGHT)
      {
         grid.add(titleLayout);
         grid.setColStretch(cols-1,1);
      }
      grid.setAlignment( Layout.AlignCenterY );

      layout = new DisplayParentLayout(this);
      layout.setAlignment( Layout.AlignCenterY );
      layout.add(grid);
      skin.setTitleBarLayoutAttribs(layout);

      layout.onLayout = onLayout;
   }

   public function onLayout(inX:Float, inY:Float, inW:Float, inH:Float)
   {
      skin.render(graphics, 0,  0, inW, inH);
      if (titleField!=null)
         skin.styleText(titleField);
   }
}


class Widget extends Sprite implements IWidget
{
   public var wantFocus:Bool;
   public var enabled(get,set):Enabled;
   public var active(get,set):Active;
   public var down(get,set):Bool;
   public var title(default,set):String;
   public var widgetLayout(default,null):DisplayParentLayout;

   var titleField:TextField;
   var titleBar:TitleBar;
   var content:DisplayObject;
   var layX:Float;
   var layY:Float;
   var layW:Float;
   var layH:Float;
   var itemX:Float;
   var itemY:Float;
   var itemW:Float;
   var itemH:Float;
   var laidOut:Bool;
   var skin:Skin;


   public function new( ?attribs : Dynamic, inContext="")
   {
      laidOut = false;
      wantFocus = true;
      layX = layY = layW = layH = 0;
      itemX = itemY = itemW = itemH = 0;
      super();
      skin = Skin.create( getClass(), attribs, inContext );
      name="theWidget";


      var titleLayout:Layout = null;
      title = skin.getTitle();
      var titleStyle = skin.getEnumDefault("titleStyle",TITLE_NONE,SkinTitle);

      switch(titleStyle)
      {
         case TITLE_NONE:
         case TITLE_LEFT, TITLE_RIGHT, TITLE_TOP, TITLE_BOTTOM:
            titleField = new TextField();
            titleField.autoSize = TextFieldAutoSize.LEFT;
            titleField.selectable = false;
            titleField.text = title==null ? "" : title;
            skin.styleText(titleField);
            addChild(titleField);
            titleLayout = skin.getTitleLayout(titleField);

         case TITLE_BAR(className, buttons):
            titleBar = new TitleBar(getClass(), className,title,buttons);
            //titleField= titleBar.titleField;
            addChild(titleBar);
            titleLayout = titleBar.layout;
      }

      var item = skin.getItem();
      var itemLayout:Layout = null;
      if (item!=null)
      {
         addChild(item);
         itemLayout = skin.getItemLayout(item);
      }
      else
         itemLayout = skin.getItemLayout();

      widgetLayout = new DisplayParentLayout(this);

      // get buttons....

      if (titleLayout!=null && itemLayout!=null)
      {
         var grid = new GridLayout( (titleStyle==TITLE_LEFT || titleStyle==TITLE_RIGHT) ? 2 : 1 );
         grid.setGap( skin.getScaledFloatDefault("gap",0) );
         grid.setAlignment(0);

         if (titleStyle==TITLE_RIGHT || titleStyle==TITLE_BOTTOM)
            grid.add(itemLayout).add(titleLayout);
         else
            grid.add(titleLayout).add(itemLayout);

         widgetLayout.add(grid);
      }
      else if (titleLayout!=null)
      {
         widgetLayout.add(titleLayout);
      }
      else if (itemLayout!=null)
      {
         widgetLayout.add(itemLayout);
      }

      if (itemLayout!=null)
         itemLayout.onLayout = onItemLayout;

      skin.setLayoutAttribs(widgetLayout);


      var skinX = skin.getFloatDefault("x",0);
      var skinY = skin.getFloatDefault("y",0);

      var w = widgetLayout.getBestWidth();
      var h = widgetLayout.getBestHeight(w);
      widgetLayout.onLayout = onLayout;
      widgetLayout.setRect(skinX, skinY, w, h);
   }

   public function getPadWidth() { return layW - itemW; }
   public function getPadHeight() { return layH - itemH; }
   public function addPadding(ioSize:Size) : Size
   { 
      ioSize.x += getPadWidth();
      ioSize.y += getPadHeight();
      return ioSize;
   }

   public function getClass() { return "widget"; }

   public function onLayout(inX:Float, inY:Float, inW:Float, inH:Float)
   {
      layX = inX;
      layY = inY;
      layW = inW;
      layH = inH;
      laidOut = true;
      // remove event listener (capture phase)
      render();
   }

   public function onItemLayout(inX:Float, inY:Float, inW:Float, inH:Float)
   {
      itemX = inX;
      itemY = inY;
      itemW = inW;
      itemH = inH;
   }


   function render()
   {
      if (!laidOut)
         return;
      graphics.clear();
      skin.render(graphics, 0,  0, layW, layH);
      if (titleField!=null)
         skin.styleText(titleField);
   }


   function get_enabled():Enabled { return skin.enabled; }
   function set_enabled(value:Enabled):Enabled
   {
      if (value!=skin.enabled)
      {
         skin.enabled = value;
         render();
      }
      return value;
   }
   function get_active():Active { return skin.active; }
   function set_active(value:Active):Active
   {
      if (value!=skin.active)
      {
         skin.active = value;
         render();
      }
      return value;
   }

   function get_down():Bool { return skin.down; }
   function set_down(value:Bool):Bool
   {
      if (value!=skin.down)
      {
         skin.down = value;
         render();
      }
      return value;
   }

   function set_title(value:String):String
   {
      if (value!=title)
      {
         title = value;
         render();
      }
      return title;
   }

   static public function getIWidgetsRecurse(inParent:DisplayObjectContainer,outList : Array<IWidget>)
   {
      if (!inParent.mouseEnabled || !inParent.visible) return;

      for(i in 0...inParent.numChildren)
      {
         var child = inParent.getChildAt(i);
         if (Std.is(child,IWidget))
         {
            var child:IWidget = cast child;
            if (child.wantsFocus())
               outList.push(child);
         }
         if (Std.is(child,DisplayObjectContainer))
           getIWidgetsRecurse(cast child, outList);
      }
   }

   public function wantsFocus() { return wantFocus; }

   public function onKeyDown(event:nme.events.KeyboardEvent ) : Bool { return false; }

   public function activate(inDirection:Int) { }

   public function onCurrentChanged(inCurrent:Bool)
   {
      if (inCurrent)
         active = CURRENT;
      else
         active = DORMANT;
      render();
   }

/*
   public function popup(inPopup:Window,inX:Float,inY:Float,inShadow:Bool=true)
   {
	   var pos = localToGlobal( new Point(inX,inY) );
		gm2d.Game.popup(inPopup,pos.x,pos.y,inShadow);
   }
*/

   public function clearCurrent()
   {
      var p = parent;
      while(p!=null)
      {
         if (Std.is(p,Window))
         {
            var window : Window = cast p;
            window.setCurrentItem(null);
            return;
         }
         p = p.parent;
      }
   }

   public function makeCurrent()
   {
      var p = parent;
      while(p!=null)
      {
         //trace(p);
         if (Std.is(p,Window))
         {
            var window : Window = cast p;
            window.setCurrentItem(this);
            return;
         }
         p = p.parent;
      }
   }
}


