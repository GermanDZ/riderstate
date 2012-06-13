express = require 'express'
stylus = require 'stylus'
hamlc = require 'haml-coffee'
http = require 'http'
url = require 'url'
__ = require 'underscore'
geohash = require("geohash").GeoHash

port = 2000 #parseInt(process.env.PORT) || 5100

app = express.createServer()

app.configure ->
  app.use express.cookieParser()
  publicDir = "#{__dirname}/public"
  viewsDir  = "#{__dirname}/views"
  coffeeDir = "#{viewsDir}/coffeescript"
  app.set "views", viewsDir
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.compiler(src: coffeeDir, dest: publicDir, enable: ['coffeescript'])
  app.use(stylus.middleware debug: true, src: viewsDir, dest: publicDir, compile: compileMethod)
  app.use express.static(publicDir)

compileMethod = (str, path) ->
  stylus(str)
    .set('filename', path)
    .set('compress', true)


app.configure "development", ->
  app.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )

app.configure "production", ->
  app.use express.errorHandler()

console.log "running at #{port}"

requestToServer = (options) ->
  queryUrl = options.path
  options.method ?= 'GET'
  if options.method == 'GET' and options.data
    queryUrl = url.format
      pathname: queryUrl
      query: options.data
  req = http.request
    host: options.host
    path: queryUrl
  , options.success
  req.on 'error', options.error if typeof options.error == 'function'
  if options.method == 'POST' and options.data
    req.write(JSON.stringify(options.data))
  req.end()

requestJsonToServer = (options) ->
  unWrappedSuccess = options.success
  options.success = (response) ->
    readJsonResponse(response, unWrappedSuccess)
  requestToServer options

readJsonResponse = (response, callback)->
  str = ''
  response.on 'data', (chunk) ->
    str += chunk
  response.on 'end', ->
    callback JSON.parse(str), str, response

hashesFromEndomondo = (str)->
  m = str.match /.*new TrackHighlights\(Wicket.maps\[\'.*\'\],(.*)\);\$\(\'#chart\'\)\.mouseleave/
  m = m[1]
  m2 = m.match /(\[.*?\])/g
  hashes = []
  __.each m2, (latlng)=>
    latlng = latlng.match(/\[(.*),(.*)\]/)
    hashes.push geohash.encodeGeoHash(latlng[1], latlng[2]).substring(0,6)
  __.uniq(hashes).join ' '

app.register '.hamlc', hamlc
app.set('view engine', 'hamlc');

app.get '/', (req, res) ->
  res.render 'welcome', name: 'riderstate'

app.get '/import', (req, res) ->
  workout_id = req.param 'id'
  onResponse = (response, callback)->
    str = ''
    response.on 'data', (chunk) ->
      str += chunk
    response.on 'end', ->
      hashes_str = hashesFromEndomondo(str)
      res.json {response: hashes_str}
  requestToServer
    host: "www.endomondo.com"
    path: "/workouts/#{workout_id}"
    success: onResponse

app.listen port
