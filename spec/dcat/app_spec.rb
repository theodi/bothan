describe MetricsApi do
  before :all do
  #  WebMock.allow_net_connect!
    get '/metrics'
    body = last_response.body
    stub_request(:any, /.*/).to_return(status: 404)
    stub_request(:get, 'http://metrics-api.theodi.org').to_return(status: 200, body: body, headers: {})
    @dataset = DataKitten::Dataset.new 'http://metrics-api.theodi.org'
  end

  it 'has a title' do
    expect(@dataset.data_title).to eq 'ODI Metrics'
  end

  it 'has the correct URL' do
    expect(@dataset.send(:dataset_uri)).to eq 'http://example.org/metrics'
  end
end
