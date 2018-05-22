# frozen_string_literal: true

class OpenExchangeRatesClient
  include ActiveModel::Validations
  include ActiveModel::Attributes

  attribute :app_id, :string

  validates :app_id, presence: true

  def base_url
    URI::HTTPS.build(
      host: 'openexchangerates.org',
      path: +'/api' # to append further path later
    )
  end

  def fetch_currencies
    currencies_url = base_url.tap do |url|
      url.path << '/currencies.json'
    end
    fetch(currencies_url)
  end

  def fetch_historical_for(date:)
    validate!
    historical_url = base_url.tap do |url|
      url.path << "/historical/#{date.to_date.strftime('%F')}.json"
      url.query = "app_id=#{app_id}"
    end
    fetch(historical_url)
  end

  private

  def fetch(uri)
    result = perform do
      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Get.new(uri)
        response = http.request(request)
        response.value
        response.body
      end
    end
    result.is_a?(Exception) ? {}.to_json : result
  end
end

class OpenExchangeRatesClient
  concerning :Execution do
    include ActiveSupport::Rescuable

    included do
      rescue_from Timeout::Error, SocketError, with: :handle_network_error
      rescue_from Net::HTTPExceptions, with: :handle_net_http_error
    end

    def perform
      yield
    rescue Exception => exception
      rescue_with_handler(exception) || raise
    end

    # ----- error handling -----

    # TODO: implement handling error before deployment
    def handle_network_error(exception)
      # Rails.logger.error "#{exception.class}: #{exception.message}"
    end

    # TODO: implement handling error before deployment
    def handle_net_http_error(exception)
      # Rails.logger.error "#{exception.class}: #{exception.message}"
    end
  end
end
