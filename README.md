# Hrk

Hrk 2 swim like a dolphin in a sea of heroku commands

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
$ hrk your-heroku-remote-name logs
```


## What does it do?

It's a command that calls the heroku toolbelt command for you, using your local
heroku git remote name instead of that app's name.

For example, let's say I've got an heroku app that's called:

> this-really-long-app-name

Well, I type my heroku commands like:

```
$ heroku run rake do:stuff
```

And it's easy.

Yep, but now I need a staging environment and a testing environment, so I add
other heroku repositories that I aptly call:

> this-really-long-app-name-that-is-used-as-a-demo
> this-really-long-app-name-draft

Now all my heroku commands look like:

```
$ heroku run rake do:something:else -a this-really-long-app-name
$ heroku run rake other:thing -a this-really-long-app-name-that-is-used-as-a-demo
$ heroku run rake yet:another:task -a this-really-long-app-name-draft
```

And, let's be frank, that sucks even when I don't have to chain these commands.

**Hrk to the rescue!**

Now, if you're like me, you've probably named your various heroku remotes in a
more sensible way than just your heroku app names, for example:

> prod    => this-really-long-app-name
> staging => this-really-long-app-name-that-is-used-as-a-demo
> test    => this-really-long-app-name-draft

Which means that you could call the Hrk command instead of the heroku command
using your remotes names like:

```
$ hrk prod    run rake do:some:work
$ hrk staging run rake arrange:stuff
$ hrk test    run rake test:some:thingy
```

Easy!

## Do I still need the heroku toolbelt?

Yes. The hrk command calls the heroku command for you, it does not replace it.

## Very important warning!

Hrk is pronounced like "a shark" because it's funny.

## Boring licensing stuff

Hrk is released under the GPL V3 license, and the people rejoiced.

Read more at http://gplv3.fsf.org/
