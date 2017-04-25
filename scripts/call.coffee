http = require 'http'
cronJob = require('cron').CronJob

timeZone = "Asia/Seoul"

callTime = new Date().getMinutes()+1;

module.exports = (robot) ->
    init()

init = (robot) ->
    new cronJob('0 '+callTime+' 14 * * *', sendMessageMethod(robot), null, true, timeZone)

sendMessageMethod = (robot) ->
    -> sendMessage(robot)

sendMessage = (robot) ->
    callTime += 1

    # TODO : cronJob의 setter는 없나?
    new cronJob('0 '+callTime+' 14 * * *', sendMessageMethod(robot), null, true, timeZone)
    console.log('다음 콜은? '+callTime);