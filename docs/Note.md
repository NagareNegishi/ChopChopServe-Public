CodeStyle.md:

Append an underscore at the start of private and virtual (abstract/overridden) variables/functions

_ for private variables/functions make sense, but not for virtual functions
If _ indicates, it needs to be overridden
-> when subclass overrides, it must have the same name starting with an underscore, but this method is no longer abstract or need to be overridden

even for private, _ is not actually making it private
