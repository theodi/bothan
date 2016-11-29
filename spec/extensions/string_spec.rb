describe String do
  it 'titleises a string' do
    expect('some string'.titleise).to eq 'Some String'
  end

  it 'recognises a duration' do
    expect('P3Y6M4DT12H30M5S'.is_duration?).to eq true
    expect('just_some_random_guff'.is_duration?).to eq false
  end

  it 'renders a duration' do
    expect('P3Y6M4DT12H30M5S'.to_seconds).to be_a Numeric
    expect('P3Y6M4DT12H30M5S'.to_seconds).to eq 110766605.0
  end
end
