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

  context 'gets the settings' do
    it 'with params' do
      params = {
        'layout' => 'bare',
        'type' => 'number',
        'boxcolour' => 'fa8100',
        'textcolour' => 'fff',
        'autorefresh' => true
      }

      helpers.get_settings(params, {})

      expect(helpers.instance_variable_get("@layout")).to eq('bare')
      expect(helpers.instance_variable_get("@type")).to eq('number')
      expect(helpers.instance_variable_get("@boxcolour")).to eq('#fa8100')
      expect(helpers.instance_variable_get("@textcolour")).to eq('#fff')
      expect(helpers.instance_variable_get("@autorefresh")).to eq(true)
    end

    it 'with no params' do
      helpers.get_settings({}, {})

      expect(helpers.instance_variable_get("@layout")).to eq('rich')
      expect(helpers.instance_variable_get("@type")).to eq('chart')
      expect(helpers.instance_variable_get("@boxcolour")).to eq('#ddd')
      expect(helpers.instance_variable_get("@textcolour")).to eq('#222')
      expect(helpers.instance_variable_get("@autorefresh")).to eq(nil)
    end

    it 'with a mixture' do
      params = {
        'boxcolour' => 'fa8100',
        'textcolour' => 'fff',
      }

      helpers.get_settings(params, {})

      expect(helpers.instance_variable_get("@layout")).to eq('rich')
      expect(helpers.instance_variable_get("@type")).to eq('chart')
      expect(helpers.instance_variable_get("@boxcolour")).to eq('#fa8100')
      expect(helpers.instance_variable_get("@textcolour")).to eq('#fff')
      expect(helpers.instance_variable_get("@autorefresh")).to eq(nil)
    end

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

  context 'gets visualisation type' do
    let(:data) {
      {
        time: "2016-02-01T09:27:45.000+00:00",
        value: 123
      }
    }
    let(:metric_name) { 'my-cool-metric' }

    it 'when a default exists' do
      MetricDefault.create(name: 'my-cool-metric', type: 'pie')
      expect(helpers.visualisation_type(metric_name, data)).to eq('pie')
    end

    it 'when a default does not exist' do
      expect(helpers.visualisation_type(metric_name, data)).to eq('chart')
    end
  end

  context 'intelligently guesses the visualisation type' do
    it 'for a chart' do
      data = {
        time: "2016-02-01T09:27:45.000+00:00",
        value: 123
      }

      expect(helpers.guess_type data).to eq('chart')
    end

    it 'for a tasklist' do
      data = {
        time: "2016-03-01T09:52:36.000+00:00",
        value: [
          {
            id: "512211cc788c2d8d110074a9",
            title: "Embed 2 processes with ODI standards",
            due: "2013-03-31T11:00:00Z",
            progress: 1,
            no_checklist: false
          }
        ]
      }

      expect(helpers.guess_type data).to eq('tasklist')
    end

    it 'for a target' do
      data = {
        time: "2016-02-02T00:27:38.000+00:00",
        value: {
          total: {
            male: 24,
            female: 37
          },
          teams: {
            board: {
              male: 6,
              female: 2
            },
            spt: {
              male: 2,
              female: 2
            },
            global_network: {
              male: 6,
              female: 8
            },
            core: {
              male: 5,
              female: 20
            },
            innovation_unit: {
              male: 11,
              female: 9
            },
            leadership: {
              male: 5,
              female: 7
            }
          }
        }
      }

      expect(helpers.guess_type data).to eq('pie')
    end

    it 'when there is no data' do
      data = nil

      expect(helpers.guess_type data).to eq('chart')
    end

    it 'when there is null data' do
      data = {
        time: "2016-02-02T00:27:38.000+00:00",
        value: nil
      }

      expect(helpers.guess_type data).to eq('chart')
    end

  end

end
