phantom = require 'phantom'
timers = require 'timers'

phantom.create (ph) ->
    ph.addCookie
        name: '_ga'
        value: 'GA1.2.1945471573.1433535983'
        domain: 'happening.im'
    console.log ph.cookies
    ph.createPage (page) ->
        console.log page
        page.set 'cookies', [
                name: '_ga'
                value: 'GA1.2.1945471573.1433535983'
            ]
        console.log page.cookies
        page.get 'cookies', (cookies) ->
            console.log 'Actual Cookies', cookies

        page.open "https://www.happening.im", (status) ->
            console.log 'Status', status
            if status == 'success'
                timers.setTimeout ->
                    page.evaluate ->
                        return document.body
                    , (body) ->
                        console.log 'Body', body
                        ph.exit()
                , 3000
