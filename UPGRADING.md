# Upgrading Bothan deployments

## 2017-08-16

Changes to dependencies mean that some new system dependencies are required for deployments created before date. `cmake` now must be installed on systems hosting Bothan instances.

### Heroku deployments

If you have deployed using [deploy.bothan.io](https://deploy.bothan.io) or hosted your own instance on Heroku, you will need to make the following manual changes.

* Log in to your Heroku dashboard, and visit the settings page for your Bothan app.
* Press the "upgrade stack" button to use the new `heroku-16` stack instead of `cedar-14`.
* In the buildpacks section, add the following entries:
  * https://github.com/100yrs/heroku-buildpack-cmake.git
  * https://github.com/heroku/heroku-buildpack-google-chrome.git
* Remove the `heroku/ruby` buildpack and re-add it so it is at the BOTTOM of the list.

#### Redeploying

If your app is automatically deploying from a GitHub repository, to apply the updates immediately:
  
* go to the Deploy tab 
* in the manual deploy section deploy the master branch
* your app should now be deployed successfully.

If you are not deploying automatically, follow your normal manual deployment process, and the next deployment will use the new settings and should succeed.