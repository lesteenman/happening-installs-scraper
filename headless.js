var page = require('webpage').create();
var devtools = require('webpage').create();
var fs = require('fs');

/**
 * Sample headless configuration file has been included. Required settings:
 * login_token: The token that's set in localStorage.token on a logged in session
 * my_plugins_page_id: The id of your 'my plugins' page on Happening
 * plugin_id: The id of the plugin you want to scrape installs for
 */

config = JSON.parse(fs.read('headless_conf.json'));

page.settings.userAgent = 'Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.61 Safari/537.36';

var error = '';

devtools.onLoadFinished = function(status) {
    console.log('Devtools page finished loading');
    setTimeout(function() {
        devtools.includeJs("http://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js", function() {
            console.log('Devtools succesfully loaded jquery');
            var numInstalls = devtools.evaluate(function() {
                return $("div.tappable:contains('Log')").length;
            });
            if (numInstalls <= 1) {
                output = '';
                error = 'Warning: Did not get any useful installs';
            } else {
                console.log('Number of installs: ', numInstalls);
                output = Date.now() + ' ' + numInstalls + '\n';
            }
            fs.write('numinstalls', output, 'a');
            fs.write('error.txt', error, 'w');
            devtools.close();
            phantom.exit();
        });
    }, 30000);
};

page.onLoadFinished = function(status) {
    page.evaluate(function() {
        console.log('Token at first: "' + localStorage.getItem('token') + '"');
    });
    setTimeout(function() {
        var body = page.evaluate(function() {
            return document.body;
        });
        var cookies = page.evaluate(function() {
            return document.cookie;
        });
        var loggedIn = page.evaluate(function() {
            var values = {
                'token': 'jfpmhj'
            };
            var isSignup = !document.getElementsByClassName('ui-avatar');
            if (isSignup) {
                console.log('Was not yet logged in.... :(');
                        localStorage.token = config.login_token;
                        return false;
                        } else {
                            console.log('Was already logged in.');
                            return true;
                        }
                        });
                if (!loggedIn) {
                    console.log('Was NOT logged in.');
                    error = 'Was not logged in!';
                    fs.write('error.txt', error, 'w');
                    phantom.exit();
                } else {
                    console.log('Succesfully logged in');
                    devtools.open('https://happening.im/'+config.my_plugins_page_id+'/settings/'+config.plugin_id+'/devtools');
                    page.close();
                }
    }, 5000);
};

page.open('https://www.happening.im');
