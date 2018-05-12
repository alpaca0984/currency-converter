# frozen_string_literal: true

require 'pry'

require './boot.rb'

RSpec.describe OpenExchangeRatesClient do
  describe '#validate!' do
    subject { client.validate! }

    context 'with valid parameters' do
      let(:client) { build(:open_exchange_rates_client) }
      it { expect { subject }.not_to raise_error }
    end

    context 'without app_id' do
      let(:client) { build(:open_exchange_rates_client, app_id: '') }
      it { expect { subject }.to raise_error(ActiveModel::ValidationError, /App can't be blank/) }
    end
  end
end
