describe Helpers do
  let(:helpers) { TestHelper.new }

  it 'merges dashboards YAML with defaults' do
    data = helpers.get_dashboard_data 'labs', 'spec/support/fixtures/dashboards.yaml'

    expect(data.first).to eq (
      {
        'metric' => 'github-forks',
        'type' => 'chart',
        'boxcolour' => 'fa8100',
        'textcolour' => 'ffffff'
      }
    )

    expect(data[1]).to eq (
      {
        'metric' => 'github-repository-count',
        'type' => 'number',
        'boxcolour' => 'ffffff',
        'textcolour' => '000000'
      }
    )
  end

  it 'makes a query-string' do
    data = {
      'metric' => 'github-repository-count',
      'type' => 'number',
      'boxcolour' => 'ffffff',
      'textcolour' => '000000'
    }

    expect(helpers.query_string data).to eq 'type=number&boxcolour=ffffff&textcolour=000000'
  end

  it 'extracts a title from a URL' do
    expect(
      helpers.extract_title(
        'http://localhost:9292/metrics/certificated-datasets/2013-01-01T00:00:00/2016-02-01T00:00:00'
      )
    ).to eq(
      'Certificated Datasets'
    )

    expect(
      helpers.extract_title(
        'http://localhost:9292/metrics/2013-q1-completed-tasks.json'
      )
    ).to eq(
      '2013 Q1 Completed Tasks'
    )
  end

  it 'gets a image url for a creative commons license' do
    image = helpers.license_image('https://creativecommons.org/licenses/cc-by/4.0/')
    expect(image).to eq('https://licensebuttons.net/l/cc-by/4.0/88x31.png')
  end

  it 'returns nil for a non cc license' do
    image = helpers.license_image('http://www.opendefinition.org/licenses/against-drm')
    expect(image).to eq(nil)
  end

  it 'gets a start-date' do
    params = {
      from: 'P2D',
      to: '2013-12-25T12:00:00+00:00'
    }
    expect(helpers.get_start_date params).to eq 'Mon, 23 Dec 2013 12:00:00 +0000'
  end

  it 'gets an end-date' do
    params = {
      from: '2013-12-22T12:00:00+00:00',
      to: 'PT24H'
    }

    expect(helpers.get_end_date params).to eq 'Mon, 23 Dec 2013 12:00:00 +0000'
  end

end
