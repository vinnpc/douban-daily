###
tietu-convert.coffee
convert txt image to tietuku image
###

request = require 'request'

mutil = require './mutil'

# Tietuku SDK Config
config =
  accesskey: 'b0ad5f8e3eb9ad3155d79eefccc78dcf3ff06615'
  secretkey: '14dad821fcc5ad407b4b6645bcf79a334a3c42bf'
  albumId: 1031924

# Tietuku SDK
class TietuSdk
  constructor: (@accesskey, @secretkey, @albumId) ->
    @accesskey = @accesskey || config.accesskey
    @secretkey = @secretkey || config.secretkey
    @albumId = @albumId || config.albumId
  Token: () ->
    param =
      deadline: Date.now() + 30000
      album: @albumId
      from: 'web'
      returnBody:
        height: 'h'
        width: 'w'
        ubburl: 'url'
    base64param = @Base64(JSON.stringify(param))
    sign = @Sign(base64param, @secretkey)
    return @accesskey + ':' + sign + ':' + base64param

  Sign: (str, key) ->
    return @Base64(require('crypto').createHmac('sha1', key).update(str).digest())

  Base64: (str) ->
    return new Buffer(str).toString('base64').replace('+','-').replace('/','_')

# convert img url to tietuku img url
tietuConvert = (imgUrl, callback) ->
  tietusdk = new TietuSdk
  token = tietusdk.Token()

  request.post
    headers:
      'content-type': 'application/x-www-form-urlencoded'
    url: 'http://up.tietuku.com/'
    form:
      Token: token
      fileurl: imgUrl,
    (err, response, body) ->
      if err
        callback err
      else
        result = JSON.parse body

        if mutil.exist(result) && mutil.exist(result.url)
          newUrl = result.url.match(/\[img\](.*)\[\/img\]/)[1]
        else
          mutil.errlog "Tietuku #{JSON.stringify(result)} #{imgUrl}"
          console.log "[Tietu Error #{result.code}]: #{imgUrl}"
          newUrl = imgUrl

        callback null, newUrl

module.exports = tietuConvert
