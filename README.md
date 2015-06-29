# Happening Installs Scraper
This is a rough project that can be used to scrape a `my plugins` page on Happening for the number of installs of a certain plugin.

# Why does this exist?
I created this project as a basis for a Pebble app. I needed a way to get the number of installs for a plugin, and to send a prediction of future install numbers to Pebble Timeline.

# Components
## Headless Scraper
headless.js contains a headless scraper that uses PhantomJS to scrape a `my plugins` page for the number of installs. It currently only supports a fixed login token, and one plugin. It can be run using a cronjob to regularly retrieve the current number of installs. The number of installs, along with the time of the scrape, is saved to the `numInstalls` file.

The login token can be retrieved from the developer console in e.g. Chrome or Firefox. Simply log in to Happening in your browser, and retrieve the login token using `localStorage.token`.

## Node App
This is a web API to retrieve scraped information using a Node.js app. app.coffee should be run continuously.

// TODO: Add a list of supported API methods

## Pebble Timeline Push
A simple coffee file that pushes predicted installs (using `api.predict`) to the Pebble Timeline, to all devices registered using `api.register_pin` through the Node app.
