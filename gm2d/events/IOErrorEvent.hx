package gm2d.events;

#if flash
typedef IOErrorEvent = flash.events.IOErrorEvent;
#else
typedef IOErrorEvent = nme.events.IOErrorEvent;
#end
