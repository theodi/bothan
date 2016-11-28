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
        'autorefresh' => true,
        'metric' => 'foo-bar'
      }

      helpers.get_settings(params, {})

      expect(helpers.instance_variable_get("@layout")).to eq('bare')
      expect(helpers.instance_variable_get("@type")).to eq('number')
      expect(helpers.instance_variable_get("@boxcolour")).to eq('#fa8100')
      expect(helpers.instance_variable_get("@textcolour")).to eq('#fff')
      expect(helpers.instance_variable_get("@autorefresh")).to eq(true)
      expect(helpers.instance_variable_get("@title")).to eq({"en"=>"Foo Bar"})
      expect(helpers.instance_variable_get("@description")).to eq({})
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

    it 'gets metadata' do
      MetricMetadata.create(
        name: 'my-cool-metric',
        type: 'pie',
        title: {
          en: 'My title'
        },
        description: {
          en: 'Description'
        }
      )

      helpers.get_settings({
        'metric' => 'my-cool-metric'
      }, {})

      expect(helpers.instance_variable_get("@type")).to eq('pie')
      expect(helpers.instance_variable_get("@title")).to eq({'en' => 'My title'})
      expect(helpers.instance_variable_get("@description")).to eq({'en' => 'Description'})
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

  it 'extracts a title from a slug' do
    expect(helpers.title_from_slug('certificated-datasets')).to eq('Certificated Datasets')
  end

  it 'gets a title from the params' do
    expect(helpers.title_from_slug_or_params({'title' => 'Here%20is%20my%20title'})).to eq('Here is my title')
  end

  it 'gets a the default if title is blank' do
    expect(helpers.title_from_slug_or_params({'title' => '', 'metric' => 'certificated-datasets'})).to eq('Certificated Datasets')
  end

  it 'strips out anything dodgy' do
    expect(helpers.title_from_slug_or_params({'title' => '%3Cscript%3Ealert(%22Pwopa%20nawty%22)%3C%2Fscript%3E', 'metric' => 'certificated-datasets'})).to eq('Certificated Datasets')
  end

  describe '#extract_query_string' do
    it 'chops-up a query string' do
      expect(helpers.extract_query_string 'type=target&boxcolour=fa8100').to eq (
        {
          'type' => 'target',
          'boxcolour' => 'fa8100'
        }
      )
    end

    it 'can exclude a param' do
      expect(helpers.extract_query_string 'type=target&boxcolour=fa8100', exclude: 'type').to eq (
        {
          'boxcolour' => 'fa8100'
        }
      )
    end
  end

  describe '#sanitise_params' do
    it 'keeps only the keys we care about' do
      expect(helpers.sanitise_params({
        "type"=>"chart",
        "boxcolour"=>"fa8100",
        "oldest"=>"2015-11-09 14:26:37",
        "newest"=>"2016-02-01 12:27:39",
        "splat"=>[],
        "captures"=>["github-forks", "2016-01-31T14:26:37+00:00", "2016-03-01T14:26:37+00:00"],
        "metric"=>"github-forks",
        "from"=>"2016-01-31T14:26:37+00:00",
        "to"=>"2016-03-01T14:26:37+00:00"
      })).to eq 'type=chart&boxcolour=fa8100'

  #    expect(helpers.sanitise_query_string 'type=chart&oldest=2015-11-09 14:26:37&boxcolour=fa8100&metric=derp').to eq (
  #      'type=chart&boxcolour=fa8100'
  #    )
    end
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
      metadata = MetricMetadata.create(name: 'my-cool-metric', type: 'pie')
      expect(helpers.visualisation_type('pie', data)).to eq('pie')
    end

    it 'when a default does not exist' do
      expect(helpers.visualisation_type(nil, data)).to eq('chart')
    end

    it 'when a default does not exist, but metadata does' do
      MetricMetadata.create(name: 'my-cool-metric', name: { en: "Foo Bar"})
      expect(helpers.visualisation_type(nil, data)).to eq('chart')
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

    it 'for geodata' do
      data = {
        time: "2016-02-02T00:27:38.000+00:00",
        value: {
          type: "FeatureCollection",
          features: [
            {
              type: "Feature",
              geometry: {
                type: "Point",
                coordinates: [112, 0.7]
              },
              properties: {
                prop0: "value0"
              }
            },
            {
              type: "Feature",
              geometry: {
                type: "Point",
                coordinates: [102, 0.5]
              },
              properties: {
                prop0: "value0"
              }
            },
            {
              type: "Feature",
              geometry: {
                type: "Point",
                coordinates: [112, 0.8]
              },
              properties: {
                prop0: "value0"
              }
            }
          ]
        }
      }

      expect(helpers.guess_type data).to eq('map')
    end

  end

  context 'with a request' do

    before(:each) do
      # Monkey patch `request` method here - in the context of the app, it would be available
      class TestHelper
        def request
        end
      end

      allow(helpers).to receive(:request) {
        double = instance_double(Rack::Request)
        allow(double).to receive(:scheme) { 'http' }
        allow(double).to receive(:host_with_port) { 'example.org' }
        allow(double).to receive(:path) { '/metrics/my-awesome-metric/2016-02-02T09:27:29+00:00/2016-03-03T09:27:29+00:00' }
        allow(double).to receive(:params) { {foo: 'bar', baz: 'foo'} }
        double
      }
    end

    let(:url) { 'http://example.org/metrics/my-awesome-metric/2016-02-02T09:27:29+00:00/2016-03-03T09:27:29+00:00?baz=foo&foo=bar&layout=bare' }

    it 'generates an embed url' do
      expect(helpers.embed_url).to eq(url)
    end

    it 'generates an embed iframe' do
      expect(helpers.embed_iframe).to eq("<iframe src='#{url}' width='100%' height='100%' frameBorder='0' scrolling='no'></iframe>")
    end

    it 'allows additional params' do
      expect(helpers.embed_url(parma: 'ham')).to eq(url + "&parma=ham")
    end

    it 'adds additional params to an embed iframe' do
      expect(helpers.embed_iframe(parma: 'ham')).to eq("<iframe src='#{url + "&parma=ham"}' width='100%' height='100%' frameBorder='0' scrolling='no'></iframe>")
    end

  end

  context 'checks whether to display a single date or a range' do

    it 'data is a simple value' do
      data = 123
      expect(helpers.single? data, nil).to eq(false)
    end

    it 'data is a target' do
      data = {
        "actual" => 1091000,
        "annual_target" => 2862000,
        "ytd_target" => 1368000
      }

      expect(helpers.single? data, nil).to eq(true)
    end

    it 'data has multiple values' do
      data = {
        "total": {
          "value1" => 123,
          "value2" => 23213,
          "value4" => 1235
        }
      }

      expect(helpers.single? data, nil).to eq(true)
    end

    it 'data is a task list' do
      data = [
        {
          "id" => "512211cc788c2d8d110074a9",
          "title" => "Embed 2 processes with ODI standards",
          "due" => "2013-03-31T11:00:00Z",
          "progress" => 1,
          "no_checklist"  => false
        }
      ]
    end

    it 'data has an override' do
      data = 123
      expect(helpers.single? data, 'single').to eq(true)
    end

  end

  context 'gets the correct possible visualisation types' do

    it 'data is a simple value' do
      data = 123
      expect(helpers.get_alternatives data).to eq([
        'chart',
        'number'
      ])
    end

    it 'data is a target' do
      data = {
        "actual" => 1091000,
        "annual_target" => 2862000,
        "ytd_target" => 1368000
      }

      expect(helpers.get_alternatives data).to eq([
        'chart',
        'number',
        'target'
      ])
    end

    it 'data has multiple values' do
      data = {
        "total": {
          "value1" => 123,
          "value2" => 23213,
          "value4" => 1235
        }
      }

      expect(helpers.get_alternatives data).to eq([
        'chart',
        'number',
        'pie'
      ])
    end

    it 'data is a task list' do
      data = [
        {
          "id" => "512211cc788c2d8d110074a9",
          "title" => "Embed 2 processes with ODI standards",
          "due" => "2013-03-31T11:00:00Z",
          "progress" => 1,
          "no_checklist"  => false
        }
      ]

      expect(helpers.get_alternatives data).to eq([
        'tasklist'
      ])
    end

    it 'data is geodata' do
      data = {
        type: "FeatureCollection",
        features: [
          {
            type: "Feature",
            geometry: {
              type: "Point",
              coordinates: [112, 0.7]
            },
            properties: {
              prop0: "value0"
            }
          },
          {
            type: "Feature",
            geometry: {
              type: "Point",
              coordinates: [102, 0.5]
            },
            properties: {
              prop0: "value0"
            }
          },
          {
            type: "Feature",
            geometry: {
              type: "Point",
              coordinates: [112, 0.8]
            },
            properties: {
              prop0: "value0"
            }
          }
        ]
      }

      expect(helpers.get_alternatives data).to eq([
        'map'
      ])
    end

  end

  context 'gets a title' do

    let(:metadata) { MetricMetadata.create(title: {"en" => "My Custom Title"}) }
    let(:params) {
      {
        'metric' => "my-original-title"
      }
    }

    it 'with metadata' do
      expect(helpers.get_title(metadata, params)).to eq({"en" => "My Custom Title"})
    end

    it 'with blank metadata' do
      metadata = MetricMetadata.create
      expect(helpers.get_title(metadata, params)).to eq({"en" => "My Original Title"})
    end

    it 'with no metadata' do
      expect(helpers.get_title(nil, params)).to eq({"en" => "My Original Title"})
    end

  end

  it 'turns a list of colours into a JS array' do
    expect(helpers.fix_pie_colours '1d91a1:8cdbe6:faa2c7:').to eq (
      "['#1d91a1', '#8cdbe6', '#faa2c7']"
    )
  end

  it 'is fine with no pie colours' do
    expect(helpers.fix_pie_colours '').to eq '[]'
  end

  it 'builds a dashboard url' do
    metric = {
      name: 'foo-bar',
      date: 'my-date'
    }

    params = {
      layout: 'bare',
      boxcolour: 'abc123',
      textcolour: 'def345',
      title: 'my title',
      type: 'foo'
    }

    url = helpers.dashboard_url(metric[:name], metric[:date], params)

    expect(url).to eq('/metrics/foo-bar/my-date?boxcolour=abc123&layout=bare&textcolour=def345&title=my+title&type=foo')
  end

end
