require 'net/http'
require 'json'
require 'date'

class OpenExchangeRatesClient
  attr_writer :app_id

  def base_url
    URI::HTTPS.build(
      host: 'openexchangerates.org',
      path: '/api'
    )
  end

  def fetch_currencies
    currencies_url = base_url.tap do |url|
      url.path << '/currencies.json'
    end
    Net::HTTP.get(currencies_url)
  end

  # TODO: check having @app_id
  def fetch_historical_for(date:)
    historical_url = base_url.tap do |url|
      url.path << "/historical/#{date}.json"
      url.query = "app_id=#{@app_id}"
    end
    Net::HTTP.get(historical_url)
  end
end

class CurrencyConverter
  attr_reader :errors
  attr_writer :date, :amount_in_currency_from, :currency_from, :currency_to

  def initialize(api_app_id:, date: nil, amount_in_currency_from: nil, currency_from: nil, currency_to: nil)
    @apiClient = OpenExchangeRatesClient.new
    @apiClient.app_id = api_app_id

    @date = date
    @amount_in_currency_from = amount_in_currency_from
    @currency_from = currency_from
    @currency_to = currency_to
  end

  def convert
    validate!

    ratio_mapping = JSON.parse(@apiClient.fetch_historical_for(date: @date))
    if ratio_mapping.has_key?('error')
      raise RuntimeError.new(ratio_mapping['description'])
    end

    rates = ratio_mapping['rates']
    (rates[@currency_to] / rates[@currency_from] * @amount_in_currency_from).floor(2)
  end

  def validate!
    errors = {}

    unless (Date.parse(@date) rescue false)
      errors.store(:date, "Invalid date `#{@date}`")
    end

    currencies = JSON.parse(@apiClient.fetch_currencies)
    { currency_from: @currency_from, currency_to: @currency_to }.each do |attr_name, currency|
      unless currencies.has_key?(currency)
        errors.store(attr_name, "Invalid currency #{currency}")
      end
    end

    if @amount_in_currency_from < 0
      errors.store(:attr_name, "Amount is less than 0")
    end

    unless errors.empty?
      raise ArgumentError.new(errors)
    end
  end
end
