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
    request mygenequery, (error, response, body) ->
      if error?
        msg.send "Uh-oh. Something has gone wrong\n#{error}"
      else
        hits = JSON.parse(body)['hits']
        response = ""
        for hit in hits
          response += "ID: #{hit.entrezgene}\nName: #{hit.name}\nSymbol\n#{hit.symbol}\n-----\n"
        msg.send "#{response}"

  robot.respond /get gene position ([0-9]+)/i, (msg) ->
    geneID = msg.match[1]
    mygenequery = 'http://mygene.info/v2/gene/' + geneID + '?fields=genomic_pos_hg19'
    request mygenequery, (error, response, body) ->
      if error?
        msg.send "Uh-oh. Something has gone wrong\n#{error}"
        return
      else
        pos = JSON.parse(body)['genomic_pos_hg19']
        if pos?
          msg.send "chr: #{pos.chr}\nstart: #{pos.start}\nend: #{pos.end}\nstrand: #{pos.strand}"
        else
          msg.send "There doesn't seem to be any position information"

  robot.respond /get gene summary ([0-9]+)/i, (msg) ->
    geneID = msg.match[1]
    mygenequery = 'http://mygene.info/v2/gene/' + geneID + '?fields=summary'
    request mygenequery, (error, response, body) ->
      if error?
        msg.send "Uh-oh. Something has gone wrong\n#{error}"
      else
        summary = JSON.parse(body)['summary']
        if summary?
          msg.send "#{summary}"
        else
          msg.send "There doesn't seem to be a summary for gene #{geneID}"
