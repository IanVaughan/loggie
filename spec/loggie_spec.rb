require 'spec_helper'

RSpec.describe Loggie, :vcr do
  it 'has a version number' do
    expect(Loggie::VERSION).not_to be nil
  end

  let(:search) { Loggie.search(query: 'foo') }
  let(:stubbed_result) { 'bar' }
  let(:search_double) { instance_double(Loggie::Logentries::Search, call: stubbed_result) }

  it 'passes the parmms to a search' do
    Timecop.freeze do
      params = { query: 'foo', from: 1.week.ago, to: Time.zone.now, block: nil }
      expect(Loggie::Logentries::Search).to(
        receive(:new).with(params).and_return(search_double)
      )
      expect(search).to eq(stubbed_result)
    end
  end
end
