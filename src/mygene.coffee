# Commands:
#   hubot find gene <query> - Returns ID, TaxId, Name and Symbol of genes matching query
#   hubot find gene <query> <species> - Limits search by species. Species can be TaxId.
#   hubot get gene symbol <gene ID> - Returns gene symbol for gene ID.
#   hubot get gene position <gene ID> - Returns genomic position for gene ID. Position in HG19. 
#   hubot get gene summary <gene ID> - Returns summary of gene
#   hubot get entrezi gene <gene ID> - Returns Entrez gene ID for gene
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
#   hubot get smpdb <gene ID> - Returns SMPDB entries for gene
#   hubot get pid <gene ID> - Returns PID entries for gene
#   hubot get gene type <gene ID> - Returns type of gene
#   hubot get swiss-prot <gene ID> - Returns Swiss-Prot entry for gene
#   hubot get trembl <gene ID> - Returns TrEMBL entries for gene
#   hubot get go bp <gene ID> - Returns Biological Process GO terms for gene
#   hubot get go mf <gene ID> - Returns Molecular Function GO terms for gene
#   hubot get go cc <gene ID> - Returns Cellular Component GO terms for gene
#   hubot get unigene <gene ID> - Returns Unigene entry for gene
#   hubot get prosite <gene ID> - Returns Prosite entries for gene
#   hubot get taxid <gene ID> - Returns TaxId for species with gene
#
#
#
# Dependencies:
#   "request" : "*"
#
# Author:
#   Andrew Quitadamo

request = require 'request'

