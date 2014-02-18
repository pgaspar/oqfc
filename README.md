This is the source code behind the "[O que falta em Coimbra?](http://oquefaltaemcoimbra.pt/)" concept.
Make sure you check out the [Usage Guidelines](http://oquefaltaemcoimbra.pt/about).

How does it work?
---------------------

* Sinatra app
* Running on Ruby 1.8.7 up to 2.0.0 (and probably higher)

Setup
------

Install Ruby 2.0.0 (if necessary). RVM is optional, but highly recommended.

    rvm install ruby-2.0.0-p353
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

    ruby app.rb

Go to [http://127.0.0.1:4567](http://127.0.0.1:4567)

Customization
-------------

App global settings are available on your `config/config.rb`. Here you can change the city name and background color, among other things.

For the Facebook Comments plugin to work you'll need to:

* [create a Facebook App](https://developers.facebook.com/apps)
* make sure the `:site_url` setting corresponds to the Site URL and App Domains settings on your Facebook App configuration
* set your Facebook App ID in the `:fb_app_id` setting

You may also want to:

* change `public/img/favicon.png` to your own color
* change `public/img/logo.png` (this image is used by Facebook when sharing)
* customize the Facebook sharing text via the `:meta_description` setting

Deployment
-------------

The app is ready for deployment in [Heroku](http://heroku.com). [Troubleshoot here](https://devcenter.heroku.com/articles/rack#sinatra) | [Custom Domains](https://devcenter.heroku.com/articles/custom-domains).

Note: You need to remove the `config/config.rb` line from `.gitignore` so your configuration is sent to Heroku.

Contributing
-------------

Fork, create a topic branch, change the code and create a [Pull Request](https://help.github.com/articles/using-pull-requests). Thanks!
