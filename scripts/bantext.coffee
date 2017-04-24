# Commands:
#   (u4bi|하이오) - 금기어를 타이핑할 시 경고 메세지를 보낸다

module.exports = (robot) ->

  robot.hear /(.*)u4bi(.*)|(.*)하이오(.*)$/i, (res) ->
    res.send "금기어를 발설하지마!"