getSearchLink = (searchTerm) ->
  if searchTerm == 'ensembl gene'
    searchTerm = 'ensembl.gene'
    link = (id) -> "#{id}\thttp://www.ensembl.org/Homo_sapiens/Gene/Summary?g=#{id}"
  if searchTerm == 'map location'
    searchTerm = 'map_location'
    link = (id) -> "#{id}"
  if searchTerm == 'hprd'
    searchTerm = 'HPRD'
    link = (id) -> "#{id}\twww.hprd.org/protein/#{id}"
  if searchTerm == 'hgnc'
    searchTerm = 'HGNC'
    link = (id) -> "#{id}\thttp://www.genenames.org/cgi-bin/gene_symbol_report?hgnc_id=#{id}"
  if searchTerm == 'homologene'
    link = (id) -> "#{id.id}\thttp://www.ncbi.nlm.nih.gov/homologene/#{id.id}"
  if searchTerm == 'homologene genes'
    searchTerm = 'homologene.genes'
    link = (id) -> 
      response = ""
      taxid = id[0]
      geneid = id[1]
      response += "TaxId: #{taxid}\tGene Id: #{geneid}\n"
      return response
  if searchTerm == 'omim'
    searchTerm = 'MIM'
    link = (id) -> "#{id}\thttp://www.omim.org/entry/#{id}"
  if searchTerm == 'gene type'
    searchTerm = 'type_of_gene'
    link = (id) -> "#{id}"
  if searchTerm == 'unigene'
    link = (id) ->
      fields = id.split('.')
      species = fields[0]
      numid = fields[1]
      return "#{id}\thttp://www.ncbi.nlm.nih.gov/UniGene/clust.cgi?ORG=#{species}&CID=#{numid}"
  if searchTerm == 'swiss-prot'
    searchTerm = 'uniprot.Swiss-Prot'
    link = (id) -> "#{id}\thttp://www.uniprot.org/uniprot/#{id}"
  if searchTerm == 'gene summary'
    searchTerm = 'summary'
    link = (id) -> "#{id}"
  if searchTerm == 'gene position hg19'
    searchTerm = 'genomic_pos_hg19'
  if searchTerm == 'gene position'
    searchTerm = 'genomic_pos'
  if searchTerm == 'genomic_pos_hg19' or searchTerm =='genomic_pos'
    link = (pos) -> "chr: #{pos.chr}\nstart: #{pos.start}\nend: #{pos.end}\nstrand: #{pos.strand}"
  if searchTerm == 'kegg'
    searchTerm = 'pathway.kegg'
    link = (id) -> "#{id.name}\thttp://www.genome.jp/dbget-bin/www_bget?#{id.id}\n"
  if searchTerm == 'wikipathways'
    searchTerm = 'pathway.wikipathways'
    link = (id) -> "#{id.name}\thttp://www.wikipathways.org/index.php/Pathway:#{id.id}\n"
  if searchTerm == 'reactome'
    searchTerm = 'pathway.reactome'
    link = (id) -> "#{id.name}\t#{id.id}\n"
  if searchTerm == 'smpdb'
    searchTerm = 'pathway.smpdb'
    link = (id) -> "#{id.name}\thttp://smpdb.ca/view/#{id.id}\n"
  if searchTerm == 'pid'
    searchTerm = 'pathway.pid'
    link = (id) -> "#{id.name}\thttp://pid.nci.nih.gov/search/pathway_landing.shtml?what=graphic&jpg=on&pathway_id=#{id.id}\n"
  if searchTerm == 'pfam'
    link = (id) -> "#{id}\thttp://pfam.xfam.org/family/#{id}\n"
  if searchTerm == 'pdb'
    link = (id) -> "#{id}\thttp://www.rcsb.org/pdb/explore.do?structureId=#{id}\n"
  if searchTerm == 'refseq protein'
    searchTerm = 'refseq.protein'
    link = (id) -> "#{id}\thttp://www.ncbi.nlm.nih.gov/protein/#{id}\n"
  if searchTerm == 'refseq genomic'
    searchTerm = 'refseq.genomic'
    link = (id) -> "#{id}\thttp://www.ncbi.nlm.nih.gov/nuccore/#{id}\n"
  if searchTerm == 'refseq rna'
    searchTerm = 'refseq.rna'
    link = (id) -> "#{id}\thttp://www.ncbi.nlm.nih.gov/nuccore/#{id}\n"
  if searchTerm == 'ensembl proteins'
    searchTerm = 'ensembl.protein'
    link = (id) -> "#{id}\n"
  if searchTerm == 'ensembl transcripts'
    searchTerm = 'ensembl.transcript'
    link = (id) -> "#{id}\thttp://www.ensembl.org/Homo_sapiens/Transcript/Summary?t=#{id}\n"
  if searchTerm == 'alias'
    link = (id) -> "#{id}\n"
  if searchTerm == 'interpro'
    link = (id) -> "#{id.desc}\thttp://www.ebi.ac.uk/interpro/entry/#{id.id}\n"
  if searchTerm == 'trembl'
    searchTerm = 'uniprot.TrEMBL'
    link = (id) -> "#{id}\thttp://www.uniprot.org/uniprot/#{id}\n"
  if searchTerm == 'go cc'
    searchTerm = 'go.CC'
  if searchTerm == 'go bp'
    searchTerm = 'go.BP'
  if searchTerm == 'go mf'
    searchTerm = 'go.MF'
  if searchTerm == 'go.CC' or searchTerm == 'go.MF' or searchTerm == 'go.BP'
    link = (id) ->
      if id.pubmed?
        response = "#{id.id}\t#{id.term}\t#{id.evidence}\t"
        for ref in id.pubmed
          response += "http://www.ncbi.nlm.nih.gov/pubmed/#{ref}  "
        response += "\n\n"
        return response
      else
        return "#{id.id}\t#{id.term}\t#{id.evidence}\n\n"
  if searchTerm == 'prosite'
    link = (id) -> "#{id}\thttp://prosite.expasy.org/#{id}\n"
  if searchTerm == 'taxid'
    link = (id) -> "#{id}\thttp://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=#{id}"
  if searchTerm == 'gene symbol'
    searchTerm = 'symbol'
    link = (id) -> "#{id}"
  if searchTerm == 'entrez gene'
    searchTerm = 'entrezgene'
    link = (id) -> "#{id}\thttp://www.ncbi.nlm.nih.gov/gene/#{id}"

  return [searchTerm, link]

