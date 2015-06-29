fs = require 'fs'
Timeline = require 'pebble-api'

prediction_intervals = [1000*3600, 1000*3600*8, 1000*3600*24]

predict = ->
    data = fs.readFileSync 'numinstalls', 'utf8'
    # TODO: Improve extrapolation. Currently uses a simple
    # linear extrapolation from the first to the last timestamp.
    oldest_time = -1
    oldest_data = 0
    newest_time = -1
    newest_data = 0
    for l in data.split '\n'
        if not l
            continue

        d = l.split ' '
        # console.log d
        if +d[0] < oldest_time or oldest_time < 0
            oldest_time = +d[0]
            oldest_data = +d[1]
        if +d[0] > newest_time or newest_time < 0
            newest_time = +d[0]
            newest_data = +d[1]
    
    prediction = {}
    # console.log 'Old:', oldest_time, oldest_data
    # console.log 'New:', newest_time, newest_data
    delta_count = (newest_data - oldest_data) / ((newest_time - oldest_time) * 1000)
    console.log 'Delta:', delta_count
    console.log 'Time until install (hours): ', (1/delta_count) / 1000 / 3600
    for int in prediction_intervals
        console.log 'Interval:', Date.now(), int, Date.now()+int
        next_time = Date.now() + int
        next_data = newest_data + (int/1000) * delta_count
        prediction[next_time] = next_data

    next_install = {}
    next_install[1/delta_count] = newest_data + 1
    return next_install

    console.log 'Predictions:', JSON.stringify prediction
    return prediction

exports.pin_subscribe = (res, token) ->
    res.end()
    fs.readFile 'pin_subscriptions', 'utf8', (err, data) ->
        if err
            console.error 'Error reading subscriptions file:', err
            return 'ERROR'

        subscriptions = data.split '\n'
        console.log 'Current subscriptions', JSON.stringify subscriptions
        known = false
        for s in subscriptions
            console.log 'S: ', s
            if s == token
                known = true

        console.log 'Was known? ', JSON.stringify known
        if not known
            fs.writeFile 'pin_subscriptions', data + '\n' + token, (err) ->
                if err
                    console.error 'Error writing: ' + err
                console.log 'New subscription: ' + token

        exports.pins()

sendpins = ->
    timeline = new Timeline()

    predictions = predict()
    i = 0
    for t, c of predictions
        id = 'predict_' + i
        pin = new Timeline.Pin
            id: id
            time: new Date(t)
            layout:
                type: Timeline.Pin.LayoutType.GENERIC_PIN
                tinyIcon: Timeline.Pin.Icon.PIN
                title: 'Expected: ' + c
                body: c + 'Expected installs for Happening against Humanity'

        fs.readFile 'pin_subscriptions', 'utf8', (err, data) ->
            subscriptions = data.split '\n'
            for s in subscriptions
                if s
                    console.log 'Sending', id, 'to', s
                    timeline.sendUserPin s, pin, (err, body, resp) ->
                        console.log 'Result: ', resp.statusCode

exports.pins = (res) ->
    sendpins()
    if res
        res.end 'Sent'

exports.count = (res) ->
    fs.readFile 'numinstalls', 'utf8', (err, data) ->
        if err
            return 'ERROR'
        
        out = {}
        for l in data.split '\n'
            d = l.split ' '
            out[d[0]] = d[1]

        res.end JSON.stringify out

exports.current = (res) ->
    fs.readFile 'numinstalls', 'utf8', (err, data) ->
        if err
            return 'ERROR'

        newest_time = 0
        newest_data = 0
        for l in data.split '\n'
            d = l.split ' '
            if +d[0] > newest_time
                newest_time = +d[0]
                newest_data = +d[1]

        res.end ''+newest_data

exports.error = (res) ->
    fs.readFile 'errors', 'utf8', (err, data) ->
        res.end data
