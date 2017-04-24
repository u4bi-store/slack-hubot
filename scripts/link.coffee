# Commands:
#   samp-bot (깃주소|깃링크) - samp-bot 주인의 깃헙 주소를 출력한다.

module.exports = (robot) ->

  robot.respond /깃주소|깃링크$/, (res) ->
    res.send "https://github.com/u4bi"
