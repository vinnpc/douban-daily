###
  mutil.coffee
  my utilities
###

fs = require 'fs'

mutil =
  errlog: (type, content) ->
    path = 'err.log'
    time = (new Date).toISOString()
    fs.appendFile path, "#{time} [#{type}] #{content}\n"

  nextDay: (day) ->
    new Date(day.getTime() + 24 * 60 * 60 * 1000)

  exist: (target) ->
    return target != null && typeof target != 'undefined'

module.exports = mutil
