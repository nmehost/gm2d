package gm2d.svg;


class Group
{
   public function new()
   {
      name = "";
      children = [];
   }

   public var name:String;
   public var children:Array<DisplayElement>;
}

enum DisplayElement
{
   DisplayPath(path:Path);
   DisplayGroup(group:Group);
   DisplayText(text:Text);
}

typedef DisplayElements = Array<DisplayElement>;
