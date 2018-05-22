# frozen_string_literal: true

class OpenExchangeRatesClient
  include ActiveModel::Validations
  include ActiveModel::Attributes

  DEFAULT_HTTP_ATTRIBUTES = { use_ssl: true }.freeze

  attribute :app_id, :string

  validates :app_id, presence: true

  def base_url
    URI::HTTPS.build(
      host: 'openexchangerates.org',
      path: +'/api' # to append further path later
    )
  end

  def fetch_currencies(**options)
    currencies_url = base_url.tap do |url|
      url.path << '/currencies.json'
    end
    fetch(currencies_url, options)
  end

  def fetch_historical_for(date:, **options)
    validate!
    historical_url = base_url.tap do |url|
      url.path << "/historical/#{date.to_date.strftime('%F')}.json"
      url.query = "app_id=#{app_id}"
    end
    fetch(historical_url, options)
  end

  private

  def fetch(uri, **options)
    result = perform do
      http_attributes = DEFAULT_HTTP_ATTRIBUTES.merge(options.symbolize_keys)
      Net::HTTP.start(uri.host, uri.port, http_attributes) do |http|
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
