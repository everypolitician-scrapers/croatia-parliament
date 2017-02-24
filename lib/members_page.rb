# frozen_string_literal: true
require 'scraped'
require_relative 'member_row'

class MembersPage < Scraped::HTML
  decorator Scraped::Response::Decorator::AbsoluteUrls

  field :member_rows do
    noko.css('.liste2 .liste').map do |item|
      fragment item => MemberRow
    end
  end
end
