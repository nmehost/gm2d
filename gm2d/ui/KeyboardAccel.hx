package gm2d.ui;
import nme.events.KeyboardEvent;
import nme.ui.Keyboard;

class KeyboardAccel
{
   public var shortcutText:String;
   public var ctrl:Bool;
   public var shift:Bool;
   public var alt:Bool;
   public var code:Int;

   public function new(inShortcut:String)
   {
      shortcutText = inShortcut;
      ctrl = shift = alt = false;
      code = -1;
 
      for(part in inShortcut.split("+"))
      {
         if (part>="0" && part<="9")
             code = part.charCodeAt(0);
         else
            switch(part)
            {
               case "Ctrl" : ctrl = true;
               case "Alt" : alt = true;
               case "Shift" : shift = true;
               case "Del" : code = Keyboard.DELETE;
               default:
                  var upper= part.toUpperCase();
                  var f =  Reflect.field(Keyboard,upper);
                  if (Std.is(f,Int))
                     code = f;
                  else
                     throw "Unknown key : " + part;
            }
      }
      if (code<0)
         throw "No key code specified";
   }

   public function matches(key:KeyboardEvent) : Bool
   {
      return Std.int(key.keyCode)==code && shift==key.shiftKey && alt==key.altKey && ctrl==key.ctrlKey;
   }
}


