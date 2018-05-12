# frozen_string_literal: true

require 'pry'

require './boot.rb'

RSpec.describe OpenExchangeRatesClient do
  let(:client) { OpenExchangeRatesClient.new }

  describe '#validate!' do
    subject { client.validate! }

    context "without app_id" do
      before { client.app_id = '' }
      it { expect { subject }.to raise_error(ActiveModel::ValidationError, /App can't be blank/) }
    end
  end
end
