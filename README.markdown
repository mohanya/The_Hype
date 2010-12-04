#Handcrafted Bootstrap Rails App

This is a Handcrafted bootstrapped rails app. It runs on rails 2.1.2.

---

##Installation Steps (development)

1.  mkdir Blah
2.  cd Blah
3.  git remote add bootstrap git@github.com:handcrafted/bootstrap.git
4.  git pull bootstrap master
5.  git remote add origin git@github.com:handcrafted/blah.git
6.  Setup config/database.yml
7.  RAILS_ENV=development rake db:create
8.  RAILS_ENV=development rake db:migrate
9.  script/runner -e development lib/data/make_the_site.rb
10. script/runner -e development lib/data/make_email_templates.rb --> Only needed when you aren't re-running make_the_site.rb
11. You always need to run: rake sunspot:solr:start
12. And: rake jobs:work

---

##Plugins

- annotate models
- restful auth
- will paginate
- rspec
- factory girl
- acts as state machine
- delayed job
- thinking sphinx
- sitemap
- paperclip
- newrelic RPM
- hoptoad app
- permalink fu
- haml


##Gems

- ar_mailer
- liquid
- chronic
- vlad (deployment stuff)
- tinder (campfire-vlad notifier)
- htmlentities (tarantula)


##CSS Files


##JS Libraries

- Jquery 1.2.6
- Jquery UI 1.5.2
- Dimensions
- Autocompleter
- Livequery
- CoolInput


test
