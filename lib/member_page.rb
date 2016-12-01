# frozen_string_literal: true
require 'scraped'

class MemberPage < Scraped::HTML
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
    dob_from(noko.css('.ArticleText2'))
  end

  field :faction do
    noko.xpath('//td[b[contains(.,"Deputy club:")]]//a').text
  end

  field :faction_id do
    noko.xpath('//td[b[contains(.,"Deputy club:")]]//a/@href').text[/id=(\d+)/, 1]
  end

  field :party do
    noko.css('td.Stranka').text.tidy
  end

  field :constituency do
    noko.xpath('//td[b[contains(.,"Constituency:")]]/text()').text
  end

  field :start_date do
    noko.xpath('//td[b[contains(.,"Begin of parliamentary mandate:")]]/text()').text.split('/').reverse.join('-')
  end

  field :end_date do
    noko.xpath('//td[b[contains(.,"End of parliamentary mandate:")]]/text()').text.split('/').reverse.join('-')
  end

  field :source do
    url.to_s
  end

  # TODO: Changes, e.g. http://www.sabor.hr/Default.aspx?sec=5358

  private

  def dob_from(node)
    Date.parse(node.text.tidy[/Born\s+(?:on)\s+(\d+\s+\w+\s+\d+)/, 1]).to_s rescue ''
  end
end
