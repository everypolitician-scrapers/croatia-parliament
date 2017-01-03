#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'require_all'
require 'scraped'
require 'scraperwiki'

# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'

require_rel 'lib'

class String
  def tidy
    gsub(/[[:space:]]+/, ' ').strip
  end
end

def scrape_list(term, url)
  MembersPage.new(response: Scraped::Request.new(url: url).response)
             .member_urls
             .each do |url|
    data = MemberPage.new(response: Scraped::Request.new(url: url).response)
                     .to_h
                     .merge(term: term)
    ScraperWiki.save_sqlite([:id, :term], data)
  end
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
