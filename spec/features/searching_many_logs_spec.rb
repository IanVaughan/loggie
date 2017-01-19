require 'spec_helper'
require 'webmock/rspec'

# NOTE: The VCR for this test has been modified to remove private date
RSpec.describe "Checkout estimates", type: :feature, vcr: true do
  let!(:unix_timestamp) { 1484689304000 }
  let!(:test_time) { Time.at(unix_timestamp / 1000).to_datetime }
  let!(:base_uri) { "https://rest.logentries.com/query/logs" }

  it "gets matching logs from the requested log files" do
    Timecop.freeze test_time

    expect { |b| @res = Loggie.search(query: "foobar", &b) }.to yield_successive_args([0,1], [12,2])
    res = @res

    body = {
      logs: ["e20bd6af", "c83c7cd7", "6fb426fd", "776dfea9"],
      leql: {
        during: { from: 1484084504000, to: 1484689304000 },
        statement: "where(foobar)"
      }
    }

    expect(WebMock).to have_requested(:post, base_uri).with(
      headers: { 'X-Api-Key' => 'bf3b4d32' },
      body: body
    )

    get_uri = "https://rest.logentries.com/query/f2122376:0:daabb84:50:c6611df2e551110da3919fcc05294d332c6e3620?log_keys=e20bd6af:c83c7cd7:6fb426fd:776dfea9&query=where(foobar)"
    expect(WebMock).to have_requested(:get, get_uri).with(
      headers: { 'X-Api-Key' => 'bf3b4d32' },
    ).twice

    expect(res.first[:message]).to eq("path_info"=>"/user", "request_method"=>"PUT")
  end
end
