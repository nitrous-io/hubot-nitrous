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
  if shell_str
    shell_str.replace /([\(\);&\|"'$`\\])/g, '\\$1'
  else
    ""

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

execute_thor = (cmd, options, text, cb) ->
  # cmd should be already filtered by regexp at hubot listener
  command = "bundle exec thor #{escape_shell(cmd)}"
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
  execute_thor "list", environments.production, "I'm here to help you", (str) ->
    res.reply str.replace(/thor\ /g, "hubot tt ")

module.exports = (robot) ->
  robot.respond /thortasks list$/, (res) ->
    help_thor res

  robot.respond /thortasks update$/, (res) ->
    update_thor (str) ->
      res.reply str

  # Note: used the not greedy operator (*?) to avoid recognizing the environment inside the task
  robot.respond /tt (.*?)( (staging|production))?$/, (res) ->
    [_, cmd, _, environment] = res.match
    environment ||= "production" # Default production for thortasks

    execute_thor cmd, environments[environment], "Running: `#{cmd}` on #{environment}" , (str) ->
      res.send(str)
