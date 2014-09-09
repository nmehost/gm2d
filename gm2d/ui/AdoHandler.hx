package gm2d.ui;

import gm2d.Ado;


class AdoHandler<T>
{
   public var ado:Ado;
   public var text:String;
   public var getValue:Void->T;
   public var setValue:Dynamic->T->Void;
   public var getContext:Void->Dynamic;
   public var guiLockout:Int;

   public var updateGui:T->Void;

   public function new(inAdo:Ado, inText:String,
                       inGetValue:Void->T,
                       inSetValue:Dynamic->T->Void,
                       ?inGetContext:Void->Dynamic)
   {
      guiLockout = 0;
      ado = inAdo;
      text= inText;
      getValue = inGetValue;
      setValue = inSetValue;
      getContext = inGetContext;
      
   }

   function updateValue(context:Dynamic, value:T)
   {
      setValue(context,value);

      if (updateGui!=null && guiLockout==0)
      {
         var ctx = getContext==null ? null : getContext();
         if (ctx==context)
            updateGui(value);
      }
   }

   public function finishEdit()
   {
      ado.finishEdit();
   }

   public function onValue(value:T, phase:Int) : Void
   {
      var oldValue = getValue();
      if (oldValue!=value)
      {
         guiLockout++;
         var context = getContext==null ? null : getContext();
         ado.editPhase(text,
                function() updateValue(context,value),
                function() updateValue(context,oldValue),
                phase );
         guiLockout--;
      }
   }



 

}
