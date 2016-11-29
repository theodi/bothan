class ViewsHelpers
  include Bothan::Helpers::Views
end

describe Bothan::Helpers::Views do
  let(:helpers) { ViewsHelpers.new }

  describe '#title_from_slug' do
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

  describe '#dashboard_url' do
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

  context 'with a request' do

    before(:each) do
      # Monkey patch `request` method here - in the context of the app, it would be available
      class ViewsHelpers
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

    describe '#embed_url' do

      it 'generates an embed url' do
        expect(helpers.embed_url).to eq(url)
      end

      it 'allows additional params' do
        expect(helpers.embed_url(parma: 'ham')).to eq(url + "&parma=ham")
      end

    end

    describe '#embed_iframe' do

      it 'generates an embed iframe' do
        expect(helpers.embed_iframe).to eq("<iframe src='#{url}' width='100%' height='100%' frameBorder='0' scrolling='no'></iframe>")
      end

      it 'adds additional params to an embed iframe' do
        expect(helpers.embed_iframe(parma: 'ham')).to eq("<iframe src='#{url + "&parma=ham"}' width='100%' height='100%' frameBorder='0' scrolling='no'></iframe>")
      end

    end

  end

end
