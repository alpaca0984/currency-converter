# frozen_string_literal: true

RSpec.describe CurrencyConverter do
  describe '#errors' do
    subject { converter.tap(&:valid?).errors.to_h }
    before { allow(converter).to receive(:currencies).and_return(JSON.parse(load_json('currencies'))) }

    context 'with valid attributes' do
      let(:converter) { build(:currency_converter) }
      it { is_expected.to be_empty }
    end

    context 'with date which is in the future' do
      let(:converter) { build(:currency_converter, date: Date.tomorrow) }
      it { is_expected.to include(date: "can't be in the future") }
    end

    context 'with amount_in_currency_from which is 0' do
      let(:converter) { build(:currency_converter, amount_in_currency_from: 0) }
      it { is_expected.to include(amount_in_currency_from: 'must be greater than 0') }
    end

    context 'with currency_from which is FoO' do
      let(:converter) { build(:currency_converter, currency_from: 'FoO') }
      it { is_expected.to include(currency_from: 'accepts only three charactors of upper case') }
    end

    context 'with currency_to which is FOO' do
      let(:converter) { build(:currency_converter, currency_to: 'FOO') }
      it { is_expected.to include(currency_to: 'must be valid one') }
    end
  end

  describe '.currencies' do
    subject { CurrencyConverter.currencies }
    let(:client_klass) { class_double(OpenExchangeRatesClient).as_stubbed_const }
    before(:each) { CurrencyConverter.instance_variable_set('@currencies', nil) }

    context 'when OpenExchangeRatesClient has fetched result' do
      before { allow(client_klass).to receive_message_chain(:new, :fetch_currencies => load_json('2018-05-10')) }
      it { is_expected.to be_a(Hash) }
      it { is_expected.not_to be_empty }
    end

    context "when OpenExchangeRatesClient hasn't fetched result" do
      before { allow(client_klass).to receive_message_chain(:new, :fetch_currencies => nil) }
      it { expect { subject }.to raise_error(TypeError, /no implicit conversion .+ into String/) }
    end
  end

  describe '#convert!' do
    subject { converter.convert! }
    let(:client) { build(:open_exchange_rates_client) }
    before(:each) do
      allow(client).to receive(:fetch_historical_for).with(date: converter.date).and_return(load_json(converter.date.strftime('%F')))
      allow(converter).to receive(:api_client).and_return(client)
      allow(converter).to receive(:currencies).and_return(JSON.parse(load_json('currencies')))
    end

    context 'when convert 100 AUD to JPY at 2018-05-10' do
      let(:converter) do
        build(
          :currency_converter,
          date: '2018-05-10', amount_in_currency_from: 100, currency_from: 'AUD', currency_to: 'JPY'
        )
      end
      it { is_expected.to eq(8_236.39) }
    end

    context 'when convert 10,000 JPY to AUD at 2017-02-22' do
      let(:converter) do
        build(
          :currency_converter,
          date: '2017-02-22', amount_in_currency_from: 10_000, currency_from: 'JPY', currency_to: 'AUD'
        )
      end
      it { is_expected.to eq(114.56) }
    end

    context 'when convert 10,000 JPY to AUD at 1900-01-01' do
      let(:converter) { build(:currency_converter, date: '1900-01-01') }
      it { expect { subject }.to raise_error(CurrencyConverter::ConversionError,
        /Historical rates for the requested date are not available/) }
    end

    context 'when convert 10,000 JPY to ZWL at 2000-01-01' do
      let(:converter) do
        build(
          :currency_converter,
          date: '2000-01-01', amount_in_currency_from: 10_000, currency_from: 'JPY', currency_to: 'ZWL'
        )
      end
      it { expect { subject }.to raise_error(CurrencyConverter::ConversionError,
        /Rates didn't exist for ZWL at 2000-01-01/) }
    end
  end
end
