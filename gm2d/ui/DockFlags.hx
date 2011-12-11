package gm2d.ui;

class DockFlags
{
   public static inline var RESIZABLE     = 0x0001;
   public static inline var TOOLBAR       = 0x0002;
   public static inline var MINIMIZED     = 0x0004;
   public static inline var MAXIMIZED     = 0x0008;

   public static function isResizeable(i:IDockable) { return (i.getFlags()&RESIZABLE)!=0; }
   public static function isToolbar(i:IDockable) { return (i.getFlags()&TOOLBAR)!=0; }
   public static function isMinimized(i:IDockable) { return (i.getFlags()&MINIMIZED)!=0; }
   public static function isMaximized(i:IDockable) { return (i.getFlags()&MAXIMIZED)!=0; }
   public static function setMinimized(i:IDockable,inVal:Bool)
      { return i.setFlags( inVal ? (i.getFlags()|MINIMIZED) : (i.getFlags() & ~MINIMIZED) ); }
   public static function setMaximised(i:IDockable,inVal:Bool)
      { return i.setFlags( inVal ? (i.getFlags()|MAXIMIZED) : (i.getFlags() & ~MAXIMIZED) ); }
}


