require 'scraped'

class AbsoluteLinks < Scraped::Response::Decorator
  def body
    doc = Nokogiri::HTML(super)
    doc.css('a').each do |link|
      link[:href] = URI.join(url, URI.encode(link[:href])).to_s unless link[:href].nil?
    end
    doc.to_s
  end
end
