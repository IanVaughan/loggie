require 'spec_helper'
require 'timecop'

RSpec.describe Loggie::Extract do
  let(:search) { Loggie.search(query: 'foo') }
  let(:stubbed_result) { 'bar' }
  let(:search_double) { instance_double(Loggie::Logentries::Search, call: stubbed_result) }

  it 'passes the parmms to a search' do
    Timecop.freeze do
      params = { query: 'foo', from: 1.week.ago, to: Time.zone.now }
      expect(Loggie::Logentries::Search).to receive(:new).with(params).and_return(search_double)
      expect(search).to eq(stubbed_result)
    end
  end
end
