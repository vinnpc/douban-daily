###
columns-clawer.coffee
claw colums data
###

async = require 'async'
request = require 'request'

mutil = require './mutil'

db = null
collection = null

init = (_db) ->
  db = _db
  collection = db.collection 'columns'

run = () ->
  console.log 'Columns_Clawer Start clawing columns'

  proxy =
    host: '117.146.116.74'
    port: 80
  _request = request.defaults proxy: "http://#{proxy.host}:#{proxy.port}"
  url = 'http://moment.douban.com/api/columns'
  headers =
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:35.0) Gecko/20100101 Firefox/35.0'
    'Content-Type': 'application/x-www-form-urlencoded'

  _request.get
    url: url
    headers: headers,
    (err, response, body) ->
      if err
        mutil.errlog 'Columns', url, err
      else
        columns = (JSON.parse body).columns
        async.map columns, saveColumn, (err, result) ->
          console.log 'Finish columns clawing...'

saveColumn = (column, callback) ->

  collection.findOne id: column.id, (err, doc) ->
    if !!doc
      # exist
      callback null
      return
    else
      collection.insert column, (err, doc) ->
        console.log "Clawed columns: #{column.name}"
        callback null

module.exports =
  init: init
  run: run
