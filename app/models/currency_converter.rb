class OpenExchangeRatesClient
  include ActiveModel::Validations
  include ActiveModel::Attributes

  attribute :app_id, :string

  validates :app_id, presence: true

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

  # TODO: check having app_id
  def fetch_historical_for(date:)
    validate!
    historical_url = base_url.tap do |url|
      url.path << "/historical/#{date}.json"
      url.query = "app_id=#{app_id}"
    end
    Net::HTTP.get(historical_url)
  end
end

class CurrencyConverter
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :date
  attribute :amount_in_currency_from, :integer
  attribute :currency_from, :string
  attribute :currency_to, :string

  # used in validations
  def self.currencies
    @currencies ||= JSON.parse(OpenExchangeRatesClient.new.fetch_currencies)
  end

  validates :date, presence: true
  validates :amount_in_currency_from, numericality: { only_integer: true, greater_than: 0 }
  validates :currency_from, :currency_to, inclusion: { in: currencies.keys }
  validate :date_cannot_be_in_the_future

  def api_client
    @api_client ||= OpenExchangeRatesClient.new
  end

  def api_app_id=(app_id)
    api_client.app_id = app_id
  end

  def convert
    validate!

    ratio_mapping = JSON.parse(api_client.fetch_historical_for(date: date))
    if ratio_mapping.has_key?('error')
      raise RuntimeError.new(ratio_mapping['description'])
    end

    rates = ratio_mapping['rates']
    (rates[currency_to] / rates[currency_from] * amount_in_currency_from).floor(2)
  end

  # check if `date` has valid format in the same time
  def date_cannot_be_in_the_future
    date_obj = date.acts_like?(:date) ? date : date.to_date
    if Date.today < date_obj
      raise ArgumentError, 'date cannot be in the future'
    end
  rescue Exception => e
    errors.add(:date, e.message)
  end
end
