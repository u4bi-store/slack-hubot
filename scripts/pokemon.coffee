http = require 'http'
cronJob = require('cron').CronJob

timeZone = "Asia/Seoul"

mode = {
    call : new Date().getMinutes()+1;
    show : false
}

module.exports = (robot) ->
    init()

    robot.respond /가서물어!$/, (res) ->
        if mode.show is true
            mode.show = false
            res.send '물었다!'
        else
            res.send '누굴 물어'

init = (robot) ->
    new cronJob('0 '+mode.call+' * * * *', sendMessageMethod(robot), null, true, timeZone)

sendMessageMethod = (robot) ->
    -> sendMessage(robot)

sendMessage = (robot) ->
    mode.call += 1

    # TODO : cronJob의 setter는 없나?
    new cronJob('0 '+mode.call+' * * * *', sendMessageMethod(robot), null, true, timeZone)
    
    # robot.messageRoom '#_general', '야생의 포켓몬이 나타났다 잡아라!'
    console.log('야생의 포켓몬이 나타났다 잡아라!');
    mode.show = true

    if mode.call is 60
        mode.call = 1