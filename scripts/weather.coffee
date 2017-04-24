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
          stat : getStat(data.weather[0].id)
          wind : data.wind.speed
          wdeg : data.wind.deg
          humi : data.main.humidity
          clud : data.clouds.all
      }

      msg.send "현재 #{location}의 날씨 정보는?"
      msg.send "기온은 `#{weather.temp}˚`로 `#{weather.stat}` 날씨로 관측됩니다."
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

getStat = (value) ->
  stats = {
    '200' : 'hunderstorm with light rain'
    '201' : 'thunderstorm with rain'
    '202' : 'thunderstorm with heavy rain'
    '210' : 'light thunderstorm'
    '211' : 'thunderstorm'
    '212' : 'heavy thunderstorm'
    '221' : 'ragged thunderstorm'
    '230' : 'thunderstorm with light drizzle'
    '231' : 'thunderstorm with drizzle'
    '232' : 'thunderstorm with heavy drizzle'
    '300' : 'light intensity drizzle'
    '301' : 'drizzle'
    '302' : 'heavy intensity drizzle'
    '310' : 'light intensity drizzle rain'
    '311' : 'drizzle rain'
    '312' : 'heavy intensity drizzle rain'
    '313' : 'shower rain and drizzle'
    '314' : 'heavy shower rain and drizzle'
    '321' : 'shower drizzle'
    '500' : 'light rain'
    '501' : 'moderate rain'
    '502' : 'heavy intensity rain'
    '503' : 'very heavy rain'
    '504' : 'extreme rain'
    '511' : 'freezing rain'
    '520' : 'light intensity shower rain'
    '521' : 'shower rain'
    '522' : 'heavy intensity shower rain'
    '531' : 'ragged shower rain'
    '600' : 'light snow'
    '601' : 'snow'
    '602' : 'heavy snow'
    '611' : 'sleet'
    '612' : 'shower sleet'
    '615' : 'light rain and snow'
    '616' : 'rain and snow'
    '620' : 'light shower snow'
    '621' : 'shower snow'
    '622' : 'heavy shower snow'
    '701' : 'mist'
    '711' : 'smoke'
    '721' : '안개가 낀 (haze)'
    '731' : 'sand, dust whirls'
    '741' : 'fog'
    '751' : 'sand'
    '761' : 'dust'
    '762' : 'volcanic ash'
    '771' : 'squalls'
    '781' : 'torado'
    '800' : 'clear sky'
    '801' : 'few clouds'
    '802' : '드문드문 구름이 낀 (scattered clouds)'
    '803' : 'broken clouds'
    '804' : 'overcast clouds'
    '900' : 'tornado'
    '901' : 'tropical storm'
    '902' : 'hurricane'
    '903' : 'cold'
    '904' : 'hot'
    '905' : 'windy'
    '906' : 'hail'
    '951' : 'calm'
    '952' : 'light breeze'
    '953' : 'gentle breeze'
    '954' : 'moderate breeze'
    '955' : 'fresh breeze'
    '956' : 'strong breeze'
    '957' : 'high wind, near gale'
    '958' : 'gale'
    '959' : 'severe gale'
    '960' : 'storm'
    '961' : 'violent storm'
    '962' : 'hurricane'
  }
  stats[value]
