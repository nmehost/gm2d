package gm2d.events;

#if flash
typedef FocusEvent = flash.events.FocusEvent;
#else
typedef FocusEvent = nme.events.FocusEvent;
#end
