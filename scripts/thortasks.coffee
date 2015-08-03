# This code executes thortasks from dedicated project

execute_thor = (cmd, args, env, text, res) ->
  @exec = require('child_process').exec
  dedicated_home = process.env.DEDICATED_HOME
  env_string = ("#{key}=#{value}" for key,value of env).join ' '
  command = "cd #{dedicated_home} && #{env_string} bundle exec thor #{cmd} #{args}"
  @exec command, (error, stdout, stderr) ->
    res.send "Something went wrong" if error
    res.send "```\n#{text}: \n#{stdout}\n```" if stdout
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
  `users:info IDENT [ENV]`: Gets information from a user.\n
     IDENT User's username.\n
     ENV could be staging or production. Default is production\n
  `users:allow_free IDENT ENV]`: Enables free workspaces for a user\n
     IDENT User's username.\n
     ENV could be staging or production. Default is production\n
  "

module.exports = (robot) ->
  robot.hear /@*hubot:* ([^\ ]+) ([^\ ]+)\ ?(staging|production)?$/, (res) ->
    cmd = res.match[1]
    args = res.match[2]
    environment = res.match[3] || "production"

    execute_thor cmd, args, {NITROUS_PG_URL:environments[environment].NITROUS_PG_URL}, "Running: `#{cmd} #{args}` on #{environment}" , res
