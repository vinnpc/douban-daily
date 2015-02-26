###
server.coffee
restful api server
###

restify = require 'restify'

db = null
postsCollection = null
columnsCollection = null


init = (_db) ->
  db = _db
  postsCollection = db.collection 'posts'
  columnsCollection = db.collection 'columns'


run = () ->
  server = restify.createServer(name: 'API_Server')

  server.get '/api/columns', getColumns
  server.get '/api/column/:id/posts/:page', getColumnPosts
  server.get '/api/column/:id/posts', getColumnPosts

  server.get '/api/stream/current', getCurrentStream
  server.get '/api/stream/date/:date', getStreamByDate

  # static file index.html
  server.get '/', restify.serveStatic
    directory: './public'
    default: 'index.html'
    
  # static assets
  server.get /\/css|js|images|vendor\/?.*/, restify.serveStatic
    directory: './public'

  server.listen process.env.VCAP_APP_PORT || 8080, () ->
    console.log "#{server.name} is listening #{server.url}"


getColumns = (req, res, next) ->
  columnsCollection.find(id: $ne: 48).toArray (err, docs) ->
    res.send docs
    next()


getColumnPosts = (req, res, next) ->
  count = 10
  columnId = parseInt req.params.id
  page = if req.params.page then parseInt req.params.page else 0

  columnsCollection.findOne id: columnId, (err, doc) ->
    if err || !doc
      errHandle res
      next()
      return

    columnName = doc.name
    postsCollection.find(column: columnName)
      .sort(published_time: -1)
      .skip(page * count)
      .limit(count)
      .toArray (err, docs) ->
        if err || !doc
          errHandle res
        else
          res.send docs
        next()


getCurrentStream = (req, res, next) ->
  postsCollection.find()
    .sort(published_time: -1)
    .limit(1)
    .toArray (err, doc) ->
      if err || !doc.length
        errHandle res
        next()
        return

      lastDate = doc[0].date
      postsCollection.find(date: lastDate)
        .sort(published_time: -1)
        .toArray (err, docs) ->
          if err || !doc
            errHandle res
          else
            res.send docs
          next()


getStreamByDate = (req, res, next) ->
  date = req.params.date
  postsCollection.find(date: date)
    .sort(published_time: -1)
    .toArray (err, docs) ->
      if err || !docs
        errHandle res
        next()
        return

      res.send docs
      next()


errHandle = (res) ->
  res.setHander 'content-type': 'text/plain'
  res.send 'Err...'


module.exports =
  init: init
  run: run
