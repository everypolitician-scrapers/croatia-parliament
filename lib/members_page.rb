# frozen_string_literal: true
require 'scraped'

class MembersPage < Scraped::HTML
  field :members do
    noko.css('.liste2 .liste a').map do |a|
      MemberPage.new(response: Scraped::Request.new(url: a.attr('href')).response)
    end
  end
end
