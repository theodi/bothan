describe DateWrangler do
  context 'two cromulent dates' do
    let(:two_dates) { described_class.new '1903-12-17T10:35:00', '1969-07-20T20:17:00' }

    it 'has a from date' do
      expect(two_dates.from).to be_a DateTime
      expect(two_dates.from).to eq '1903-12-17T10:35:00'
    end

    it 'has a to date' do
      expect(two_dates.to).to be_a DateTime
      expect(two_dates.to).to eq '1969-07-20T20:17:00'
    end
  end

  context 'a date and a duration' do
    let(:date_with_duration) { described_class.new '1966-07-30T15:00:00', 'PH2M15' }

    it 'has a from date' do
      expect(date_with_duration.from).to be_a DateTime
      expect(date_with_duration.from).to eq '1966-07-30T15:00:00'
    end

    it 'has a to date'
  end
end
