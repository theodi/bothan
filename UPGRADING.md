# Upgrading Bothan deployments

## 2017-08-16

Changes to dependencies mean that some new system dependencies are required for deployments created before date. `cmake` now must be installed on systems hosting Bothan instances.

If you have deployed using [deploy.bothan.io](https://deploy.bothan.io) or hosted your own instance on Heroku, you will need to make the following manual changes.

* Log in to your Heroku dashboard, and visit the settings page for your Bothan app.
* Press the "upgrade stack" button to use the new `heroku-16` stack instead of `cedar-14`.
* In the buildpacks section, add the following entries:
  * https://github.com/100yrs/heroku-buildpack-cmake.git
  * https://github.com/heroku/heroku-buildpack-google-chrome.git
* Remove the `heroku/ruby` buildpack and re-add it so it is at the BOTTOM of the list.
* To apply the updates immediately, go to the Deploy tab and in the manual deploy section, deploy the master branch. You will not need to do this again, future deployments will be automated in the usual way.
* Your app should now be deployed successfully.