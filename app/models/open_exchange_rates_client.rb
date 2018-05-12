# frozen_string_literal: true

class OpenExchangeRatesClient
  include ActiveModel::Validations
  include ActiveModel::Attributes

  attribute :app_id, :string

  validates :app_id, presence: true

  def base_url
    URI::HTTPS.build(
      host: 'openexchangerates.org',
      path: '/api'.dup # to append further strings later
    )
  end

  def fetch_currencies
    currencies_url = base_url.tap do |url|
      url.path << '/currencies.json'
    end
    Net::HTTP.get(currencies_url)
  end

  # TODO: check having app_id
  def fetch_historical_for(date:)
    validate!
    historical_url = base_url.tap do |url|
      url.path << "/historical/#{date.to_date.strftime('%F')}.json"
      url.query = "app_id=#{app_id}"
    end
    Net::HTTP.get(historical_url)
  end
end
