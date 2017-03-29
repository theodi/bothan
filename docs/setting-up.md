---
layout: default
title: Setting up your own Bothan
hide_in_nav: true
---

Getting started with Bothan is really easy, even if you're not a developer. Each
Bothan instance is hosted separately on the [Heroku](heroku.com) platform. It's free, but you
will need a verified Heroku account.

If you haven't already, get signed up at [signup.heroku.com](https://signup.heroku.com).
Once you're signed up, you'll need to verify your account by going to [your account](https://dashboard.heroku.com/account/billing),
and adding a credit card. Heroku only need this to verify your contact details,
and hosting a standard 'out of the box' Bothan is free for all users.

## Creating your Bothan

Once you've signed up for a Heroku account you can go to the [Get started](https://bothan.io/get-started.html)
page on our website and click the 'Deploy to Heroku' button

![](/images/setting-up/step-1.png){: .screenshot.no-float}

If you're not logged in, you'll be asked to log into your Heroku account. Once you're
logged in, you'll see a screen similar to this:

![](/images/setting-up/step-2.png){: .screenshot.no-float}

Clicking 'allow' will give Bothan the access it needs to set up your Bothan instance
in Heroku. We'll only use it for this, and no other purpose.

Once logged in and authorised, you'll see this screen:

![](/images/setting-up/step-3.png){: .screenshot.no-float}

The first thing you'll be asked for is the title of your app. Choose something
catchy, descriptive and unique.

![](/images/setting-up/step-4.png){: .screenshot.no-float.full-width}

Bothan will suggest a name for your app in the next fied based on the title,
but you can change this. Remember, this must have only lowercase letters,
numbers and dashes as it will form the URL of your Bothan instance (e.g. `http://my-awesome-bothan.herokuapp.com`).
As this name has to be unique, you’ll get a warning if it’s already taken -
don’t worry if it is, you can edit it to make it right.

![](/images/setting-up/step-5.png){: .screenshot.no-float.full-width}

Next, you’ll need to supply a username and password for your Bothan instance.
This is different to your Heroku username and password, and you’ll need this
for when you’re adding metrics, so be sure to write it down, or store it somewhere safe.

![](/images/setting-up/step-6.png){: .screenshot.no-float.full-width}

Next, you can provide a description for your Bothan instance, which will be
displayed on your homepage.

![](/images/setting-up/step-7.png){: .screenshot.no-float.full-width}

Next, fill out the name and website URL of the organisation or individual that
is publishing the data, in the ‘Publisher Name’ and ‘Publisher Website’ fields.

![](/images/setting-up/step-8.png){: .screenshot.no-float.full-width}

If you want to other people to use your data, you can release it as open data.
If you want to do this, select ‘Yes’, and choose a licence, otherwise you can
skip this step:

![](/images/setting-up/step-9.png){: .screenshot.no-float.full-width}

The license options are as follows:

* **Creative Commons Attribution 4.0**

    Choose this license if you want anyone to use your data on the understanding that they credit you or your organisation
* **Creative Commons Attribution Share-Alike 4.0**

    Choose this license if you want anyone to use your data with the same restrictions as above, with the added requirement that anything created using your data is released under the same license
* **CC0 1.0**

    Choose this license if you want anyone to use your data with no restrictions
* **Open Government License 3.0 (United Kingdom)**

    This license is same as Creative Commons Attribution, but created for UK government. Choose this license if the data you are creating is published by a UK national or local government agency
* **Open Data Commons Attribution License 1.0**

    This license is similar to Creative Commons Attribution, but applies specifically to data
* **Open Data Commons Public Domain Dedication and License 1.0**

    This license is similar to CC0, but applies specifically to data

For more information of open data licensing, see the ODI's [guide to open data licensing](https://theodi.org/guides/publishers-guide-open-data-licensing).

Once you are happy with everything you have entered, you can then click ‘deploy’.

There will be a delay of a few minutes, but once the deploy has happened,
you will see a link to view or manage the app:

![](/images/setting-up/step-11.png){: .screenshot.no-float.full-width}

Click on ‘View App’, and you’ll see your Bothan instance in all its glory!
You're now ready to move onto the next step of the guide, which is [adding data](/adding-data.html).
