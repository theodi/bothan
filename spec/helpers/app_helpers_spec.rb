class AppHelpers
  include Bothan::Helpers::App
end

describe Bothan::Helpers::App do
  let(:helpers) { AppHelpers.new }

  it 'gets a image url for a creative commons license' do
    image = helpers.license_image('https://creativecommons.org/licenses/cc-by/4.0/')
    expect(image).to eq('https://licensebuttons.net/l/cc-by/4.0/88x31.png')
  end

  it 'returns nil for a non cc license' do
    image = helpers.license_image('http://www.opendefinition.org/licenses/against-drm')
    expect(image).to eq(nil)
  end

end
