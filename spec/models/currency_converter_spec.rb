# frozen_string_literal: true

require './boot.rb'

RSpec::Matchers.define_negated_matcher :have_items, :be_empty

RSpec.describe CurrencyConverter do
  describe '#errors' do
    subject { converter.tap(&:valid?).errors.to_h }

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

    context 'with currency_from which is not in the currencies list' do
      let(:converter) { build(:currency_converter, currency_from: 'FoO') }
      it { is_expected.to include(currency_from: 'accepts only three charactors of upper case') }
    end

    context 'with currency_to which is not in the currencies list' do
      let(:converter) { build(:currency_converter, currency_to: 'FOO') }
      it { is_expected.to include(currency_to: 'must be valid one') }
    end
  end

  describe '.currencies' do
    subject { CurrencyConverter.currencies }
    let(:client) { class_double(OpenExchangeRatesClient).as_stubbed_const }
    before(:each) { CurrencyConverter.instance_variable_set('@currencies', nil) }

    context 'when OpenExchangeRatesClient has fetched result' do
      before { allow(client).to receive_message_chain(:new, :fetch_currencies).and_return({ 'JPY' => 100 }.to_json) }
      it { is_expected.to be_a(Hash).and have_items }
    end

    context "when OpenExchangeRatesClient hasn't fetched result" do
      before { allow(client).to receive_message_chain(:new, :fetch_currencies).and_return(nil) }
      it { expect { subject }.to raise_error(TypeError, /no implicit conversion.*into String/) }
    end
  end

  describe '#convert!' do
    subject { converter.convert! }

    context 'the amount currency from 10,000 JPY to AUD at 2017-02-22' do
      let(:converter) { build(:currency_converter, date: '2017-02-22', amount_in_currency_from: 10_000, currency_from: 'JPY', currency_to: 'AUD') }
      it { is_expected.to eq(114.56) }
    end
  end
end
