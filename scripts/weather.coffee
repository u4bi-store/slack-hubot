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
  msg.http("http://api.openweathermap.org/data/2.5/weather?lat=#{geoCode.lat}&lon=#{geoCode.lng}&units=metric&appid=c557a988de6d87fdd326685a123ac733")
    .get() (err, res, body) ->
      data = JSON.parse(body)
      
      weather = {
          temp : data.main.temp
          wind : data.wind.speed
          wdeg : data.wind.deg
          humi : data.main.humidity
          clud : data.clouds.all
      }

      msg.send "현재 #{location}의 날씨 정보는?"
      msg.send "기온은 `#{weather.temp}˚`로"
      msg.send "풍향은 `#{getWind(weather.wdeg)}(#{weather.wdeg})`을 향해 풍속 `#{weather.wind}m/s`로 불며"
      msg.send "습도는 `#{getHumi(data.main.humidity)}(#{data.main.humidity}%)`편으로 구름은 `#{getClud(weather.clud)}(#{weather.clud}%)`편입니다."

getHumi = (value) ->
  switch
    when value < 20 then '매우 낮은'
    when value < 40 then '낮은'
    when value < 60 then '평범한'
    when value < 80 then '높은'
    else '매우 높은'

getClud = (value) ->
  switch
    when value < 20 then '매우 적은'
    when value < 40 then '적은'
    when value < 60 then '평범한'
    when value < 80 then '많은'
    else '매우 많은'

getWind = (value) ->
  switch
    when value < 45 then '북동풍'
    when value < 90 then '동풍'
    when value < 145 then '남동풍'
    when value < 180 then '남풍'
    when value < 225 then '남서풍'
    when value < 270 then '서풍'
    when value < 315 then '북서풍'
    when value < 360 then '북풍'