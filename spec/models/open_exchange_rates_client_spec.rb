# frozen_string_literal: true

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

  describe '#fetch_currencies' do
    subject { client.fetch_currencies }
    let(:net_http_mock) { class_double(Net::HTTP).as_stubbed_const }
    let(:client) { build(:open_exchange_rates_client) }

    context 'when fetched currencies data' do
      let(:currencies_json) { load_json('currencies') }
      before { allow(net_http_mock).to receive(:start).and_return(currencies_json) }
      it { is_expected.to eq(currencies_json) }
    end

    context 'when Timeout::Error is raised' do
      before { allow(net_http_mock).to receive(:start).and_raise(Timeout::Error) }
      it { is_expected.to eq({}.to_json) }
    end

    context 'when Net::HTTPServerException is raised' do
      before { allow(net_http_mock).to receive(:start).and_raise(Net::HTTPServerException.new('1.1', 503)) }
      it { is_expected.to eq({}.to_json) }
    end

    context 'when RuntimeError is raised' do
      before { allow(net_http_mock).to receive(:start).and_raise(RuntimeError) }
      it { expect { subject }.to raise_error(RuntimeError) }
    end
  end
end
