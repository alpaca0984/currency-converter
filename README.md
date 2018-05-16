# Currency Converter

This takes exchange ratios from https://openexchangerates.org and convert from different currencies.

- [Currency Converter](#currency-converter)
    - [Usage](#usage)
    - [Note](#note)
    - [Testing](#testing)
    - [My consideration](#my-consideration)
    - [Author](#author)

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

Finally, you can execute calculattion! Result is rounded down to the two decimal.
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

## Note

- Not deal with optional params of [historical api](https://docs.openexchangerates.org/docs/historical-json). It's only for paid plan.
- Past data of [historical api](https://docs.openexchangerates.org/docs/historical-json) will never change. You should cache the results

## Testing

These explains specifications of this library.
```console
$ bundle exec rspec spec/models/currency_converter_spec.rb
$ bundle exec rspec spec/models/open_exchange_rates_client_spec.rb
```

## My consideration

__Accuracy__

- Used decimal to calculate exchange rates because because floats cannot accurately represent the base 10 multiples that we use for money
    - It's explained [here](https://stackoverflow.com/questions/3730019/why-not-use-double-or-float-to-represent-currency)
    - [RubyMoney](https://github.com/RubyMoney/money/blob/master/lib/money/money/arithmetic.rb#L178) also does so
- Wrote RSpec tests to assure specifications

__Maintenability__

- Used a cutting edge feature of activemodel: `ActiveModel::Attributes` to treat attributes strictly
- Used only necessary gems to keep this project simple
- In accordance with Rails file structure to transplant this scripts to Rails easily
- Applied the principle of single responsibility for classes

__Security__

- Validates parameters strictly with both built-in validator and custom validator
- Excluded api key from repository

__Performance__

- Use `frozen_string_literal: true` in general and unfreeze string as needed.
    - @see https://github.com/bbatsov/rubocop/blob/master/lib/rubocop/cop/performance/unfreeze_string.rb#L6
- Reducing api requests by validating parameters before calling

## Author

Masataka Hirano - [alpaca0984](https://github.com/alpaca0984)
