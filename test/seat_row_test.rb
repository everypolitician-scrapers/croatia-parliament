# frozen_string_literal: true

require_relative './test_helper'
require_relative '../lib/members_page'

describe MembersPage do
  around { |test| VCR.use_cassette(File.basename(url), &test) }
  let(:response)  { MembersPage.new(response: Scraped::Request.new(url: url).response) }

  describe 'Member row with single url that points to the member’s page' do
    let(:url) { 'http://www.sabor.hr/Default.aspx?sec=4608' }

    it 'should contain the expected data' do
      response.member_urls.first.must_equal 'http://www.sabor.hr/lgs.axd?t=24&id=7163'
    end
  end

  describe 'Member row with single url that does not point to the member’s page' do
    let(:url) { 'http://www.sabor.hr/dormant-mandates0001' }

    it 'returns an empty string for the url' do
      response.member_urls[1].must_be_empty
    end
  end

  describe 'Member row with two urls' do
    let(:url) { 'http://www.sabor.hr/dormant-mandates0001' }

    it 'returns the url that points to the member’s page' do
      response.member_urls[2].must_equal 'http://www.sabor.hr/lgs.axd?t=24&id=6206'
    end
  end

  describe 'Member row with no urls' do
    let(:url) { 'http://www.sabor.hr/concluded-mandates' }

    it 'returns an empty string for the url' do
      response.member_urls[2].must_be_empty
    end
  end
end
