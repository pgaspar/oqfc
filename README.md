This is the source code behind the "[O que falta em Coimbra?](http://oquefaltaemcoimbra.pt/)" concept.
Make sure you check out the [Usage Guidelines](http://oquefaltaemcoimbra.pt/about).

How does it work?
---------------------

* Sinatra app
* Running on Ruby 1.8.7-p371 (and up, probably)

Setup
------

Install Ruby 1.8.7 (if necessary). RVM is optional, but highly recommended

    rvm install ruby-1.8.7-p371
    git clone https://github.com/pgaspar/oqfc.git
    cd oqfc

Install bundler

    gem install bundler

Install the gems

    bundle install --without production

Configure the app

* duplicate `config/config.rb.example`
* rename it to `config.rb`
* open it and change the necessary settings

Run the server

    ruby -r app.rb

Go to [http://127.0.0.1:4567](http://127.0.0.1:4567)

Deployment
-------------

The app is ready for deployment in [Heroku](http://heroku.com). [Troubleshoot here](https://devcenter.heroku.com/articles/rack#sinatra).
