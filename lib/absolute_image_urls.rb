require 'Scraped'

class AbsoluteImageURLs < Scraped::Response::Decorator
  def body
    doc = Nokogiri::HTML(super)
    doc.css('img').each do |link|
      link[:src] = URI.join(url, link[:src]).to_s
    end
    doc.to_s
  end
end
