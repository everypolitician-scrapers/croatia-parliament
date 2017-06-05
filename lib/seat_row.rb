# frozen_string_literal: true

require 'scraped'

class SeatRow < Scraped::HTML
  field :member_url do
    # A row can contain none, one, or two anchor tags. When one or more links
    # are present, the URL of the member's individual page is always the one
    # containing text that matches their sort name. If no anchors contain
    # the matching text, then the member does not have an individual page.
    noko.xpath("a[text()='#{member_sort_name}']/@href").text
  end

  field :member_sort_name do
    noko.text.split("\r").first.tidy
  end
end
