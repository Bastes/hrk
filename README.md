# Hrk
[![Gem Version](https://badge.fury.io/rb/hrk.svg)](http://badge.fury.io/rb/hrk)
[![Build Status](https://travis-ci.org/Bastes/hrk.svg?branch=master)](https://travis-ci.org/Bastes/hrk)
[![Dependency Status](https://gemnasium.com/Bastes/hrk.svg)](https://gemnasium.com/Bastes/hrk)

Hrk remembers your heroku remotes for you.

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

Hrk 2 swim like a dolphin in a sea of heroku commands

## Getting started

You can install the Hrk gem using the gem command:

```bash
$ gem install hrk
```

Or through bundler:

```ruby
# in your Gemfile
gem 'hrk', group: :development

$ bundle install
```

And enjoy the hrk command awesome power:
```bash
$ hrk logs -r your-heroku-remote-name && hrk run console
```


## What does it do?

It's a command that calls the heroku toolbelt command for you, remembers the
name of the previous remote so you don't have to re-type it again and again
and again each time you want to chain heroku commands.

For example, let's say I've got an heroku app which remote is called:

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
$ export HEROKU_APP=this-app-name-that-is-usually-even-longer-than-the-remote-name && \
  heroku run rake do:something:else && \
  heroku run rake other:thing       && \
  heroku run rake yet:another:task
```

Yup, it works.
Still feels like one command too many.
Still have to remember the names of my apps for each project instead of using my
aptly, conventionnaly named remotes ('test', 'staging', 'prod'...).

Isn't there a better way?

**Hrk to the rescue!**

Hrk remembers the previous remote you've used. So you can do:

```bash
$ hrk -r this-relly-long-remote-name run rake do:some:work && \
  hrk run rake arrange:stuff && \
  hrk run rake test:some:thingy
```

Isn't it more fun?

## Wait, what happens when...

**...I chain hrk commands with other bash commands?**

No worry there, the previous remote will be remembered as long as you don't
close your terminal.

```bash
$ git push demo && \
  hrk -r demo run rake set-this-once && \ # happens on demo
  git push -f demo HEAD^ && \
  hrk restart                             # also on demo
```

**...I chain hrk commands on concurrent terminals for different remotes?**

No worry either, both terminals have their own memory and shouldn't overlap.
Then:

```bash
# on terminal 1
$ hrk -r demo run rake db:migrate && \ # happens on demo
  hrk restart                          # still on demo
# on terminal 2
$ hrk -r prod run rake db:migrate && \ # happens on prod
  hrk restart                          # still on prod
```

**...I set another remote after completing a bunch of commands?**

The last remote set is the one used by default for subsequent commands. So:

```bash
$ hrk -r demo run rake db:migrate && \ # happens on demo
  hrk  restart && \                    # also on demo
  hrk -r prod maintenance:on && \      # happens on prod
  hrk run rake db:migrate && \         # also on prod
  hrk maintenance:off                  # still on prod
```

**...I place the "-r remote" argument at the end of the command, the heroku way**

It just works.

```bash
# this command
$ hrk run console -r demo
# is the same as
$ hrk -r demo run console
```

**...I prefer naming my app instead of the remote?**

You can use either the -r or -a option, either will work as expected and the
latest option will be memorized for subsequent uses.

```bash
$ hrk maintenance:on -a my-super-duper-app && \ # happens on my-super-duper-app
  hrk run console && \                          # again on my-super-duper-app
  hrk maintenance:off                           # aaand on my-super-duper-app
```

**...if I don't chain commands?**

Hrk has been designed to help when chaining commands, but it will remember your
last remote until you close your terminal. So this will work:

```bash
$ hrk logs -r demo
...
$ hrk console # happens on demo
```

This also means you have to be a little careful not to forget on which remote
you are. We are currently planning on adding a little more security there, so
stay tuned.

## Where will it run?

It should run on Linux and MacOSX, provided you've installed ruby.

It might run on Windows, although it hasn't been tested and relies on system
commands that might be different. If you're a windows user and would like to
give it a try, please do send us your issues and / or pull requests to make hrk
run there.

## Do I still need the heroku toolbelt?

Yes. The hrk command calls the heroku command for you, it does not replace it.

## How do I contribute?

In many ways:

**If you're having fun using hrk...**

...you can of course give your feedback and ideas for improvements through
[github issues](https://github.com/Bastes/hrk/issues).

**If you'd like to tweak something...**

Fork the project on the [github page](https://github.com/Bastes/hrk/issues)
and do what you want with it, that's what free software (and github) is for.

If you added something awesome or killed a nasty bug and want everybody to
rejoice, you can send a pull request and it'll be merged (or you'll receive an
explaination why it won't as is).

Pull requests with specs improve their chances to be accepted, so don't shy away
from adding / changing / fixing the specs.

If you'd like to to help on current issues, feel also free to browse them and
attack the ones you'd like to get your hands on. Pull requests that fix issues
are always welcome.

And if you read the code and feel your eyes start to bleed, maybe you can
notify me (preferably after consulting a good eye doctor). Code reviews lead to
better code, and better code makes hrk happy.

## Very important warning!

Hrk is pronounced like "a shark" because it's funny.

## Boring licensing stuff

Hrk is released under the GPL V3 license, and the people rejoiced.

Read more at http://gplv3.fsf.org/
