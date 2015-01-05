# Hrk

Hrk 2 swim like a dolphin in a sea of heroku commands

```
      ,|
     / ;
    /  \
   : ,'(
   |( `.\
   : \  `\       \.
    \ `.         | `.
     \  `-._     ;   \
      \     ``-.'.. _ `._
       `. `-.            ```-...__
        .'`.        --..          ``-..____
      ,'.-'`,_-._            ((((   <o.   ,'
           `' `-.)``-._-...__````  ____.-'
               ,'    _,'.--,---------'
           _.-' _..-'   ),'
          ``--''        `
```

## Getting started

You can install the Hrk gem using the gem command:

```
$ gem install hrk
```

Or through bundler:

```
# in your Gemfile
gem 'hrk', group: :development

$ bundle install
```

And enjoy the hrk command awesome power:
```
$ hrk your-heroku-remote-name: logs && hrk : run console
```


## What does it do?

It's a command that calls the heroku toolbelt command for you, remembers the
name of the previous remote so you don't have to re-type it again and again
and again each time you want to chain heroku commands.

For example, let's say I've got an heroku app that's called:

> this-really-long-remote-name

Well, I type my heroku commands like:

```bash
$ heroku run rake do:stuff -r this-really-long-remote-name
```

And it's easy.

Yep, but now I want to chain my commands:

```bash
$ heroku run rake do:something:else -r this-really-long-remote-name && \
  heroku run rake other:thing       -r this-really-long-remote-name && \
  heroku run rake yet:another:task  -r this-really-long-remote-name
```

And sometimes you mistype, and the chain breaks in the middle, and it sucks.

**Wait, I can do something like that**

```bash
$ export REMOTE_NAME=this-really-long-remote-name && \
  heroku run rake do:something:else -r $REMOTE_NAME && \
  heroku run rake other:thing       -r $REMOTE_NAME && \
  heroku run rake yet:another:task  -r $REMOTE_NAME
```

Yup. Now It doesn't look really that better now does it?

**Hrk to the rescue!**

Hrk remembers the previous remote you've used. So you can do:

```bash
$ hrk this-relly-long-remote-name: run rake do:some:work && \
  hrk : run rake arrange:stuff && \
  hrk : run rake test:some:thingy
```

Isn't it more fun?

## Wait, what happens when...

**...I chain hrk commands with other bash commands?**

No worry there, the previous remote will be remembered as long as you don't
close your terminal.

```bash
$ git push demo && \
  hrk demo: run rake set-this-once && \ # happens on demo
  git push -f demo HEAD^ && \
  hrk : restart                         # also on demo
```

**...I chain hrk commands on concurrent terminals for different remotes?**

No worry either, both terminals have their own memory and shouldn't overlap.
Then:

```bash
# on terminal 1
$ hrk demo: run rake db:migrate && \ # happens on demo
  hrk : restart                      # still on demo
# on terminal 2
$ hrk prod: run rake db:migrate && \ # happens on prod
  hrk : restart                      # still on prod
```

**...I set another remote after completing a bunch of commands?**

The last remote set is the one used by default for subsequent commands. So:

```bash
$ hrk demo: run rake db:migrate && \ # happens on demo
  hrk : restart && \                 # also on demo
  hrk prod: maintenance:on && \      # happens on prod
  hrk : run rake db:migrate && \     # also on prod
  hrk : maintenance:off              # still on prod
```

## Do I still need the heroku toolbelt?

Yes. The hrk command calls the heroku command for you, it does not replace it.

## Very important warning!

Hrk is pronounced like "a shark" because it's funny.

## Boring licensing stuff

Hrk is released under the GPL V3 license, and the people rejoiced.

Read more at http://gplv3.fsf.org/
