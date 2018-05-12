# frozen_string_literal: true

require_relative './open_exchange_rates_client'

class CurrencyConverter
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :date, :date
  attribute :amount_in_currency_from, :decimal
  attribute :currency_from, :string
  attribute :currency_to, :string

  # used in validations
  def self.currencies
    @currencies ||= JSON.parse(OpenExchangeRatesClient.new.fetch_currencies)
  end

  validates :date, presence: true
  validates :amount_in_currency_from, numericality: { greater_than: 0 }
  validates :currency_from, :currency_to, inclusion: { in: currencies.keys }
  validate :date_cannot_be_in_the_future

  def api_app_id=(app_id)
    api_client.app_id = app_id
  end

  def convert!
    validate!

    ratio_mapping = JSON.parse(api_client.fetch_historical_for(date: date))
    if ratio_mapping.key?('error')
      raise RuntimeError, ratio_mapping['description']
    end

    rates = ratio_mapping['rates']
    (rates[currency_to] / rates[currency_from] * amount_in_currency_from).floor(2)
  end

  def convert
    convert!
  rescue StandardError => e
    # TODO: use `e` for handling errors
    nil
  end

  def api_client
    @api_client ||= OpenExchangeRatesClient.new
  end

  private

  def date_cannot_be_in_the_future
    if date.present? && Date.today < date
      errors.add(:date, "Date can't be in the future")
    end
  end
end
