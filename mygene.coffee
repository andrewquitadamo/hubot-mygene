# Commands:
#   hubot find gene <query>  - Returns ID, Name and Symbol of genes matching query
# 
# Dependencies:
#   "request" : "*"
#
# Author:
#   Andrew Quitadamo

request = require 'request'

module.exports = (robot) ->
  robot.respond /find gene ([\w.+\-\*]+)/i, (msg) ->
    query = msg.match[1]
    mygenequery = 'http://mygene.info/v2/query?q=' + query
    msg.send "#{mygenequery}"
    request mygenequery, (error, response, body) ->
      if error?
        msg.send(error)
      else
        hits = JSON.parse(body)['hits']
        res = ""
        for hit in hits
          res += "ID: #{hit.entrezgene}\nName: #{hit.name}\nSymbol\n#{hit.symbol}\n-----\n"
        msg.send "#{res}"
