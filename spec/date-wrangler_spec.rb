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

    it 'does not have errors' do
      expect(two_dates.errors).to be nil
    end
  end

  context 'a date and a duration' do
    let(:date_with_duration) { described_class.new '1966-07-30T15:00:00', 'PT2H15M' }

    it 'has a from date' do
      expect(date_with_duration.from).to be_a DateTime
      expect(date_with_duration.from).to eq '1966-07-30T15:00:00'
    end

    it 'has a to date' do
      expect(date_with_duration.to).to be_a DateTime
      expect(date_with_duration.to).to eq '1966-07-30T17:15:00'
    end

    it 'does not have errors' do
      expect(date_with_duration.errors).to be nil
    end
  end

  context 'a duration and a date' do
    let(:duration_with_date) { described_class.new 'P5Y349D', '1945-08-14T00:00:00' }

    it 'has a to date' do
      expect(duration_with_date.to).to be_a DateTime
      expect(duration_with_date.to).to eq '1945-08-14T00:00:00'
    end

    it 'has a from date' do
      expect(duration_with_date.from).to be_a DateTime
      expect(duration_with_date.from).to eq '1939-09-01T00:00:00'
    end

    it 'does not have errors' do
      expect(duration_with_date.errors).to be nil
    end
  end

  context 'wildcards' do
    let(:wildcard) { described_class.new '1970-01-01T00:00:00', '*' }

    it 'is fine with a *' do
      expect(wildcard.errors).to be nil
    end
  end

  context 'non-happy paths' do
    context 'bad durations' do
      let(:duration_bad) { described_class.new 'P24H', '1962-10-28T00:00:00' }

      it 'knows what a invalid duration is' do
        expect(duration_bad.errors).to be_an Array
        expect(duration_bad.errors.first).to eq "'P24H' is not a valid ISO8601 duration."
      end

      let(:bad_duration) { described_class.new '1962-10-16T00:00:00', 'P36H' }

      it 'knows what a invalid duration is' do
        expect(bad_duration.errors).to be_an Array
        expect(bad_duration.errors.first).to eq "'P36H' is not a valid ISO8601 duration."
      end
    end

    context 'bad datetimes' do
      let(:bad_datetime) { described_class.new 'grassy-knoll', '1963-11-22T12:30:00-06:00' }

      it 'recognises a duff date' do
        expect(bad_datetime.errors).to be_an Array
        expect(bad_datetime.errors.first).to eq "'grassy-knoll' is not a valid ISO8601 date/time."
        expect(bad_datetime.errors.count).to eq 1
      end

      let(:bad_datetimes) { described_class.new 'bad', 'worse' }

      it 'knows both dates are duff' do
        expect(bad_datetimes.errors).to be_an Array
        expect(bad_datetimes.errors.first).to eq "'bad' is not a valid ISO8601 date/time."
        expect(bad_datetimes.errors[1]).to eq "'worse' is not a valid ISO8601 date/time."
      end
    end

    context 'end time before start time' do
      let(:future_before_past) { described_class.new '1985-10-26T01:21:00', '1955-11-12T06:38:00' }

      it 'objects to misordered dates' do
        expect(future_before_past.errors).to be_an Array
      end
    end
  end
end
