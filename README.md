
# Currency Converter

This takes exchange ratios from https://openexchangerates.org and convert from different currencies.

## Usage

First, clone this repository and install ruby gems.
```console
$ git clone git@github.com:alpaca0984/currency-converter.git
$ cd currency-converter
$ bundle install --path vendor/bundle
```

And then, set your app_id to config/secret.rb
```
$ mv config/secret.rb.temp config/secret.rb
$ vim config/secret.rb
```

Finally, you can execute calculattion!
```ruby
converter = CurrencyConverter.new(
  api_app_id: Config::Secrets.openexchangerates_app_id,
  date: '2017-02-22',
  amount_in_currency_from: 10_000,
  currency_from: 'JPY',
  currency_to: 'AUD'
)
converter.convert
# returns 114.56
```

## Questions

- [ ] What is response: `amount_in_currency_to` be expected?
    - in [historical data](https://docs.openexchangerates.org/docs/historical-json), most currencies ratio have six decimal place. So how about rounding down the result to the six decimal place?
- [ ] How should I treat errors?
    - This script has various types of errors, like ArgumentError, Net::HTTPError.
- [ ] Are they changeable, past historical ratio data of openexchangerates.org?
    - If not, I'm going to cache them somewhere for reducing api requests.

## Specification

### Response

- date: String|Date
- amount_in_currency_from: BigDecimal
- currency_from: String
- currency_to: String

### Caching

TODO: implement

It's for reducing api accesses(maximum of 1000 requests/month to openexchangerates.org).

Tasks
- [ ] determine what types cache do I use
    - file store(ActiveSupport::Cache::FileStore)
    - memory store(ActiveSupport::Cache::MemoryStore)
    - Redis etc..
- [ ] determine expiration time
    - 30 minutes?
    - 1 hour?
    - purge at 00:00:00 every day? etc..[]

## Testing

```console
$ bundle exec rspec spec/models/currency_converter_spec.rb
```

## Author

Masataka Hirano - [alpaca0984](https://github.com/alpaca0984)