module.exports = (robot) ->
  robot.respond /find gene ([\w.+\-\*]+) ?(\w.+|[0-9]+])?/i, (res) ->
    query = res.match[1]
    species = res.match[2]
    if species?
      mygenequery = 'http://mygene.info/v2/query?q=' + query  + '&species=' + species
    else
      mygenequery = 'http://mygene.info/v2/query?q=' + query
    request mygenequery, (error, response, body) ->
      if error?
        res.send "Uh-oh. Something has gone wrong\n#{error}"
      if response.statusCode != 200
        res.send "Uh-oh. Something has gone wrong\nHTTP Code #{response.statusCode}"
      else
        hits = JSON.parse(body)['hits']
        response = ""
        for hit in hits
          response += "ID: #{hit.entrezgene}\nTaxId: #{hit.taxid}\nName: #{hit.name}\nSymbol: #{hit.symbol}\n-----\n"
        res.send "#{response}"

  pattern = new RegExp('get gene refs ([0-9]+)' +
                       "(?: from ([0-9]+))?" +
                       "(?: to ([0-9]+))?", 'i')
  robot.respond pattern, (res) ->
    geneID = res.match[1]
    start = res.match[2]
    end = res.match[3]
    mygenequery = 'http://mygene.info/v2/gene/' + geneID + '?fields=generif'
    request mygenequery, (error, response, body) ->
      if error?
        res.send "Uh-oh. Something has gone wrong\n#{error}"
      if response.statusCode != 200
        res.send "Uh-oh. Something has gone wrong\nHTTP Code #{response.statusCode}"
      else
        refs = JSON.parse(body)['generif']
        refLength = refs.length
        if start? and end?
          if end-start > 100
            res.send "Woah, slow down there partner. Try a range less than 100"
            return
          results = refs.slice(parseInt(start)-1,parseInt(end))
          response = ""
          for ref in results 
            response += "#{ref.text}+\nhttp://www.ncbi.nlm.nih.gov/pubmed/#{ref.pubmed}\n\n"
          res.send "#{response}" 
        else
          res.send "10 of #{refLength} references"
          firstTen = refs.slice(0,10)
          response = ""
          for ref in firstTen
            response += "#{ref.text}+\nhttp://www.ncbi.nlm.nih.gov/pubmed/#{ref.pubmed}\n\n"
          res.send "#{response}"

  robot.respond /get (ensembl gene|map location|hprd|hgnc|homologene|omim|gene type|unigene|swiss-prot|gene summary|gene position hg19|gene position|taxid|gene symbol|entrez gene) ([0-9]+)/i, (res) ->
    searchTerm = res.match[1].toLowerCase()
    geneID = res.match[2]

    [searchTerm, link] = getSearchLink(searchTerm)

    mygenequery = 'http://mygene.info/v2/gene/' + geneID + '?fields=' + searchTerm
    request mygenequery, (error, response, body) ->
      if error?
        res.send "Uh-oh. Something has gone wrong\n#{error}"
      if response.statusCode != 200
        res.send "Uh-oh. Something has gone wrong\nHTTP Code #{response.statusCode}"
      else
        id = JSON.parse(body)[searchTerm]
        res.send link(id)

  robot.respond /get (kegg|wikipathways|reactome|smpdb|pid|pfam|pdb|refseq protein|refseq genomic|refseq rna|ensembl proteins|ensembl transcripts|alias|interpro|trembl|go cc|go mf|go bp|prosite|homologene genes) ([0-9]+)/i, (res) ->
    searchTerm = res.match[1].toLowerCase()
    geneID = res.match[2]

    [searchTerm, link] = getSearchLink(searchTerm)

    mygenequery = 'http://mygene.info/v2/gene/' + geneID + '?fields=' + searchTerm
    request mygenequery, (error, response, body) ->
      if error?
        res.send "Uh-oh. Something has gone wrong\n#{error}"
      if response.statusCode != 200
        res.send "Uh-oh. Something has gone wrong\nHTTP Code #{response.statusCode}"
      else
        ids = JSON.parse(body)[searchTerm]
        response = ""
        for id in ids
          response += link(id)
        res.send "#{response}"
