package gm2d.ui;

import gm2d.ui.DockPosition;

class Dock
{
   public static inline var RESIZABLE     = 0x0001;
   public static inline var TOOLBAR       = 0x0002;
   public static inline var DONT_DESTROY  = 0x0004;
   public static inline var COLLAPSED     = 0x0008;

   public static inline var DOCK_SLOT_HORIZ = 0;
   public static inline var DOCK_SLOT_VERT  = 1;
   public static inline var DOCK_SLOT_FLOAT = 2;
   public static inline var DOCK_SLOT_DOC   = 3;
   public static inline var DOCK_SLOT_DOCMAX = 4;

   public static function isResizeable(i:IDockable) { return (i.getFlags()&RESIZABLE)!=0; }
   public static function isToolbar(i:IDockable) { return (i.getFlags()&TOOLBAR)!=0; }
   public static function isCollapsed(i:IDockable) { return (i.getFlags()&COLLAPSED)!=0; }
   public static function setCollapsed(i:IDockable,inVal:Bool)
   {
      if (inVal)
         i.setFlags( i.getFlags() | COLLAPSED );
      else
         i.setFlags( i.getFlags() & (0xfffffff -COLLAPSED) );
   }

   public static function remove(child:IDockable)
   {
      var parent = child.getDock();
      if (parent!=null)
      {
         while(true)
         {
            var pp = parent.getDock();
            if (pp==null)
               break;
            parent = pp;
         }
         parent.removeDockable(child);
         child.setDock(null,null);
      }
   }
   public static function raise(child:IDockable) : Bool
   {
      var dock = child.getDock();
      if (dock==null)
      {
         trace("No dock?");
         return false;
      }
      return dock.raiseDockable(child);
   }
   public static function minimize(child:IDockable)
   {
      child.getDock().minimizeDockable(child);
   }


   static function loadChildren(inDockables:Dynamic, panes:Array<Pane>,inDocParent:DocumentParent ):Array<IDockable>
   {
      var children = new Array<IDockable>();
      var dockables:Array<Dynamic> = inDockables;
      if (dockables!=null)
      {
         for(d in dockables)
         {
            var child = loadLayout(d, panes, inDocParent);
            if (child!=null)
               children.push(child);
         }
      }
      return children;
   }

   public static function loadLayout(inInfo:Dynamic, panes:Array<Pane>,inDocParent:DocumentParent ):IDockable
   {
      if (inInfo==null)
         return null;
      switch(inInfo.type)
      {
         case "DocumentParent" :
            if (inInfo!=null)
               inDocParent.loadLayout(inInfo);
            var dockables:Array<Dynamic> = inInfo.dockables;
            var currentTitle:String = inInfo.current==null ? inInfo.current : "";
            var current:Pane = null;
            if (dockables!=null)
               for(d in dockables)
               {
                  var title = d.title;
                  for(pane in panes)
                  if (pane.title==title)
                  {
                     pane.loadLayout(d);
                     inDocParent.addDockable(pane,DOCK_OVER,0);
                     if (title==currentTitle)
                        current = pane;
                     break;
                  }
               }
            if (current!=null)
               inDocParent.raiseDockable(current);
            return inDocParent;

         case "Pane" :
            var title:String = inInfo.title;
            for(pane in panes)
                if (pane.title==title)
                {
                    pane.loadLayout(inInfo);
                    return pane;
                }
            return null;


         case "SideDock" :
            var children = loadChildren(inInfo.dockables,panes,inDocParent);
            if (children.length==0)
               return null;
            if (children.length==1)
               return children[0];
            var horizontal = inInfo.horizontal ? DOCK_LEFT:DOCK_TOP;
            var side = new SideDock(horizontal);
            side.loadLayout(inInfo);
            var idx = 0;
            for(child in children)
               side.addDockable(child,horizontal,idx++);
            return side;

         case "MultiDock" :
            var children = loadChildren(inInfo.dockables,panes,inDocParent);
            if (children.length==0)
               return null;
            if (children.length==1)
               return children[0];
            var multi = new MultiDock();
            multi.loadLayout(inInfo);
            var idx = 0;
            for(child in children)
               multi.addDockable(child,DOCK_OVER,idx++);
            return multi;
      }
      return null;
   }
}
