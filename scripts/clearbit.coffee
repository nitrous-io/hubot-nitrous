clearbit = require('clearbit')('b45acf16c98e002eace42175e988fbfc');

# get_company = (domain) ->
#   Company = clearbit.Company
#   promise = Company.find {domain: domain}
#   promise = promise.then (company) ->
#     console.log company
prettyPrintCompany = (data) ->
  return "Company not found" unless data
  return ""

prettyPrintUser = (data) ->
  return "User not found" unless data
  str = "Information of #{data.name.fullName} (*#{data.email}*) from #{data.location}\n"
  str = str + "  Employment: #{data.employment.title} #{data.employment.name}\n" if data.employment and (data.employment.title or data.employment.name)
  str = str + "  Twitter:   http://twitter.com/#{data.twitter.handle}\n" if data.twitter and data.twitter.handle
  str = str + "  Linkedin:  http://linkedin.com/#{data.linkedin.handle}\n" if data.linkedin and data.linkedin.handle
  str = str + "  AngelList: http://angel.co/#{data.angellist.handle}" if data.angellist and data.angellist.handle
  return str

cacheKey = (type, str) ->
  str = str.replace(/[^A-Za-z0-9\.@_\-]/g, '-').toLowerCase()
  return "clearbit:#{type}:#{str}"

module.exports = (robot) ->

  getUserFromClearbit = (email, cb) ->
    Person = clearbit.Person
    promise = Person.find {email: email}
    promise = promise.then (person) ->
      cb person

  getUserInfo = (email, cb) ->
    key = cacheKey 'user', email
    console.log "Getting from cache: email: #{email} key: #{key}"
    user = robot.brain.get key
    console.log "Get from redis: #{user}"
    if user
      cb user
    else
      console.log 'Getting from clearbit'
      getUserFromClearbit email, (user) ->
        console.log "Got from clearbit: #{user}"
        console.log "Storing into cache key: #{key}"
        robot.brain.set key, user
        cb user




  robot.respond /clearbit:user (.+)/, (res) ->
    # TODO: check if res.match[1] is a email
    if res.match and res.match.length > 1
      console.log res.match
      getUserInfo res.match[1], (user) ->
        console.log user
        if user
          res.send prettyPrintUser user
        else
          res.send 'Failed'

#   robot.router.post '/hubot/biz-cave', (req, res) ->
#     room   = req.params.room
#     data   = if req.body.payload? then JSON.parse req.body.payload else req.body
#     secret = data.secret
#     console.log data

#     robot.messageRoom 'bot-cave', "I have a message: #{data}"
#     res.send 'OK'
