SoundJob
=========

Sound job is a set of 2 small ruby scripts in order to download favorites from soundcloud. 

- db_routine.rb : retrieves list of last favorites and stores it into db.json file
- sc_downloader.rb : reads the db.json file and stores streams to local storage

Requirements
---

In order to use soundjob you will need an access to the API. You can register tokens here. Once done you'll just have to copy-paste your tokens into the config.yml file


Install & Use
---

The scripts have been built with ruby-2.1.2 . There's no warranty that the scripts will run on other version of ruby. 

You will also need to install taglib before install its ruby dependencies :

**linux :  **
```apt-get install taglib```

** homebrew : **
```brew install taglib```


** ruby dependencies : **



```sh
gem install soundcloud
gem install json
gem install taglib-ruby
gem install fileutils
```

**clone the repo  :** 

```sh
git clone [git-repo-url] dillinger

```

*** configure it ***

edit & rename the config.sample.yml to config.yml. 

- :dest: represents destination of files
- :max_db: represents maximum favs appending at once on the db.json file
- :max_per_cycle: number of songs to download on a call


tip : max_db can't retrieve more thant 200 favs at once due to soundcloud restrictions. 

** make it a routine **

You might want to create routines invoking the scripts. In order to do so it is recommended you use RVM. If you don't know how to do that here's some useful documentation : 

 - Linux : [Create routines with Cron and RVM](http://rvm.io/integration/cron)
 - Mac OS : [Create routines with launchd and RVM](http://rvm.io/integration/cron)
 - Windows : Suck it up, i don't know how to do that and i don't care


Version
----

0.1

Is this legal ? 
-----------

SoundJob should be considered as having a normal behavior regarding the user licence and developper licence if the script is used for personal purpose only.

The script only downloads the songs available as streams so it does not override any particular protection. 

If it appears that those scripts break any rule of the licences, please feel free to [contact me](mailto:asone@akbarworld.info)


License
----

This software is free and released under GPL v3 licence. Please [read the licence](http://opensource.org/licenses/GPL-3.0) for more information 
