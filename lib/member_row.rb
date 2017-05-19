# frozen_string_literal: true

require 'scraped'

class MemberRow < Scraped::HTML
  field :url do
    noko.attr('href')
  end
end
