package gm2d.ui;

import gm2d.Screen;
import gm2d.Game;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.events.MouseEvent;
import gm2d.ui.Layout;
import nme.display.Bitmap;
import gm2d.skin.Skin;

class PopupMenu extends Window
{
   var mItem:MenuItem;
   var mBar:Menubar;
   var mButtons:Array<Widget>;
   
   public function new(inItem:MenuItem,inBar:Menubar=null)
   {
      super(["PopupMenu"] );

      mItem = inItem;
      mBar = inBar;
      var layout = new GridLayout(3);
      layout.name = "Menu grid";
      mButtons = [];
      var gfx = graphics;
      var c = inItem.children;
      var w = 10.0;
      var ty = 5.0;
      var me=this;

      if (c!=null)
      {
         for(item in c)
         {
            if (item==null)
            {
               layout.add( null );
               layout.add( Widget.createHLine(this, null, { margin:2 } ).getLayout() );
            }
            else
            {
               var id = mButtons.length;
               var but = new TextLabel(item.text,["PopupMenuItem"]);
               but.addEventListener(MouseEvent.CLICK, function(_) {
                  Game.closePopup();
                  if (item.checkable)
                     item.checked = !item.checked;
                  if (item.onSelect!=null)
                     item.onSelect(item);
                  });
               but.addEventListener(MouseEvent.MOUSE_OVER, function(_) me.setItem(id) );
               mButtons.push(but);
               addChild(but);
               if (item.checkable)
               {
                  var checkbox = new CheckButtons(item.checked, item.onSelect==null ? null :
                        function(c) { item.checked = c; item.onSelect(item); }, ["MenuCheckbox"] );
                  addChild(checkbox);
                  layout.add( checkbox.getLayout() );
               }
               else if (item.id!=null)
               {
                  var icon:BitmapData = Skin.getIdAttrib(item.id,"icon");
                  if (icon!=null)
                  {
                     // TODO widget instead
                     var bitmap = new Bitmap(icon);
                     addChild(bitmap);
                     layout.add( new DisplayLayout(bitmap).setPadding(4,4) );
                  }
                  else
                     layout.add( null );
               }
               else
                  layout.add( null );

               layout.add(but.getLayout());

               if (item.shortcut==null)
                  layout.add(null);
               else
               {
                  var text = new TextLabel(item.shortcut,["Shortcut","PopupMenuItem"]);
                  addChild(text);
                  layout.add(text.getLayout());
               }
            }
         }
      }
      setItemLayout(layout);
      build();
      setItem(0);
   }

   public function setItem(inIDX:Int)
   {
      for(b in 0...mButtons.length)
         mButtons[b].isCurrent = inIDX==b;
   }

   public override function destroy()
   {
      super.destroy();
      #if !waxe
      if (mBar!=null) mBar.closeMenu(mItem);
      #end
   }
}
