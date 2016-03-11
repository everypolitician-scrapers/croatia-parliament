#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def dob_from(node)
  Date.parse(node.text.tidy[/Born\s+(?:on)\s+(\d+\s+\w+\s+\d+)/, 1]).to_s rescue ''
end

def scrape_list(url)
  noko = noko_for(url)
  noko.css('.liste2 .liste a').each do |a|
    link = URI.join url, a.attr('href')
    scrape_mp(a.text, link)
  end
end

def scrape_mp(sortname, url)
  puts url.to_s
  noko = noko_for(url)

  data = { 
    id: url.to_s[/id=(\d+)$/, 1],
    name: noko.css('.pagetitle span').first.text,
    sortname: sortname, 
    image: noko.css('.ArticleText2 img/@src').text,
    birth_date: dob_from(noko.css('.ArticleText2')),
    faction: noko.xpath('//td[b[contains(.,"Deputy club:")]]//a').text,
    faction_id: noko.xpath('//td[b[contains(.,"Deputy club:")]]//a/@href').text[/id=(\d+)/, 1],
    party: noko.css('td.Stranka').text.tidy,
    constituency: noko.xpath('//td[b[contains(.,"Constituency:")]]/text()').text,
    start_date: noko.xpath('//td[b[contains(.,"Begin of parliamentary mandate:")]]/text()').text.split('/').reverse.join('-'),
    # TODO: Chamges, e.g. http://www.sabor.hr/Default.aspx?sec=5358
    term: 8,
    source: url.to_s,
  }
  data[:image] = URI.join(url, data[:image]).to_s unless data[:image].to_s.empty?
  if data[:faction].to_s.empty?
    data[:faction] = "Independent"
    warn "No faction: setting to #{data[:faction]}".red
  end
  puts data[:faction]
  # ScraperWiki.save_sqlite([:id, :term], data)
end

scrape_list('http://www.sabor.hr/Default.aspx?sec=4608')
