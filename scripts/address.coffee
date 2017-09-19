# Commands:
#   samp-bot <지역명> (주소) - 지역의 주소명을 출력한다.


http = require 'http'
q = require 'q'

module.exports = (robot) ->
  robot.respond /(.*) 주소/i, (msg) ->
    location = decodeURIComponent(unescape(msg.match[1]))
    getAddress(msg, location)
    .then (addressName) ->
        getDust(msg, addressName, location)
    .catch ->
        msg.send '지역 불러오기를 실패하였습니다.'


getAddress = (msg, location) ->
  deferred= q.defer()
  msg.http("https://maps.googleapis.com/maps/api/geocode/json")
    .query({
      address: location
    })
    .get() (err, res, body) ->
      response = JSON.parse(body)
      item = response.results[0].address_components      
      if response.status is "OK"
        addressName = {
          dong : item[0].long_name,
          si   : item[1].long_name,
          do   : item[2].long_name
        }
        deferred.resolve(addressName)
      else
        deferred.reject(err)
  return deferred.promise

getDust = (msg, addressName, location) ->
  msg.send "#{location}의 주소는?"
  msg.send "지역 : #{addressName.dong} #{addressName.si} #{addressName.do}"