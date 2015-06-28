var page = require('webpage').create();
var devtools = require('webpage').create();
var fs = require('fs');

// page.onConsoleMessage = function(msg) {
//     console.log(msg.length, msg);
// };

// console.log('UserAgent', page.settings.userAgent);
page.settings.userAgent = 'Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.61 Safari/537.36';
// console.log('UserAgent', page.settings.userAgent);

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
                        localStorage.token = '6874-fpeaKIq8s190jFgO6ubrvffj3T4_';
                        // Comet.rpc('Client.auth', '6874-fpeaKIq8s190jFgO6ubrvffj3T4_', {
                        //     'agent': "Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.61 Safari/537.36",
                        //     'lang': 'nl'
                        // }, function(response) {
                        //     console.log("GOT A RESPONSE", response);
                        // });
                        return false;
                        } else {
                            console.log('Was already logged in!!! :D');
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
                    devtools.open('https://happening.im/159/settings/r/devtools');
                    page.close();
                }
    }, 5000);
};

page.open('https://www.happening.im');
