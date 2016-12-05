#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
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
  members_page = MembersPage.new(response: Scraped::Request.new(url: url).response(decorators: [AbsoluteLinks]))
                    .members
                    .map do |member_page|
           member_page.to_h.merge(term: term)
         end
                    .each do |member_data|
    ScraperWiki.save_sqlite([:name, :term], member_data)
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
