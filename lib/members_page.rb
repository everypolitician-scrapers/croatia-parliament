# frozen_string_literal: true

require 'scraped'
require_relative 'seat_row'

class MembersPage < Scraped::HTML
  decorator Scraped::Response::Decorator::CleanUrls

  field :seat_rows do
    noko.css('.liste2 .liste').map do |row|
      (fragment row => SeatRow).to_h
    end
  end
end
