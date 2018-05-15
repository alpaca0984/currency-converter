# frozen_string_literal: true

require_relative './open_exchange_rates_client'

class CurrencyConverter
  include ActiveModel::Model
  include ActiveModel::Attributes

  VALID_CURRENCY_FORMAT = /\A[A-Z]{3}\z/

  attribute :date, :date
  attribute :amount_in_currency_from, :decimal
  attribute :currency_from, :string
  attribute :currency_to, :string

  validates :date, presence: true
  validates :amount_in_currency_from, numericality: { greater_than: 0 }
  validates :currency_from, :currency_to,
    format: { with: VALID_CURRENCY_FORMAT, message: 'accepts only three charactors of upper case' }
  validate :date_cannot_be_in_the_future, :currencies_must_be_valid_one

  delegate :currencies, to: :class

  class ConversionError < ::StandardError; end

  def self.currencies
    @currencies ||= JSON.parse(OpenExchangeRatesClient.new.fetch_currencies)
  end

  def api_app_id=(app_id)
    api_client.app_id = app_id
  end

  def convert!
    validate!

    ratio_mapping = JSON.parse(api_client.fetch_historical_for(date: date))
    if ratio_mapping.key?('error')
      raise ConversionError, ratio_mapping['description']
    end

    rates = ratio_mapping['rates']
    nonexist_currencies = [currency_from, currency_to].reject { |ccy| rates.key?(ccy) }
    if nonexist_currencies.present?
      raise ConversionError, "Rates didn't exist for #{nonexist_currencies.join(', ')} at #{date}"
    end

    (rates[currency_to].to_d / rates[currency_from].to_d * amount_in_currency_from).floor(2).to_f
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
    if date.present? && (Date.today < date)
      errors.add(:date, "can't be in the future")
    end
  end

  def currencies_must_be_valid_one
    %i[currency_from currency_to].each do |attr_name|
      value = public_send(attr_name).to_s
      if value.match?(VALID_CURRENCY_FORMAT) && !currencies.key?(value)
        errors.add(attr_name, 'must be valid one')
      end
    end
  end
end
