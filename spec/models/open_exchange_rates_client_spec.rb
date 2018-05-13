# frozen_string_literal: true

require './boot.rb'

RSpec.describe OpenExchangeRatesClient do
  describe '#errors' do
    subject { client.tap(&:valid?).errors.to_h }

    context 'with valid parameters' do
      let(:client) { build(:open_exchange_rates_client) }
      it { is_expected.to be_empty }
    end

    context 'without app_id' do
      let(:client) { build(:open_exchange_rates_client, app_id: '') }
      it { is_expected.to include(app_id: "can't be blank") }
    end
  end
end
