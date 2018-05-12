# frozen_string_literal: true

require 'spec_helper'
require 'pry'

require './boot.rb'

RSpec.describe CurrencyConverter do
  context 'from 10,000 JPY to AUD at 2017-02-22' do
    it 'returns 114.56' do
      converter = CurrencyConverter.new(
        api_app_id: Config::Secrets.openexchangerates_app_id,
        date: '2017-02-22',
        amount_in_currency_from: 10_000,
        currency_from: 'JPY',
        currency_to: 'AUD'
      )
      expect(converter.convert!).to eq(114.56)
    end
  end
end
