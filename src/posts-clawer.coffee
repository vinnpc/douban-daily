###
posts-clawer.coffee
claw posts data
###

request = require 'request'
async = require 'async'

Post = require './Post'
mutil = require './mutil'

db = null
collection = null


init = (_db) ->
  db = _db
  Post.init db

run = () ->
  console.log 'Clawer start clawing posts...'

  Post.getLast (err, lastData) ->
    if lastData.length == 0
      startDate = '2014-05-12'
    else
      startDate = lastData[0].published_time.slice(0, 10)

    endDate = (new Date).toISOString().slice(0, 10)

    dateList = getDateList(startDate, endDate)

    functionList = [];
    for date in dateList
      ((date)->
        functionList.push (callback) ->
          getDailyPosts(date, callback)
      )(date)

    async.series functionList, (err, result) ->
      console.log 'Finish posts clawing...'


getDateList = (start, end) ->
  res = [start]
  next = start
  nextDate = new Date start
  while next != end
    nextDate = new Date(nextDate.getTime() + 24 * 60 * 60 * 1000)
    next = nextDate.toISOString().slice(0, 10)
    res.push next
  return res


# get json from douban moment server
getDailyPosts = (date, callback) ->
  proxy =
    host: '117.146.116.74'
    port: 80
  _request = request.defaults proxy: "http://#{proxy.host}:#{proxy.port}"
  url = "http://moment.douban.com/api/stream/date/#{date}?v=#{Math.random()}"
  headers =
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:35.0) Gecko/20100101 Firefox/35.0'
    'Content-Type': 'application/x-www-form-urlencoded'

  _request.get
    url: url
    headers: headers,
    (err, response, body) =>
      if err
        mutil.errlog 'Request', url, err
        callback null, err
      else
        dataObj = (JSON.parse body)
        dataList = dataObj.posts
        async.map dataList, handlePost, (err, result) ->
          console.log "Clawed all posts on #{date}"
          callback null, date


handlePost = (data, callback) ->
  post = new Post data
  post.checkExist (err, exist) ->
    if exist
      callback null
      return

    post.convertThumbsAndSave (err)->
      if err
        mutil.errlog 'ConvertAndSave', @id, err
      callback err

module.exports =
  init: init
  run: run
