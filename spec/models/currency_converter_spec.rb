# frozen_string_literal: true

require 'pry'

require './boot.rb'

RSpec.describe CurrencyConverter do
  describe '#validate!' do
    subject { converter.validate! }

    context 'with valid attributes' do
      let(:converter) { build(:currency_converter) }
      it { expect { subject }.not_to raise_error }
    end

    context 'with date which is in the future' do
      let(:converter) { build(:currency_converter, date: Date.tomorrow) }
      it { expect { subject }.to raise_error(ActiveModel::ValidationError, /Date can't be in the future/) }
    end

    context 'with amount_in_currency_from which is 0' do
      let(:converter) { build(:currency_converter, amount_in_currency_from: 0) }
      it { expect { subject }.to raise_error(ActiveModel::ValidationError, /Amount in currency from must be greater than 0/) }
    end

    context 'with currency_from which is not in the currencies list' do
      let(:converter) { build(:currency_converter, currency_from: 'FOOBAR') }
      it { expect { subject }.to raise_error(ActiveModel::ValidationError, /Currency from is not included in the list/) }
    end

    context 'with currency_to which is not in the currencies list' do
      let(:converter) { build(:currency_converter, currency_to: 'FOOBAR') }
      it { expect { subject }.to raise_error(ActiveModel::ValidationError, /Currency to is not included in the list/) }
    end
  end

  describe '#convert' do
    subject { converter.convert }

    context 'the amount currency from 10,000 JPY to AUD at 2017-02-22' do
      let(:converter) { build(:currency_converter) }
      it { is_expected.to eq 114.56 }
    end
  end
end
