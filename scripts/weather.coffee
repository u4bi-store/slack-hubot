# Commands:
#   samp-bot <지역명> (날씨정보) - 지역의 날씨정보를 출력한다.


http = require 'http'
q = require 'q'

module.exports = (robot) ->
  robot.respond /(.*) 날씨정보/i, (msg) ->
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
  msg.send "#{location}의 날씨 정보는?"
  msg.http("http://api.openweathermap.org/data/2.5/weather?lat=#{geoCode.lat}&lon=#{geoCode.lng}&units=metric&appid=c557a988de6d87fdd326685a123ac733")
    .get() (err, res, body) ->
      data = JSON.parse(body)
      msg.send "온도 #{data.main.temp}도"
      msg.send "습도 #{data.main.humidity}%"
      msg.send "날씨 #{data.weather[0].id}"
      msg.send "구름 #{data.clouds.all}%"