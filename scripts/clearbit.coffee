clearbit = require('clearbit')('b45acf16c98e002eace42175e988fbfc');

prettyPrintCompany = (data) ->
  return "Company not found" unless data
  str = "_Information of_ *#{data.name}* (#{data.url})  - #{data.location} [#{data.phone}]\n"
  tags = data.tags.join(" ") if data.tags
  str = str + "  _Tags_: #{tags}\n" if tags
  str = str + "  _Description_: #{data.description}\n" if data.description
  return str

prettyPrintUser = (data) ->
  return "User not found" unless data
  str = "_Information of_ #{data.name.fullName} (*#{data.email}*) from #{data.location}\n"
  str = str + "  _Employment_: #{data.employment.title} #{data.employment.name}\n" if data.employment and (data.employment.title or data.employment.name)
  str = str + "  _Twitter_:   http://twitter.com/#{data.twitter.handle}\n" if data.twitter and data.twitter.handle
  str = str + "  _Linkedin_:  http://linkedin.com/#{data.linkedin.handle}\n" if data.linkedin and data.linkedin.handle
  str = str + "  _AngelList_: http://angel.co/#{data.angellist.handle}" if data.angellist and data.angellist.handle
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

  # We use domain as as key. This allow us to get the company from the email
  getCompanyFromClearbit = (domain, cb) ->
    Company = clearbit.Company
    promise = Company.find {domain: domain}
    promise = promise.then (company) ->
      cb company

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

  getCompanyInfo = (domain, cb) ->
    key = cacheKey 'company', domain
    console.log "Getting from cache: domain: #{domain} key: #{key}"
    company = robot.brain.get key
    console.log "Get from redis: #{company}"
    if company
      cb company
    else
      console.log 'Getting from clearbit'
      getCompanyFromClearbit domain, (company) ->
        console.log "Got from clearbit: #{company}"
        console.log "Storing into cache key: #{key}"
        robot.brain.set key, company
        cb company

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

  robot.respond /clearbit:company (.+)/, (res) ->
    # TODO: check if res.match[1] is a domain
    if res.match and res.match.length > 1
      # Remove https:// because slack always add it
      domain = res.match[1].replace /https?:\/\//, ''
      getCompanyInfo domain, (company) ->
        console.log company
        if company
          res.send prettyPrintCompany company
        else
          res.send 'Failed'



#   robot.router.post '/hubot/biz-cave', (req, res) ->
#     room   = req.params.room
#     data   = if req.body.payload? then JSON.parse req.body.payload else req.body
#     secret = data.secret
#     console.log data

#     robot.messageRoom 'bot-cave', "I have a message: #{data}"
#     res.send 'OK'
