# Commands:
#   samp-bot <지역명> (날씨정보) - 지역의 날씨정보를 출력한다.


http = require 'http'
moment = require 'moment'
q = require 'q'

module.exports = (robot) ->
  robot.respond /(.*) 일출일몰/i, (msg) ->
    location = decodeURIComponent(unescape(msg.match[1]))
    getGeocode(msg, location)
    .then (geoCode) ->
        getDust(msg, geoCode, location)
    .catch ->
        msg.send '지역 불러오기를 실패하였습니다.'


getGeocode = (msg, location) ->
  deferred= q.defer()
  msg.http("https://maps.googleapis.com/maps/api/geocode/json")
    .query({
      address: location
    })
    .get() (err, res, body) ->
      response = JSON.parse(body)
      geo = response.results[0].geometry.location
      if response.status is "OK"
        geoCode = {
          lat : geo.lat
          lng : geo.lng
        }
        deferred.resolve(geoCode)
      else
        deferred.reject(err)
  return deferred.promise

getDust = (msg, geoCode, location) ->
  msg.http("http://api.openweathermap.org/data/2.5/weather?lat=#{geoCode.lat}&lon=#{geoCode.lng}&units=metric&appid=c557a988de6d87fdd326685a123ac733")
    .get() (err, res, body) ->
      data = JSON.parse(body)
      
      sun = {
          search : moment.unix(data.sys.sunrise).format('MM월 DD일')
          rise : moment.unix(data.sys.sunrise).format('오전 hh시 mm분')
          set : moment.unix(data.sys.sunset).format('오후 hh시 mm분')
      }

      msg.send "금일(#{sun.search}) #{location}의 일출일몰 정보는?"
      msg.send ":city_sunrise:`#{sun.rise}` 해가 뜨며 `#{sun.set}` 해가 저뭅니다:city_sunset:"