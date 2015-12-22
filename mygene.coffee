# Commands:
#   hubot find gene <query> - Returns ID, Name and Symbol of genes matching query
#   hubot get gene position <gene ID> - Returns genomic position for gene ID. Position in HG19. 
#   hubot get gene summary <gene ID> - Returns summary of gene
#   hubot get ensembl gene <gene ID> - Returns Ensembl gene ID for gene
#   hubot get ensembl transcripts <gene ID> - Returns Ensembl transcript IDs for gene
#   hubot get ensembl proteins <gene ID> - Return Ensembl protein IDs for gene
#   hubot get refseq genomic <gene ID> - Returns RefSeq gene IDs for gene
#   hubot get refseq rna <gene ID> - Returns RefSeq rna IDs for gene
#   hubot get refseq protein <gene ID> - Returns RefSeq protein IDs for gene
#   hubot get pdb <gene ID> - Returns PDB entries for gene
#   hubot get pfam <gene ID> - Returns PFAM entries for gene 
#   hubot get kegg <gene ID> - Returns KEGG entries for gene
#   hubot get map location <gene ID> - Returns chromosomal map location for gene
#   hubot get hprd <gene ID> - Returns Human Protein Reference Database entry for gene
#   hubot get hgnc <gene ID> - Returns HUGO Gene Nomenclature Committee entry for gene
#   hubot get alias <gene ID> - Returns aliases for gene
#   hubot get homologene <gene ID> - Returns HomoloGene entry for gene
#   hubot get interpro <gene ID> - Returns InterPro entries for gene
#   hubot get omim <gene ID> - Returns OMIM entry for gene
#   hubot get wikipathways <gene ID> - Returns wikipathway entries for gene
#   hubot get reactome <gene ID> - Returns Reactome entries for gene
#
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

  pattern = new RegExp('get gene refs ([0-9]+)' +
                       "(?: from ([0-9]+))?" +
                       "(?: to ([0-9]+))?", 'i')
  robot.respond pattern, (msg) ->
    geneID = msg.match[1]
    start = msg.match[2]
    end = msg.match[3]
    mygenequery = 'http://mygene.info/v2/gene/' + geneID + '?fields=generif'
    request mygenequery, (error, response, body) ->
      if error?
        msg.send "Uh-oh. Something has gone wrong\n#{error}"
      else
        refs = JSON.parse(body)['generif']
        refLength = refs.length
        if start? and end?
          if end-start > 100
            msg.send "Woah, slow down there partner. Try a range less than 100"
            return
          results = refs.slice(parseInt(start)-1,parseInt(end))
          response = ""
          for ref in results 
            response += "#{ref.text}+\nhttp://www.ncbi.nlm.nih.gov/pubmed/#{ref.pubmed}\n\n"
          msg.send "#{response}" 
        else
          msg.send "10 of #{refLength} references"
          firstTen = refs.slice(0,10)
          response = ""
          for ref in firstTen
            response += "#{ref.text}+\nhttp://www.ncbi.nlm.nih.gov/pubmed/#{ref.pubmed}\n\n"
          msg.send "#{response}"

  robot.respond /get ensembl transcripts ([0-9]+)/i, (msg) ->
    geneID = msg.match[1]
    mygenequery = 'http://mygene.info/v2/gene/' + geneID + '?fields=ensembl.transcript'
    request mygenequery, (error, response, body) ->
      if error?
        msg.send "Uh-oh. Something has gone wrong\n#{error}"
      else
        transcripts = JSON.parse(body)['ensembl.transcript']
        response = ""
        for transcript in transcripts
          response += "#{transcript}\thttp://www.ensembl.org/Homo_sapiens/Transcript/Summary?t=#{transcript}\n"
        msg.send "#{response}"

  robot.respond /get ensembl gene ([0-9]+)/i, (msg) ->
    geneID = msg.match[1]
    mygenequery = 'http://mygene.info/v2/gene/' + geneID + '?fields=ensembl.gene'
    request mygenequery, (error, response, body) ->
      if error?
        msg.send "Uh-oh. Something has gone wrong\n#{error}"
      else
        gene = JSON.parse(body)['ensembl.gene']
        msg.send "#{gene}\thttp://www.ensembl.org/Homo_sapiens/Gene/Summary?g=#{gene}"

  robot.respond /get ensembl proteins ([0-9]+)/i, (msg) ->
    geneID = msg.match[1]
    mygenequery = 'http://mygene.info/v2/gene/' + geneID + '?fields=ensembl.protein'
    request mygenequery, (error, response, body) ->
      if error?
        msg.send "Uh-oh. Something has gone wrong\n#{error}"
      else
        proteins = JSON.parse(body)['ensembl.protein']
        response = ""
        for protein in proteins
          response += "#{protein}\n"
        msg.send "#{response}"

  robot.respond /get refseq rna ([0-9]+)/i, (msg) ->
    geneID = msg.match[1]
    mygenequery = 'http://mygene.info/v2/gene/' + geneID + '?fields=refseq.rna'
    request mygenequery, (error, response, body) ->
      if error?
        msg.send "Uh-oh. Something has gone wrong\n#{error}"
      else
        ids = JSON.parse(body)['refseq.rna']
        response = ""
        for id in ids
          response += "#{id}\thttp://www.ncbi.nlm.nih.gov/nuccore/#{id}\n"
        msg.send "#{response}"

  robot.respond /get refseq genomic ([0-9]+)/i, (msg) ->
    geneID = msg.match[1]
    mygenequery = 'http://mygene.info/v2/gene/' + geneID + '?fields=refseq.genomic'
    request mygenequery, (error, response, body) ->
      if error?
        msg.send "Uh-oh. Something has gone wrong\n#{error}"
      else
        ids = JSON.parse(body)['refseq.genomic']
        response = ""
        for id in ids
          response += "#{id}\thttp://www.ncbi.nlm.nih.gov/nuccore/#{id}\n"
        msg.send "#{response}"

  robot.respond /get refseq protein ([0-9]+)/i, (msg) ->
    geneID = msg.match[1]
    mygenequery = 'http://mygene.info/v2/gene/' + geneID + '?fields=refseq.protein'
    request mygenequery, (error, response, body) ->
      if error?
        msg.send "Uh-oh. Something has gone wrong\n#{error}"
      else
        ids = JSON.parse(body)['refseq.protein']
        response = ""
        for id in ids
          response += "#{id}\thttp://www.ncbi.nlm.nih.gov/protein/#{id}\n"
        msg.send "#{response}"

  robot.respond /get pdb ([0-9]+)/i, (msg) ->
    geneID = msg.match[1]
    mygenequery = 'http://mygene.info/v2/gene/' + geneID + '?fields=pdb'
    request mygenequery, (error, response, body) ->
      if error?
        msg.send "Uh-oh. Something has gone wrong\n#{error}"
      else
        ids = JSON.parse(body)['pdb']
        response = ""
        for id in ids
          response += "#{id}\thttp://www.rcsb.org/pdb/explore.do?structureId=#{id}\n"
        msg.send "#{response}"

  robot.respond /get pfam ([0-9]+)/i, (msg) ->
    geneID = msg.match[1]
    mygenequery = 'http://mygene.info/v2/gene/' + geneID + '?fields=pfam'
    request mygenequery, (error, response, body) ->
      if error?
        msg.send "Uh-oh. Something has gone wrong\n#{error}"
      else
        ids = JSON.parse(body)['pfam']
        response = ""
        for id in ids
          response += "#{id}\thttp://pfam.xfam.org/family/#{id}\n"
        msg.send "#{response}"

  robot.respond /get kegg ([0-9]+)/i, (msg) ->
    geneID = msg.match[1]
    mygenequery = 'http://mygene.info/v2/gene/' + geneID + '?fields=pathway.kegg'
    request mygenequery, (error, response, body) ->
      if error?
        msg.send "Uh-oh. Something has gone wrong\n#{error}"
      else
        ids = JSON.parse(body)['pathway.kegg']
        response = ""
        for id in ids
          response += "#{id.name}\thttp://www.genome.jp/dbget-bin/www_bget?#{id.id}\n"
        msg.send "#{response}"

  robot.respond /get map location ([0-9]+)/i, (msg) ->
    geneID = msg.match[1]
    mygenequery = 'http://mygene.info/v2/gene/' + geneID + '?fields=map_location'
    request mygenequery, (error, response, body) ->
      if error?
        msg.send "Uh-oh. Something has gone wrong\n#{error}"
      else
        id = JSON.parse(body)['map_location']
        msg.send "#{id}"

  robot.respond /get hprd ([0-9]+)/i, (msg) ->
    geneID = msg.match[1]
    mygenequery = 'http://mygene.info/v2/gene/' + geneID + '?fields=HPRD'
    request mygenequery, (error, response, body) ->
      if error?
        msg.send "Uh-oh. Something has gone wrong\n#{error}"
      else
        id = JSON.parse(body)['HPRD']
        msg.send "#{id}\twww.hprd.org/protein/#{id}"

  robot.respond /get hgnc ([0-9]+)/i, (msg) ->
    geneID = msg.match[1]
    mygenequery = 'http://mygene.info/v2/gene/' + geneID + '?fields=HGNC'
    request mygenequery, (error, response, body) ->
      if error?
        msg.send "Uh-oh. Something has gone wrong\n#{error}"
      else
        id = JSON.parse(body)['HGNC']
        msg.send "#{id}\thttp://www.genenames.org/cgi-bin/gene_symbol_report?hgnc_id=#{id}"

  robot.respond /get alias ([0-9]+)/i, (msg) ->
    geneID = msg.match[1]
    mygenequery = 'http://mygene.info/v2/gene/' + geneID + '?fields=alias'
    request mygenequery, (error, response, body) ->
      if error?
        msg.send "Uh-oh. Something has gone wrong\n#{error}"
      else
        ids = JSON.parse(body)['alias']
        response = ""
        for id in ids
          response += "#{id}\n"
        msg.send "#{response}"

  robot.respond /get homologene ([0-9]+)/i, (msg) ->
    geneID = msg.match[1]
    mygenequery = 'http://mygene.info/v2/gene/' + geneID + '?fields=homologene'
    request mygenequery, (error, response, body) ->
      if error?
        msg.send "Uh-oh. Something has gone wrong\n#{error}"
      else
        id = JSON.parse(body)['homologene']
        msg.send "#{id.id}\thttp://www.ncbi.nlm.nih.gov/homologene/#{id.id}"

  robot.respond /get interpro ([0-9]+)/i, (msg) ->
    geneID = msg.match[1]
    mygenequery = 'http://mygene.info/v2/gene/' + geneID + '?fields=interpro'
    request mygenequery, (error, response, body) ->
      if error?
        msg.send "Uh-oh. Something has gone wrong\n#{error}"
      else
        ids = JSON.parse(body)['interpro']
        response = ""
        for id in ids
          response += "#{id.desc}\thttp://www.ebi.ac.uk/interpro/entry/#{id.id}\n"
        msg.send "#{response}"

  robot.respond /get omim ([0-9]+)/i, (msg) ->
    geneID = msg.match[1]
    mygenequery = 'http://mygene.info/v2/gene/' + geneID + '?fields=MIM'
    request mygenequery, (error, response, body) ->
      if error?
        msg.send "Uh-oh. Something has gone wrong\n#{error}"
      else
        id = JSON.parse(body)['MIM']
        msg.send "#{id}\thttp://www.omim.org/entry/#{id}"

  robot.respond /get wikipathways ([0-9]+)/i, (msg) ->
    geneID = msg.match[1]
    mygenequery = 'http://mygene.info/v2/gene/' + geneID + '?fields=pathway.wikipathways'
    request mygenequery, (error, response, body) ->
      if error?
        msg.send "Uh-oh. Something has gone wrong\n#{error}"
      else
        ids = JSON.parse(body)['pathway.wikipathways']
        response = ""
        for id in ids
          response += "#{id.name}\thttp://www.wikipathways.org/index.php/Pathway:#{id.id}\n"
        msg.send "#{response}"

  robot.respond /get reactome ([0-9]+)/i, (msg) ->
    geneID = msg.match[1]
    mygenequery = 'http://mygene.info/v2/gene/' + geneID + '?fields=pathway.reactome'
    request mygenequery, (error, response, body) ->
      if error?
        msg.send "Uh-oh. Something has gone wrong\n#{error}"
      else
        ids = JSON.parse(body)['pathway.reactome']
        response = ""
        for id in ids
          response += "#{id.name}\t#{id.id}\n"
        msg.send "#{response}"
