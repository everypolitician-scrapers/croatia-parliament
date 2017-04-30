# frozen_string_literal: true
require 'scraped'

class MembersPage < Scraped::HTML
  decorator Scraped::Response::Decorator::CleanUrls

  field :member_urls do
    noko.css('.liste2 .liste a').map do |a|
      a.attr('href')
    end
  end
end
