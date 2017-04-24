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
  msg.send ""
  msg.send "#{location}의 날씨 정보는?"
  msg.http("http://api.openweathermap.org/data/2.5/weather?lat=#{geoCode.lat}&lon=#{geoCode.lng}&units=metric&appid=c557a988de6d87fdd326685a123ac733")
    .get() (err, res, body) ->
      data = JSON.parse(body)
      
      weather = {
          temp : data.main.temp
          humi : getHumi(data.main.humidity)
          stat : getStat(data.weather[0].id) 
          clud : getClud(data.clouds.all)
      }
      msg.send "온도는 #{weather.temp}도로"
      msg.send "습도는 #{weather.humi}편이며"
      msg.send "#{weather.stat} 날씨로"
      msg.send "구름은 #{weather.clud}편입니다"

getHumi = (value) ->
  switch
    when value < 20 then '매우 낮은'
    when value < 40 then '낮은'
    when value < 60 then '보통'
    when value < 80 then '높은'
    else '매우 높은'

getClud = (value) ->
  switch
    when value < 20 then '매우 적은'
    when value < 40 then '적은'
    when value < 60 then '보통'
    when value < 80 then '많은'
    else '매우 많은'

getStat = (value) ->
  switch value
    when 800 then '맑은 하늘의'
    when 801 then '구름이 매우 없는'
    when 300 then '쨍쨍한 햇볕의 이슬비가 내리는'
    else value