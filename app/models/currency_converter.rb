require_relative './open_exchange_rates_client'

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
