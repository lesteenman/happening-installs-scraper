fs = require 'fs'

exports.predict = (res) ->
    fs.readFile 'numinstalls', 'utf8', (err, data) ->
        if err
            return 'ERROR'
        
        # TODO: Actually extrapolate ;)
        newest_time = 0
        newest_data = 0
        for l in data.split '\n'
            d = l.split ' '
            if +d[0] > newest_time
                newest_time = +d[0]
                newest_data = +d[1]

        res.end JSON.stringify {newest_time, newest_data}

exports.count = (res) ->
    fs.readFile 'numinstalls', 'utf8', (err, data) ->
        if err
            return 'ERROR'
        
        out = {}
        for l in data.split '\n'
            d = l.split ' '
            out[d[0]] = d[1]

        res.end JSON.stringify out

exports.error = (res) ->
    fs.readFile 'errors', 'utf8', (err, data) ->
        res.end data
