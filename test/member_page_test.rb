# frozen_string_literal: true
require_relative './test_helper'
require_relative '../lib/member_page'

describe MemberPage do
  around { |test| VCR.use_cassette(File.basename(url), &test) }

  let(:yaml_data) { YAML.load_file(subject).to_h }
  let(:url)       { yaml_data[:url] }
  let(:response)  { MemberPage.new(response: Scraped::Request.new(url: url).response) }

  describe 'Member data with image' do
    subject { 'test/data/goran_aleksic.yml' }

    it 'should contain the expected data' do
      yaml_data[:to_h].must_equal response.to_h
    end
  end
end
