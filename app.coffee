http = require 'http'
api = require './api'
url = require 'url'

server = http.createServer (req, res) ->
    console.log('Incoming request')
    request = url.parse(req.url).pathname.substring(1)
    console.log 'Requested: ', request
    console.log 'Full Request: ', JSON.stringify request.split '/'
    args = request.split('/')
    action = args.shift()

    console.log 'Action: ', action
    console.log 'Args: ', JSON.stringify args
    if api[action]
        res.writeHead 200
        args.unshift res
        api[action].apply @, args
    else
        console.log 'Unknown function'
        res.writeHead 404
        res.end()

server.listen 3000
