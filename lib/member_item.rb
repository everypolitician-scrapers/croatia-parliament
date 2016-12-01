require 'scraped'

class MemberItem < Scraped::HTML
  field :name do
    split_row_text[0].split(',').reverse.join(' ').tidy
  end

  field :party do
    split_row_text[1].tidy
  end

  field :sort_name do
    split_row_text[0]
  end
  
  private

  def split_row_text
    noko.xpath('text()').text.split("\r")
  end
end
