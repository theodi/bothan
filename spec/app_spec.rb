describe MetricsApi do

  context 'sets the correct visualisation types' do

    it 'with a single metric type' do
      Metric.create(
        name: "simple-metric",
        time: DateTime.now - 1,
        value: rand(100)
      )

      get '/metrics/simple-metric'
      follow_redirect!

      body = Nokogiri::HTML(last_response.body)
      types = body.css('#types input')

      expect(types.count).to eq(2)
      expect(types[0][:value]).to eq('chart')
      expect(types[1][:value]).to eq('number')
    end

    it 'with a target type' do
      Metric.create(
        name: "metric-with-target",
        time: DateTime.now - 1,
        value: {
          actual: rand(100),
          annual_target: rand(1000)
        }
      )

      get '/metrics/metric-with-target'
      follow_redirect!

      body = Nokogiri::HTML(last_response.body)
      types = body.css('#types input')

      expect(types.count).to eq(3)
      expect(types[0][:value]).to eq('chart')
      expect(types[1][:value]).to eq('number')
      expect(types[2][:value]).to eq('target')
    end

    it 'with multiple values' do
      Metric.create(
        name: "metric-with-multiple-values",
        time: DateTime.now - 1,
        value: {
          total: {
            value1: rand(100),
            value2: rand(100),
            value3: rand(100),
            value4: rand(100),
          }
        }
      )

      get '/metrics/metric-with-multiple-values'
      follow_redirect!

      body = Nokogiri::HTML(last_response.body)
      types = body.css('#types input')

      expect(types.count).to eq(3)
      expect(types[0][:value]).to eq('chart')
      expect(types[1][:value]).to eq('number')
      expect(types[2][:value]).to eq('pie')
    end

    it 'with a tasklist' do
      Metric.create(
        name: "metric-with-tasklist",
        time: DateTime.now - 1,
        value: [
          {
            "id" => "512211cc788c2d8d110074a9",
            "title" => "Embed 2 processes with ODI standards",
            "due" => "2013-03-31T11:00:00Z",
            "progress" => 1,
            "no_checklist"  => false
          }
        ]
      )

      get '/metrics/metric-with-tasklist'
      follow_redirect!

      body = Nokogiri::HTML(last_response.body)
      types = body.css('#types input')

      expect(types.count).to eq(1)
      expect(types[0][:value]).to eq('tasklist')
    end

  end

  context 'redirects to dates correctly' do

    before(:each) do
      Metric.create(
        name: "simple-metric",
        time: DateTime.parse("2016-01-02T00:00:00Z"),
        value: rand(100)
      )
    end

    context 'from a date range' do
      let(:base_url) { '/metrics/simple-metric/2014-01-01T16:00:00+01:00/2014-01-12T16:00:00+00:00' }

      it 'with to and from dates' do
        get "#{base_url}?oldest=2016-01-01T16:00:00Z&newest=2016-01-12T16:00:00Z"
        follow_redirect!

        expect(last_request.url).to eq 'http://example.org/metrics/simple-metric/2016-01-01T16:00:00+00:00/2016-01-12T16:00:00+00:00'
      end

      it 'with from date' do
        get "#{base_url}?oldest=2016-01-01T16:00:00Z"
        follow_redirect!

        expect(last_request.url).to eq 'http://example.org/metrics/simple-metric/2016-01-01T16:00:00+00:00'
      end
    end

    context 'from a single date' do
      let(:base_url) { '/metrics/simple-metric/2014-01-01T16:00:00+01:00' }

      it 'with to and from dates' do
        get "#{base_url}?oldest=2016-01-01T16:00:00Z&newest=2016-01-12T16:00:00Z"
        follow_redirect!

        expect(last_request.url).to eq 'http://example.org/metrics/simple-metric/2016-01-01T16:00:00+00:00/2016-01-12T16:00:00+00:00'
      end

      it 'with from date' do
        get "#{base_url}?oldest=2016-01-01T16:00:00Z"
        follow_redirect!

        expect(last_request.url).to eq 'http://example.org/metrics/simple-metric/2016-01-01T16:00:00+00:00'
      end
    end

  end

end
