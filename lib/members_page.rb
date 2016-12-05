require 'scraped'

class MembersPage < Scraped::HTML
  field :members_with_pages do
    noko.css('.liste2 .liste a').map do |a|
      MemberPage.new(response: Scraped::Request.new(url: a.attr('href')).response)
    end
  end

  field :members_without_pages do
    noko.xpath('//td[@class= "liste"]').map do |row|
      unless row.xpath('text()').text.split("\r")[0].empty?
        MemberItem.new(response: response, noko: row)
      end
    end
  end

  field :members do
    members_with_pages + members_without_pages
  end
end
