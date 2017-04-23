# Description:
#   
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

module.exports = (robot) ->

  robot.hear /test/i, (res) ->
    res.send "테스트 테스트"
  
  robot.respond /너는 (.*) 좋아해?/i, (res) ->
    name = res.match[1]
    if name is "명재"
      res.reply "아니! 나는 유명재가 너무 싫어!"
    else
      res.reply "응 #{name} 좋아해"
  
  robot.hear /난 바나나가 좋더라/i, (res) ->
    res.emote "여기 바나나 가져왔어!!"
  
  robot.respond /랜덤과일/i, (res) ->
    lulz = ['사과', '바나나', '파인애플']
    res.send res.random lulz