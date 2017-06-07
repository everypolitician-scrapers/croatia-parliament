# frozen_string_literal: true

require_relative './test_helper'
require_relative '../lib/members_page'

describe MembersPage do
  around { |test| VCR.use_cassette(File.basename(url), &test) }
  let(:response)  { MembersPage.new(response: Scraped::Request.new(url: url).response) }

  describe 'Seat row with single url that points to the primary member’s page' do
    let(:url) { 'http://www.sabor.hr/Default.aspx?sec=4608' }
    let(:subject) { response.seat_rows.first }

    it 'should contain the expected url' do
      subject[:primary_member_url].must_equal 'http://www.sabor.hr/lgs.axd?t=24&id=7163'
    end

    it 'returns the expected sort name' do
      subject[:primary_member_sort_name].must_equal 'Aleksić, Goran'
    end
  end

  describe 'Seat row with single url that does not point to the primary member’s page' do
    let(:url) { 'http://www.sabor.hr/dormant-mandates0001' }
    let(:subject) { response.seat_rows[1] }

    it 'returns an empty string for the url' do
      subject[:primary_member_url].must_be_empty
    end

    it 'returns the sort name for the primary member' do
      subject[:primary_member_sort_name].must_equal 'Bandić, Milan'
    end
  end

  describe 'Seat row with two urls' do
    let(:url) { 'http://www.sabor.hr/dormant-mandates0001' }
    let(:subject) { response.seat_rows[2] }

    it 'returns the url that points to the primary member’s page' do
      subject[:primary_member_url].must_equal 'http://www.sabor.hr/lgs.axd?t=24&id=6206'
    end

    it 'returns the sort name of the primary member' do
      subject[:primary_member_sort_name].must_equal 'Brkić, Milijan'
    end
  end

  describe 'Seat row with no urls' do
    let(:url) { 'http://www.sabor.hr/concluded-mandates' }
    let(:subject) { response.seat_rows[2] }

    it 'returns an empty string for the url' do
      subject[:primary_member_url].must_be_empty
    end

    it 'returns the sort name of the primary member' do
      subject[:primary_member_sort_name].must_equal 'Baričević, Martin'
    end
  end
end
