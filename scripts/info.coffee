module.exports = (robot) ->
  robot.respond /info$/, (res) ->
    res.reply 'Info could flood the channel, replying you privately'
    robot.emit 'inforequest', { user: res.message.user }

  robot.on 'inforequest', (info) ->
    console.log info
