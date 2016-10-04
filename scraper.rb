#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'

module NokoHelper
  def noko_for(url)
    @noko ||= Nokogiri::HTML(open(url).read)
  end

  def noko
    noko_for(url)
  end
end

class String
  def tidy
    gsub(/[[:space:]]+/, ' ').strip
  end
end

class List
  include NokoHelper

  def initialize(term:, url:)
    @term = term
    @url = url
  end

  def members
    @members ||= noko_for(url).css('.liste2 .liste a').map do |a|
      link = URI.join url, a.attr('href')
      Member.new(term: term, sortname: a.text, url: link)
    end
  end

  private
  attr_reader :term, :url
end

class Member
  include NokoHelper

  def initialize(term:, sortname:, url:)
    @term = term
    @sortname = sortname
    @url = url
  end

  def to_h
    {
      id: id,
      name: name,
      sortname: sortname,
      image: image,
      birth_date: birth_date,
      faction: faction,
      faction_id: faction_id,
      party: party,
      constituency: constituency,
      start_date: start_date,
      end_date: end_date,
      term: term,
      source: source,
    }
  end

  def id
    url.to_s[/id=(\d+)$/, 1]
  end

  def name
    noko.xpath('//title').text.split(' - ').last
  end

  def image
    img = noko.css('.ArticleText2 img/@src').text
    URI.join(url, img).to_s unless img.to_s.empty?
  end

  def birth_date
    dob_from(noko.css('.ArticleText2'))
  end

  def faction
     warn "No faction in #{source}: setting to 'Independent'".red unless deputy_club
     deputy_club || 'Independent'
  end

  def faction_id
    noko.xpath('//td[b[contains(.,"Deputy club:")]]//a/@href')
        .text[/id=(\d+)/, 1]
  end

  def party
    noko.css('td.Stranka').text.tidy
  end

  def constituency
    noko.xpath('//td[b[contains(.,"Constituency:")]]/text()').text
  end

  def start_date
    noko.xpath('//td[b[contains(.,"Begin of parliamentary mandate:")]]/text()')
        .text
        .split('/')
        .reverse
        .join('-')
  end

  def end_date
    noko.xpath('//td[b[contains(.,"End of parliamentary mandate:")]]/text()')
        .text
        .split('/')
        .reverse
        .join('-')
  end

  def source
    url.to_s
  end

  private

  attr_reader :term, :sortname, :url

  def deputy_club
    f = noko.xpath('//td[b[contains(.,"Deputy club:")]]//a').text
    f unless f.to_s.empty?
  end

  def dob_from(node)
    Date.parse(node.text.tidy[/Born\s+(?:on)\s+(\d+\s+\w+\s+\d+)/, 1]).to_s rescue ''
  end
end

def save(list)
  list.members.each do |member|
    ScraperWiki.save_sqlite([:id, :term], member.to_h)
  end
end

save( List.new(term: 8, url: 'http://www.sabor.hr/Default.aspx?sec=4608') )
save( List.new(term: 8, url: 'http://www.sabor.hr/concluded-mandates') ) # left mid-way
save( List.new(term: 7, url: 'http://www.sabor.hr/members-of-parliament') )
save( List.new(term: 7, url: 'http://www.sabor.hr/0041') )# left mid-way

# List.new(term: 6, url: 'http://www.sabor.hr/Default.aspx?sec=4897')
# List.new(term: 5, url: 'http://www.sabor.hr/Default.aspx?sec=2487')

