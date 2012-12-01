timemachine
===========

Apple's Time Machine is one of the simplest backup programs I've ever used.

When I started using Linux, I didn't find anything like that.

So I made this script to do essentially the same thing.

I set it as a cronjab to run hourly. It doesn't copy files, it makes hard links, so each successive backup doesn't really use much space, and any backup set can be deleted  without affecting the others.

Every time it completes a backup it logs which files changed since the previous backup.