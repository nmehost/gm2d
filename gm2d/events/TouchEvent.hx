package gm2d.events;

#if flash
typedef TouchEvent = flash.events.TouchEvent;
#else
typedef TouchEvent = nme.events.TouchEvent;
#end
