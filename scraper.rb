#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'scraperwiki'
require 'nokogiri'
require 'pry'

# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'

class String
  def tidy
    gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def dob_from(node)
  Date.parse(node.text.tidy[/Born\s+(?:on)\s+(\d+\s+\w+\s+\d+)/, 1]).to_s rescue ''
end

def scrape_list(term, url)
  noko = noko_for(url)
  noko.css('.liste2 .liste a').each do |a|
    link = URI.join url, a.attr('href')
    scrape_mp(term, a.text, link)
  end
end

def scrape_mp(term, sortname, url)
  noko = noko_for(url)

  data = {
    id:           url.to_s[/id=(\d+)$/, 1],
    #  name: noko.css('.pagetitle span').first.text,
    name:         noko.xpath('//title').text.split(' - ').last,
    sortname:     sortname,
    image:        noko.css('.ArticleText2 img/@src').text,
    birth_date:   dob_from(noko.css('.ArticleText2')),
    faction:      noko.xpath('//td[b[contains(.,"Deputy club:")]]//a').text,
    faction_id:   noko.xpath('//td[b[contains(.,"Deputy club:")]]//a/@href').text[/id=(\d+)/, 1],
    party:        noko.css('td.Stranka').text.tidy,
    constituency: noko.xpath('//td[b[contains(.,"Constituency:")]]/text()').text,
    start_date:   noko.xpath('//td[b[contains(.,"Begin of parliamentary mandate:")]]/text()').text.split('/').reverse.join('-'),
    end_date:     noko.xpath('//td[b[contains(.,"End of parliamentary mandate:")]]/text()').text.split('/').reverse.join('-'),
    # TODO: Chamges, e.g. http://www.sabor.hr/Default.aspx?sec=5358
    term:         term,
    source:       url.to_s,
  }
  data[:image] = URI.join(url, data[:image]).to_s unless data[:image].to_s.empty?

  if data[:faction].to_s.empty?
    data[:faction] = 'Independent'
    warn "No faction in #{data[:source]}: setting to #{data[:faction]}"
  end
  ScraperWiki.save_sqlite(%i(id term), data)
end

scrape_list(9, 'http://www.sabor.hr/Default.aspx?sec=4608')
scrape_list(9, 'http://www.sabor.hr/concluded-mandates') # left mid-way

scrape_list(8, 'http://www.sabor.hr/members-of-parliament0001')
scrape_list(8, 'http://www.sabor.hr/concluded-mandates0001') # left mid-way
scrape_list(8, 'http://www.sabor.hr/dormant-mandates0001') # suspended memberships

scrape_list(7, 'http://www.sabor.hr/members-of-parliament')
scrape_list(7, 'http://www.sabor.hr/0041') # left mid-way

# scrape_list(6, 'http://www.sabor.hr/Default.aspx?sec=4897')
# scrape_list(5, 'http://www.sabor.hr/Default.aspx?sec=2487')
