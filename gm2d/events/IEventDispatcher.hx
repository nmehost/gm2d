package gm2d.events;

#if flash
typedef IEventDispatcher = flash.events.IEventDispatcher;
#else
typedef IEventDispatcher = nme.events.IEventDispatcher;
#end
