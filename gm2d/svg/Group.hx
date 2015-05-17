package gm2d.svg;


class Group extends DisplayElement
{
   public var children:Array<DisplayElement>;

   public function new()
   {
      super();
      children = [];
   }

   public function hasGroup(inName:String) { return findGroup(inName)!=null; }
   public function findGroup(inName:String) : Group
   {
      for(child in children)
         if (child.name==inName)
            return child.asGroup();
      return null;
   }

   override public function asGroup() : Group return this;

}

