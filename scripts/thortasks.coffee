# Description:
#   This code executes thortasks from dedicated project
#
# Commands:
#   hubot thortasks list - list thor tasks
#   hubot thortasks update - update local thor tasks from dedicated project. Use carefully
#
# Dependencies:
#   child_process:*
# 
# Notes:
#   help is done in two steps because we want to dinamically do "thor list"

child_process = require 'child_process'

execute_thor = (cmd, args, env, text, cb) ->
  @exec = child_process.exec
  dedicated_home = process.env.DEDICATED_HOME
  env_string = ("#{key}=#{value}" for key,value of env).join ' '
  command = "cd #{dedicated_home} && #{env_string} bundle exec thor #{cmd} #{args}"
  @exec command, (error, stdout, stderr) ->
    cb "Something went wrong" if error
    cb "```\n#{text}: \n#{stdout}```" if stdout
    cb if stderr

update_thor = (cb) ->
  @exec = child_process.exec
  dedicated_home = process.env.DEDICATED_HOME
  command = "cd #{dedicated_home} && git pull origin master"
  @exec command, (error, stdout, stderr) ->
    cb "Something went wrong" if error
    cb "```#{stdout}```" if stdout
    cb if stderr


environments = {
  staging: {
    NITROUS_PG_URL: process.env.STAGING_PG_URL
  },
  production: {
    NITROUS_PG_URL: process.env.PRODUCTION_PG_URL
  }
}

# Just send thor -t as help message
help_thor = (res) ->
  execute_thor "list", "", {NITROUS_PG_URL:environments.production.NITROUS_PG_URL}, "I'm here to help you", (str) ->
    res.reply str.replace(/thor\ /g, "hubot ")

module.exports = (robot) ->
  robot.respond /([^\ ]+:[^\ ]+) ([^\ ]+)\ ?(staging|production)?$/, (res) ->
    [_, cmd, args, environment] = res.match
    environment ||= "production"

    execute_thor cmd, args, {NITROUS_PG_URL:environments[environment].NITROUS_PG_URL}, "Running: `#{cmd} #{args}` on #{environment}" , (str) ->
      res.send(str)

  robot.respond /thortasks list$/, (res) ->
    help_thor res

  robot.respond /thortasks update$/, (res) ->
    update_thor (str) ->
      res.reply str
