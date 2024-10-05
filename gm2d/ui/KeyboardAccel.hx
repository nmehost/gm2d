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
         if (part.length>1 && part.substr(0,1)=="F")
         {
            code = Std.parseInt( part.substr(1) ) + 111;
         }
         else if (part>="0" && part<="9")
         {
            code = part.charCodeAt(0);
         }
         else
            switch(part)
            {
               case "Ctrl" : ctrl = true;
               case "Alt" : alt = true;
               case "Shift" : shift = true;
               case "Del" : code = Keyboard.DELETE;
               case "Insert" : code = Keyboard.INSERT;
               case "PgUp" : code = Keyboard.PAGE_UP;
               case "PgDn" : code = Keyboard.PAGE_DOWN;
               case "Enter" : code = Keyboard.ENTER;
               case "End" : code = Keyboard.END;
               case "Home" : code = Keyboard.HOME;
               case "=" : code = Keyboard.EQUAL;
               case "Down" : code = Keyboard.DOWN;
               case "Up" : code = Keyboard.UP;
               case "Left" : code = Keyboard.LEFT;
               case "Right" : code = Keyboard.RIGHT;
               case "-" : code = Keyboard.MINUS;
               case "`" : code = Keyboard.BACKQUOTE;
               case "," : code = Keyboard.COMMA;
               case ";" : code = Keyboard.SEMICOLON;
               case "(" : code = Keyboard.LEFTBRACKET;
               case ")" : code = Keyboard.RIGHTBRACKET;
               case "." : code = Keyboard.PERIOD;
               case "[" : code = 219;
               case "]" : code = 221;
               default:
                  var upper= part.toUpperCase();
                  if (upper.charCodeAt(0)>='A'.code && upper.charCodeAt(0)<='Z'.code)
                     code = upper.charCodeAt(0);
                  else
                  {
                     var f =  Reflect.field(Keyboard,upper);
                     if (Std.isOfType(f,Int))
                     {
                        code = f;
                     }
                     else
                     {
                        //throw "Unknown key : " + part;
                        trace("Unknown key : ");
                     }
                  }
            }
      }
      if (code<0)
         throw "No key code specified";
   }

   public function matches(key:KeyboardEvent) : Bool
   {
      var match =  (Std.int(key.keyCode)==code || (code==Keyboard.DELETE && key.keyCode==8) )
                      && shift==key.shiftKey && alt==key.altKey && ctrl==key.ctrlKey;
      return match;
      // return Std.int(key.keyCode)==code && shift==key.shiftKey && alt==key.altKey && ctrl==key.ctrlKey;
   }

   public function toString()
   {
      return 'KeyboardAccel($shortcutText,$code,$shift,$alt,$ctrl)';
   }
}


