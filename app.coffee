http = require 'http'
api = require './api'
url = require 'url'

server = http.createServer (req, res) ->
    console.log('Incoming request')
    request = url.parse(req.url).pathname.substring(1)

    console.log 'Requested: ', request
    if api[request]
        res.writeHead 200
        api[request] res
    else
        console.log 'Unknown function'
        res.writeHead 404
        res.end()

server.listen 3000
