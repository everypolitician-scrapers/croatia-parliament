# frozen_string_literal: true

require_relative './test_helper'
require_relative '../lib/members_page'

describe MembersPage do
  around { |test| VCR.use_cassette(File.basename(url), &test) }
  let(:response)  { MembersPage.new(response: Scraped::Request.new(url: url).response) }

  describe 'Member row' do
    let(:url) { 'http://www.sabor.hr/Default.aspx?sec=4608' }

    it 'should contain the expected data' do
      'http://www.sabor.hr/lgs.axd?t=24&id=7163'.must_equal response.member_urls.first
    end
  end
end
