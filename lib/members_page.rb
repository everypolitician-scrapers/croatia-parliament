# frozen_string_literal: true

require 'scraped'
require_relative 'member_row'

class MembersPage < Scraped::HTML
  decorator Scraped::Response::Decorator::CleanUrls

  field :member_urls do
    noko.css('.liste2 .liste').map do |row|
      (fragment row => MemberRow).url
    end
  end
end
