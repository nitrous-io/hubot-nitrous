# Description:
#   This code deploys Nitrous code. It just calls jenkins jobs to do the deploy by its own.
#
# Commands:
#   hubot deploy APP [environment]
#

HELP= """
```
deploy APP [ENVIRONMENT]
Deployment targets
 - nitrous-react   - Webapp of Nitrous.io
 - registry        - Docker registry for Org snapshots of Nitrous.io
 - rise-server     - Api server and deployer of PubStorm
 - rise-apiserver  - Api server and deployer of PubStorm
 - rise-deployer   - Api server and deployer of PubStorm
 - rise-edge       - Nginx lua on each edge of PubStorm
 - rise-redirector - Pubstorm A redirector
 - rise-all        - Deploy all targets of PubStorm
```
"""


deploy = (app, environment, robot, msg) ->
  url = process.env.HUBOT_JENKINS_URL
  job = "fastfood-deployer-#{environment}"
  params = "APP=#{app}"
  path = "#{url}/job/#{job}/buildWithParameters?#{params}"

  req = robot.http(path)

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

module.exports = (robot) ->

  robot.respond /deploy ([^\ ]+)( (staging|production))?$/, (msg) ->
    [_, app, _, environment] = msg.match
    environment ||= "staging"
    console.log "Deploying #{app} to #{environment}"

    if app == "help"
      msg.reply HELP
    else
      deploy app, environment, robot, msg
