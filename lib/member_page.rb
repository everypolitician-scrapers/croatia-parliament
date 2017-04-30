# frozen_string_literal: true

require 'scraped'

class MemberPage < Scraped::HTML
  decorator Scraped::Response::Decorator::CleanUrls

  field :id do
    url.to_s[/id=(\d+)$/, 1]
  end

  field :name do
    noko.xpath('//title').text.split(' - ').last
  end

  field :image do
    noko.css('.ArticleText2 img/@src').text
  end

  field :birth_date do
    date = noko.css('.ArticleText2').text.tidy
    return '' if date.to_s.empty?
    Date.parse(date[/Born\s+(?:on)\s+(\d+\s+\w+\s+\d+)/, 1]).to_s rescue ''
  end

  field :faction do
    faction = noko.xpath('//td[b[contains(.,"Deputy club:")]]//a').text
    return 'Independent' if faction.to_s.empty?
    faction
  end

  field :faction_id do
    noko.xpath('//td[b[contains(.,"Deputy club:")]]//a/@href').text[/id=(\d+)/, 1]
  end

  field :party do
    noko.css('td.Stranka').text.tidy
  end

  field :constituency do
    noko.xpath('//td[b[contains(.,"Constituency:")]]/text()').text.tidy
  end

  field :start_date do
    noko.xpath('//td[b[contains(.,"Begin of parliamentary mandate:")]]/text()').text.split('/').reverse.map(&:tidy).join('-')
  end

  field :end_date do
    noko.xpath('//td[b[contains(.,"End of parliamentary mandate:")]]/text()').text.split('/').reverse.map(&:tidy).join('-')
  end

  field :source do
    url.to_s
  end

  # TODO: Changes, e.g. http://www.sabor.hr/Default.aspx?sec=5358
end
