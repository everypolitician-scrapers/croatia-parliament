#!/bin/env ruby
# frozen_string_literal: true

require 'pry'
require 'require_all'
require 'scraped'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

require_rel 'lib'

def scrape(pair)
  url, klass = pair.to_a.first
  klass.new(response: Scraped::Request.new(url: url).response)
end

def scrape_list(term, url)
  scrape(url => MembersPage).member_urls.each do |mem_url|
    data = scrape(mem_url => MemberPage).to_h.merge(term: term)
    puts data.reject { |_, v| v.to_s.empty? }.sort_by { |k, _| k }.to_h if ENV['MORPH_DEBUG']
    ScraperWiki.save_sqlite(%i[id term], data)
  end
end

ScraperWiki.sqliteexecute('DROP TABLE data') rescue nil
scrape_list(9, 'http://www.sabor.hr/Default.aspx?sec=4608')
scrape_list(9, 'http://www.sabor.hr/concluded-mandates') # left mid-way

scrape_list(8, 'http://www.sabor.hr/members-of-parliament0001')
scrape_list(8, 'http://www.sabor.hr/concluded-mandates0001') # left mid-way
scrape_list(8, 'http://www.sabor.hr/dormant-mandates0001') # suspended memberships

scrape_list(7, 'http://www.sabor.hr/members-of-parliament')
scrape_list(7, 'http://www.sabor.hr/0041') # left mid-way

# scrape_list(6, 'http://www.sabor.hr/Default.aspx?sec=4897')
# scrape_list(5, 'http://www.sabor.hr/Default.aspx?sec=2487')
