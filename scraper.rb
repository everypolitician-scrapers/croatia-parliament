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
  scrape(url => MembersPage).member_urls.map do |mem_url|
    data = scrape(mem_url => MemberPage).to_h.merge(term: term)
    puts data.reject { |_, v| v.to_s.empty? }.sort_by { |k, _| k }.to_h if ENV['MORPH_DEBUG']
    data
  end
end

member_lists = [
  { term: 9, url: 'http://www.sabor.hr/Default.aspx?sec=4608' },
  { term: 9, url: 'http://www.sabor.hr/concluded-mandates' }, # left mid-way
  { term: 9, url: 'http://www.sabor.hr/concluded-mandates' },
  { term: 8, url: 'http://www.sabor.hr/concluded-mandates0001' }, # left mid-way
  { term: 8, url: 'http://www.sabor.hr/dormant-mandates0001' }, # suspended memberships
  { term: 7, url: 'http://www.sabor.hr/members-of-parliament' },
  { term: 7, url: 'http://www.sabor.hr/0041' }, # left mid-way
  # { term: 6, url: 'http://www.sabor.hr/Default.aspx?sec=4897' },
  # { term: 5, url: 'http://www.sabor.hr/Default.aspx?sec=2487' }
]

data = member_lists.flat_map { |list| member_data(list[:term], list[:url]) }
ScraperWiki.sqliteexecute('DROP TABLE data') rescue nil
ScraperWiki.save_sqlite(%i[id term], data)
