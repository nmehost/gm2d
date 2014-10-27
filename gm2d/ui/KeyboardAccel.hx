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
         switch(part)
         {
            case "Ctrl" : ctrl = true;
            case "Alt" : alt = true;
            case "Shift" : shift = true;
            case "Del" : code = Keyboard.DELETE;
            case "Home" : code = Keyboard.HOME;
            default:
               if (part.length==1)
               {
                  code = part.charCodeAt(0);
               }
               else if (part.substr(0,1)=="F")
               {
                  var func = Std.parseInt(part.substr(1));
                  if (func>0 && func<=15)
                  {
                     code = Keyboard.F1 + func - 1 ;
                  }
                  else
                     throw "Unknown function key" + part;
               }
               else
                 throw "Unknown key specification: " + part;
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


