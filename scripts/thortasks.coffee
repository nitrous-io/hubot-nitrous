# Description:
#   This code executes thortasks from dedicated project
#
# Commands:
#   hubot thortasks list - list thor tasks
#   hubot thortasks update - update local thor tasks from dedicated project. Use carefully
#
# Dependencies:
#   child_process:*
#   lodash: 3.10.0
#
# Notes:
#   help is done in two steps because we want to dinamically do "thor list"

child_process = require 'child_process'
lodash = require 'lodash'

escape_shell = (shell_str) ->
  return shell_str.replace /([\(\);&\|"\s'$`\\])/g, '\\$1'

environments = {
  staging: {
    env: {
      NITROUS_PG_URL: process.env.STAGING_PG_URL
    }
  },
  production: {
    env: {
      NITROUS_PG_URL: process.env.PRODUCTION_PG_URL
    }
  }
}

default_options = {
  env: process.env,
  cwd: process.env.DEDICATED_HOME
}

execute_thor = (cmd, args, options, text, cb) ->
  # cmd should be already filtered by regexp at hubot listener
  command = "bundle exec thor #{escape_shell(cmd)} #{escape_shell(args)}"
  child_process.exec command, lodash.merge(default_options, options), (error, stdout, stderr) ->
    cb "Something went wrong" if error
    cb "```\n#{text}: \n#{stdout}```" if stdout
    cb stderr if stderr

update_thor = (cb) ->
  command = "git pull origin master"
  child_process.exec command, default_options, (error, stdout, stderr) ->
    cb "Something went wrong" if error
    cb "```#{stdout}```" if stdout
    cb stderr if stderr


# Just send thor list as help message
help_thor = (res) ->
  execute_thor "list", "", environments.production, "I'm here to help you", (str) ->
    res.reply str.replace(/thor\ /g, "hubot ")

module.exports = (robot) ->
  robot.respond /([^\ ]+) ([^\ ]+)\ ?(staging|production)?$/, (res) ->
    [_, cmd, args, environment] = res.match
    environment ||= "production"

    execute_thor cmd, args, environments[environment], "Running: `#{cmd} #{args}` on #{environment}" , (str) ->
      res.send(str)

  robot.respond /thortasks list$/, (res) ->
    help_thor res

  robot.respond /thortasks update$/, (res) ->
    update_thor (str) ->
      res.reply str
