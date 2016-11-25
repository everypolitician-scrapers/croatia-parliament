#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped'
require 'require_all'

require_rel 'lib'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(term, url)
  noko = noko_for(url)
  noko.css('.liste2 .liste a').each do |a|
    link = URI.join url, a.attr('href')
    scrape_mp(term, a.text, link)
  end
end

def scrape_mp(term, sortname, url)

  response = Scraped::Request.new(url: url)
                             .response(decorators: [AbsoluteImageURLs])
  data = MemberPage.new(response: response).to_h
                   .merge({
                    id: url.to_s[/id=(\d+)$/, 1],
                    term: term,
                    sortname: sortname,
                    source: url.to_s
                    })

  if data[:faction].to_s.empty?
    data[:faction] = "Independent"
    warn "No faction in #{data[:source]}: setting to #{data[:faction]}".red
  end

  ScraperWiki.save_sqlite([:id, :term], data)
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
