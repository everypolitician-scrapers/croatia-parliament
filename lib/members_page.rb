# frozen_string_literal: true

require 'scraped'
require_relative 'member_row'

class MembersPage < Scraped::HTML
  decorator Scraped::Response::Decorator::CleanUrls

  field :member_urls do
    noko.css('.liste2 .liste a').map do |a|
      (fragment a => MemberRow).url
    end
  end
end
