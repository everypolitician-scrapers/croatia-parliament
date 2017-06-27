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

def scrape(h)
  url, klass = h.to_a.first
  klass.new(response: Scraped::Request.new(url: url).response)
end

def member_data(term, url)
  scrape(url => MembersPage).member_urls.each do |mem_url|
    data = scrape(mem_url => MemberPage).to_h.merge(term: term)
    puts data.reject { |_, v| v.to_s.empty? }.sort_by { |k, _| k }.to_h if ENV['MORPH_DEBUG']
    ScraperWiki.save_sqlite(%i[id term], data)
  end
end

ScraperWiki.sqliteexecute('DROP TABLE data') rescue nil
member_data(9, 'http://www.sabor.hr/Default.aspx?sec=4608')
member_data(9, 'http://www.sabor.hr/concluded-mandates') # left mid-way

member_data(8, 'http://www.sabor.hr/members-of-parliament0001')
member_data(8, 'http://www.sabor.hr/concluded-mandates0001') # left mid-way
member_data(8, 'http://www.sabor.hr/dormant-mandates0001') # suspended memberships

member_data(7, 'http://www.sabor.hr/members-of-parliament')
member_data(7, 'http://www.sabor.hr/0041') # left mid-way

# member_data(6, 'http://www.sabor.hr/Default.aspx?sec=4897')
# member_data(5, 'http://www.sabor.hr/Default.aspx?sec=2487')
