package gm2d.events;

#if flash
typedef ErrorEvent = flash.events.ErrorEvent;
#else
typedef ErrorEvent = nme.events.ErrorEvent;
#end
