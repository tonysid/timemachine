timemachine
===========

Makes hourly backups like Apple's Time Machine

On my Macbook Pro there's a backup program that's very useful and so simple to use.

When I started using Linux, I didn't find anything like that.

So I made this script to do essentially the same thing.

Set it as a cronjab to run hourly. It uses rsync to make hard links so each successive backup doesn't really use much space, and any backup seet can be deleted  without affecting the others.
