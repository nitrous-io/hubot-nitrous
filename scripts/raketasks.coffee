# This code executes raketasks from dedicated project

execute_rake = (task, env, text, res) ->
  @exec = require('child_process').exec
  dedicated_home = process.env.DEDICATED_HOME
  env_string = ("#{key}=#{value}" for key,value of env).join ' '
  command = "cd #{dedicated_home} && #{env_string} bundle exec rake #{task}"
  @exec command, (error, stdout, stderr) ->
    res.send "Something went wrong" if error
    res.send "#{text}: \n#{stdout}" if stdout
    res.send stderr if stderr


environments = {
  staging: {
    NITROUS_PG_URL: process.env.STAGING_PG_URL
  },
  production: {
    NITROUS_PG_URL: process.env.PRODUCTION_PG_URL
  }
}


help = () ->
  return "\
  `users:info ARG [ENV]`: Gets information from a user.\n
     ARG User's username.\n
     ENV could be staging or production. Default is production\n
  `users:allow_free ARG [ENV]`: Enables free workspaces for a user\n
     ARG User's username.\n
     ENV could be staging or production. Default is production\n
  "

module.exports = (robot) ->

  robot.hear /hubot users:info ([^\ ]+)\ ?([^\ ]+)?/, (res) ->
    arg = res.match[1]
    environment = res.match[2] or "production"

    if environment not in ['staging','production']
      res.reply "syntax: users:info USER ENVIRONMENT"
      res.reply " ENV: staging or production"
    else
      execute_rake "users:info", {USER_USERNAME: arg, NITROUS_PG_URL:environments[environment].NITROUS_PG_URL}, "The information of the user \"#{arg}\"" , res


  robot.hear /hubot users:allow_free ([^\ ]+)\ ?([^\ ]+)?/, (res) ->
    arg = res.match[1]
    environment = res.match[2] or "production"

    if environment not in ['staging','production']
      res.reply "syntax: allow_free:info USER ENVIRONMENT"
      res.reply " ENV: staging or production"
    else
      execute_rake "users:allow_free", {USER_USERNAME: arg, NITROUS_PG_URL:environments[environment].NITROUS_PG_URL}, "The information of the user \"#{arg}\"" , res


  robot.on 'inforequest', (user) ->
    robot.send user.name, help()
