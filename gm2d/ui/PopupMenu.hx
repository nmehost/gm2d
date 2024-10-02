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
   var mList:ListControl;
   var mRowIdx:Array<Int>;
   
   public function new(?inSkin:Skin, inItem:MenuItem,inBar:Menubar=null)
   {
      super(inSkin, ["PopupMenu"] );

      mItem = inItem;
      mBar = inBar;
      mRowIdx = [];

      mList = new ListControl(["PopupMenuList"]);
      //mList.setColAlign(2, Layout.AlignCenterY | Layout.AlignRight );

      addChild(mList);

      mButtons = [];
      var gfx = graphics;
      var c = inItem.children;
      var w = 10.0;
      var ty = 5.0;
      var me=this;
      var rowCount = 0;


      if (c!=null)
      {
         for(item in c)
         {
            var height:Null<Float> = null;
            var w0:Dynamic = null;
            var w1:Dynamic = null;
            var w2:Dynamic = null;
            if (item==null)
            {
               var widget = Widget.createHLine(this, ["PopupMenuSeparator"] );
               height = widget.attribFloat("rowHeight");
               w1 = widget;
               mList.addRow([w1],height,null,0,true);
            }
            else
            {
               var id = mButtons.length;
               mRowIdx.push(rowCount);
               var but = new TextLabel(item.text,["PopupMenuItem"]);
               but.addEventListener(MouseEvent.CLICK, function(e) {
                  Game.closePopup();
                  if (item.checkable)
                     item.checked = !item.checked;
                  if (item.children!=null && item.children.length>0)
                  {
                     var p = new PopupMenu(inSkin, item);
                     var px = Math.max(0, e.stageX-skin.scale(16));
                     var py = Math.max(0, e.stageY-skin.scale(16));
                     Game.popup(p,px,py);
                  }
                  else if (item.onSelect!=null)
                     item.onSelect(item);
                  });
               but.addEventListener(MouseEvent.MOUSE_OVER, function(_) me.setItem(id) );
               but.applyStyles();
               mButtons.push(but);
               //mList.addChild(but);
               w1 = but;

               if (item.checkable)
               {
                  var checkbox = new CheckButtons(item.checked, item.onSelect==null ? null :
                        function(c) { item.checked = c; item.onSelect(item); }, [item.checkStyle] );
                  checkbox.applyStyles();
                  //mList.addChild(checkbox);
                  w0 = checkbox;
                  //layout.add( checkbox.getLayout() );
               }
               else if (item.icon!=null)
               {
                  var bitmap = new Bitmap(item.icon);
                  //mList.addChild(bitmap);
                  w0 = bitmap;
                  //layout.add( new DisplayLayout(bitmap).setPadding(4,4) );
               }
               else if (item.id!=null)
               {
                  var icon:BitmapData = skin.getIdAttrib(item.id,"icon");
                  if (icon!=null)
                  {
                     // TODO widget instead
                     var bitmap = new Bitmap(icon);
                     //mList.addChild(bitmap);
                     //layout.add( new DisplayLayout(bitmap).setPadding(4,4) );
                     w0 = bitmap;
                  }
                  //else layout.add( null );
               }
               //else layout.add( null );

               //layout.add(but.getLayout());

               if (item.shortcut==null)
               {
                  //layout.add(null);
               }
               else
               {
                  var text = new TextLabel(item.shortcut,["PopupMenuItemShortcut","PopupMenuItem"]);
                  text.applyStyles();
                  //mList.addChild(text);
                  //layout.add(text.getLayout());
                  w2 = text;
               }
               mList.addRow([w0,w1,w2],height);
            }
            rowCount++;
         }
      }
      //setItemLayout(layout);
      setItemLayout(mList.getLayout());
      applyStyles();
      setItem(0);
   }

   public function getSelected()
   {
      return mList.getSelected();
   }

   public function setItem(inIDX:Int)
   {
      mList.select(mRowIdx[inIDX]);
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
