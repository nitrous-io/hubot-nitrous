# Description:
#   This code deploys Nitrous code. It just calls jenkins jobs to do the deploy by its own.
#
# Commands:
#   hubot deploy APP [environment]
#
module.exports = (robot) ->

  robot.respond /deploy ([^\ ]+) (staging|production)?$/, (msg) ->
    [_, app, environment] = msg.match
    environment ||= "staging"
    url = process.env.HUBOT_JENKINS_URL
    job = "fastfood-deployer-#{environment}"
    params = "APP=#{app}"
    path = "#{url}/job/#{job}/buildWithParameters?#{params}"

    # monkeypatch the msg.match object
    msg.match[1] = job
    msg.match[3] = params

    req = msg.http(path)

    if process.env.HUBOT_JENKINS_AUTH
      auth = new Buffer(process.env.HUBOT_JENKINS_AUTH).toString('base64')
      req.headers Authorization: "Basic #{auth}"

    req.header('Content-Length', 0)
    req.post() (err, res, body) ->
        if err
          msg.reply "Jenkins says: #{err}"
        else if 200 <= res.statusCode < 400 # Or, not an error code.
          msg.reply "(#{res.statusCode}) Build started for #{job} #{url}/job/#{job}"
        else if 400 == res.statusCode
          jenkinsBuild(msg, true)
        else if 404 == res.statusCode
          msg.reply "Build not found, double check that it exists and is spelt correctly."
        else
          msg.reply "Jenkins says: Status #{res.statusCode} #{body}"
