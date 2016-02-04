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
end

describe String do
  it 'titleises a string' do
    expect('some string'.titleise).to eq 'Some String'
  end
end
