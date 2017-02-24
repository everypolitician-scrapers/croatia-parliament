# frozen_string_literal: true
require 'scraped'

class MemberRow < Scraped::HTML
  field :url do
    # The URL of a substitue member may be listed in a row.
    # We only want URLs of the members we're scraping.
    link = noko.at_xpath("a[contains(text(),'#{sort_name}')]/@href") and return link.text
  end

  field :sort_name do
    noko.text.split("\r").first.tidy
  end
end
