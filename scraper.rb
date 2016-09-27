#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class Base
  private
  def noko_for(url)
    @noko ||= Nokogiri::HTML(open(url).read)
  end
end

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

class ListScraper < Base
  def initialize(term, url)
    @term = term
    @url = url
  end

  def members
    @members ||= noko_for(url).css('.liste2 .liste a').map do |a|
      link = URI.join url, a.attr('href')
      Member.new(term, a.text, link)
    end
  end

  def save
    members.each do |member|
      ScraperWiki.save_sqlite([:id, :term], member.to_h)
    end
  end

  private
  attr_reader :term, :url
end

class Member < Base

  def initialize(term, sortname, url)
    @term = term
    @sortname = sortname
    @url = url
  end

  def to_h
    noko = noko_for(url)

    data = {
      id: url.to_s[/id=(\d+)$/, 1],
      # name: noko.css('.pagetitle span').first.text,
      name: noko.xpath('//title').text.split(' - ').last,
      sortname: sortname,
      image: noko.css('.ArticleText2 img/@src').text,
      birth_date: dob_from(noko.css('.ArticleText2')),
      faction: noko.xpath('//td[b[contains(.,"Deputy club:")]]//a').text,
      faction_id: noko.xpath('//td[b[contains(.,"Deputy club:")]]//a/@href').text[/id=(\d+)/, 1],
      party: noko.css('td.Stranka').text.tidy,
      constituency: noko.xpath('//td[b[contains(.,"Constituency:")]]/text()').text,
      start_date: noko.xpath('//td[b[contains(.,"Begin of parliamentary mandate:")]]/text()').text.split('/').reverse.join('-'),
      end_date: noko.xpath('//td[b[contains(.,"End of parliamentary mandate:")]]/text()').text.split('/').reverse.join('-'),
      # TODO: Chamges, e.g. http://www.sabor.hr/Default.aspx?sec=5358
      term: term,
      source: url.to_s,
    }
    data[:image] = URI.join(url, data[:image]).to_s unless data[:image].to_s.empty?

    if data[:faction].to_s.empty?
      data[:faction] = "Independent"
      warn "No faction in #{data[:source]}: setting to #{data[:faction]}".red
    end

    data
  end

  private

  attr_reader :term, :sortname, :url

  def dob_from(node)
    Date.parse(node.text.tidy[/Born\s+(?:on)\s+(\d+\s+\w+\s+\d+)/, 1]).to_s rescue ''
  end
end

ListScraper.new(8, 'http://www.sabor.hr/Default.aspx?sec=4608').save
ListScraper.new(8, 'http://www.sabor.hr/concluded-mandates').save # left mid-way

ListScraper.new(7, 'http://www.sabor.hr/members-of-parliament').save
ListScraper.new(7, 'http://www.sabor.hr/0041').save # left mid-way

# ListScraper.new(6, 'http://www.sabor.hr/Default.aspx?sec=4897').members
# ListScraper.new(5, 'http://www.sabor.hr/Default.aspx?sec=2487').members

