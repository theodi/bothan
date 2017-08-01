describe Bothan::App do
  before :all do
    create_data

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

  it 'has the correct creation date' do
    expect(@dataset.issued).to eq DateTime.parse '2015-01-01T00:00:00.000+00:00'
  end

  it 'has the correct last-modified date' do
    expect(@dataset.modified).to eq DateTime.parse '2017-01-01T00:00:00.000+00:00'
  end

  it 'has a good description' do
    expect(@dataset.description).to match(/This API contains a list of all metrics collected by the Open Data Institute since 2013/)
  end

  it 'has a license' do
    expect(@dataset.licenses.first.uri).to eq 'https://creativecommons.org/licenses/by-sa/4.0/'
    expect(@dataset.licenses.first.name).to eq 'Creative Commons Attribution-ShareAlike'
  end

  it 'has a publisher' do
    expect(@dataset.publishers.first.homepage).to eq 'http://theodi.org'
    expect(@dataset.publishers.first.name).to eq 'Open Data Institute'
  end

  it 'has the update frequency' do
    expect(@dataset.update_frequency).to eq 'http://purl.org/linked-data/sdmx/2009/code#freq-D'
  end

  it 'has some distributions' do
    expect(@dataset.distributions.count).to eq(1)
    expect(@dataset.distributions.first.title).to eq('Metrique')
    expect(@dataset.distributions.first.access_url).to eq('http://example.org/metrics/metrique')
  end
end

def create_data
  earliest = {name: 'metrique', time: '2015-01-01T00:00:00.000+00:00', value: '194321'}
  Metric.create(earliest)

  latest = {name: 'metrique', time: '2017-01-01T00:00:00.000+00:00', value: '194321'}
  Metric.create(latest)
end
