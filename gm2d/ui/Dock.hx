package gm2d.ui;

class Dock
{
   public static inline var RESIZABLE     = 0x0001;
   public static inline var TOOLBAR       = 0x0002;
   public static inline var MINIMIZED     = 0x0004;
   public static inline var MAXIMIZED     = 0x0008;

   public static inline var DOCK_SLOT_HORIZ = 0;
   public static inline var DOCK_SLOT_VERT  = 1;
   public static inline var DOCK_SLOT_FLOAT = 2;
   public static inline var DOCK_SLOT_MDIMAX = 3;

   public static function isResizeable(i:IDockable) { return (i.getFlags()&RESIZABLE)!=0; }
   public static function isToolbar(i:IDockable) { return (i.getFlags()&TOOLBAR)!=0; }
   public static function isMinimized(i:IDockable) { return (i.getFlags()&MINIMIZED)!=0; }
   public static function isMaximized(i:IDockable) { return (i.getFlags()&MAXIMIZED)!=0; }
   public static function setMinimized(i:IDockable,inVal:Bool)
      { return i.setFlags( inVal ? (i.getFlags()|MINIMIZED) : (i.getFlags() & ~MINIMIZED) ); }
   public static function setMaximised(i:IDockable,inVal:Bool)
      { return i.setFlags( inVal ? (i.getFlags()|MAXIMIZED) : (i.getFlags() & ~MAXIMIZED) ); }


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
         child.setDock(null);
         child.setContainer(null);
      }
   }
   public static function raise(child:IDockable)
   {
      child.getDock().raiseDockable(child);
   }

}
