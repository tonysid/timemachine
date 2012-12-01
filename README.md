timemachine
===========

Apple's Time Machine is one of the simplest and most useful backup programs ever made.

When I started using Linux, I didn't find anything like that.

So I made this script to do essentially the same thing.

Set it as a cronjab to run hourly. It uses rsync to make hard links so each successive backup doesn't really use much space, and any backup set can be deleted  without affecting the others.
