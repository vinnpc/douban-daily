MongoClient = require('mongodb').MongoClient

server = require './server'
postsClawer = require './posts-clawer'
columnsClawer = require './columns-clawer'
config = require './config'

MongoClient.connect config.mongoUri, (err, db) ->
  app(db)


app = (db) ->
  server.init db
  server.run()

  postsClawer.init db
  postsClawer.run()

  columnsClawer.init db
  columnsClawer.run()

  clawer.init()
  clawer.run()


clawer =
  oldHour: 0
  oldDate: 0
  checkPeriod: 5 * 60 * 1000 # run clawer.run every 5 minutes

  init: ()->
    date = new Date
    @oldHour = date.getHours()
    @oldDate = date.getDate()

  run: () ->
    now = new Date
    nowHour = now.getHours()
    nowDate = now.getDate()

    # check posts stream data every hour
    if @oldHour != nowHour
      @oldHour = nowHour
      postsClawer.run()

    # # check columns data every day
    if @oldDate != nowDate
      @oldDate = nowDate
      columnsClawer.run()

    setTimeout @run.bind(@), @checkPeriod
