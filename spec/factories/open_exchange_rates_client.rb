FactoryBot.define do
  factory :open_exchange_rates_client do
    app_id Config::Secrets.openexchangerates_app_id
  end
end
