# frozen_string_literal: true
require_relative './test_helper'
require_relative '../lib/members_page'

describe MembersPage do
  around { |test| VCR.use_cassette(File.basename(url), &test) }
  let(:response)  { MembersPage.new(response: Scraped::Request.new(url: url).response) }

  describe 'Member row' do
    let(:url) { 'http://www.sabor.hr/Default.aspx?sec=4608' }

    it 'should contain the expected data' do
      {
        url:       'http://www.sabor.hr/lgs.axd?t=24&id=7163',
        sort_name: 'Aleksić, Goran',
      }.must_equal response.member_rows.first.to_h
    end
  end

  describe 'Member row of member without individual page' do
    let(:url) { 'http://www.sabor.hr/concluded-mandates' }

    it 'should contain the expected data' do
      {
        url:       nil,
        sort_name: 'Baričević, Martin',
      }.must_equal response.member_rows[1].to_h
    end
  end

  describe 'Member row which lists member and substitute, where both have a URL' do
    let(:url) { 'http://www.sabor.hr/0041' }

    it 'should contain the expected data' do
      {
        url:       'http://www.sabor.hr/lgs.axd?t=24&id=4999',
        sort_name: 'Borzan, Biljana',
      }.must_equal response.member_rows[3].to_h
    end
  end
end
