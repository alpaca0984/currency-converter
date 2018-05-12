# frozen_string_literal: true

require 'pry'

require './boot.rb'

RSpec.describe CurrencyConverter do
  let(:converter) { CurrencyConverter.new }
  let(:base_attributes) do
    {
      api_app_id: Config::Secrets.openexchangerates_app_id,
      date: '2017-02-22',
      amount_in_currency_from: 10_000,
      currency_from: 'JPY',
      currency_to: 'AUD'
    }
  end

  describe '#validate!' do
    subject { converter.validate! }

    context 'with valid attributes' do
      before { converter.attributes = base_attributes }
      it { expect { subject }.not_to raise_error }
    end

    context 'with date which is in the future' do
      before { converter.attributes = base_attributes.merge(date: Date.tomorrow) }
      it { expect { subject }.to raise_error(ActiveModel::ValidationError, /Date can't be in the future/) }
    end

    context 'with amount_in_currency_from which is 0' do
      before { converter.attributes = base_attributes.merge(amount_in_currency_from: 0) }
      it { expect { subject }.to raise_error(ActiveModel::ValidationError, /Amount in currency from must be greater than 0/) }
    end

    context 'with currency_from which is not in the currencies list' do
      before { converter.attributes = base_attributes.merge(currency_from: 'FOOBAR') }
      it { expect { subject }.to raise_error(ActiveModel::ValidationError, /Currency from is not included in the list/) }
    end

    context 'with currency_to which is not in the currencies list' do
      before { converter.attributes = base_attributes.merge(currency_to: 'FOOBAR') }
      it { expect { subject }.to raise_error(ActiveModel::ValidationError, /Currency to is not included in the list/) }
    end
  end

  describe '#convert' do
    subject { converter.convert }

    context 'the amount currency from 10,000 JPY to AUD at 2017-02-22' do
      before { converter.attributes = base_attributes }
      it { is_expected.to eq 114.56 }
    end
  end
end
