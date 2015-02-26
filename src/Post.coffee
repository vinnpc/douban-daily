###
Post.coffee
Module of Post
###
request = require 'request'
tietuConvert = require './tietuku'

class Post
  @collection: null

  constructor: (@data) ->

  @init: (db) ->
    @collection = db.collection 'posts'

  @getLast: (callback) ->
    Post.collection.find().sort('published_time', -1).limit(1).toArray (err, res) ->
      callback err, res

  save: (callback) ->
    Post.collection.insert @data, (err, result) ->
      callback err, result if callback?

  get: () ->
    return @data

  hasThumbs: () ->
    return @data.thumbs.length > 0

  checkExist: (callback) ->
    Post.collection.findOne id: @data.id, (err, doc) ->
      callback err, !!doc

  # convert the first thumbs small image url to tietuku image url
  convertThumbsAndSave: (callback) ->
    if !@hasThumbs()
      Post.collection.insert @data, (err, result) ->
        callback err, result if callback?
    else
      thumbImg = @data.thumbs[0].small.url

      tietuConvert thumbImg, (err, newImg) =>
        @data.thumbs[0].small.url = newImg

        Post.collection.insert @data, (err, result) ->
          callback err, result if callback?

module.exports = Post
