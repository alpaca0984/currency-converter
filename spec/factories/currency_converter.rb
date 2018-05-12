FactoryBot.define do
  factory :currency_converter do
    api_app_id Config::Secrets.openexchangerates_app_id
    date '2017-02-22'
    amount_in_currency_from 10_000
    currency_from 'JPY'
    currency_to 'AUD'
  end
end
