# SearchMacAddress
SearchMacAddress helps you discover the IP addresses available on the current machine. It works in Ruby and Ruby on Rails applications and is designed to behave consistently on macOS, Linux, and Windows.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'search_mac_address'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install search_mac_address

## Usage

To get the list of usable IP addresses available on your system:
```
SearchMacAddress::Filter.all_addr
```

You can also call the more explicit method name:
```
SearchMacAddress::Filter.all_ip_addr
```

To get the primary IP address of your system:
```
SearchMacAddress::Filter.ip_addr
```

The legacy method below is still supported for backward compatibility and now returns the primary IP address:
```
SearchMacAddress::Filter.mac_addr
```

To get an encoded version of the primary IP address:
```
SearchMacAddress::Filter.encode
```

To decode the encoded IP address, supply encoded data to `decode()`:
```
SearchMacAddress::Filter.decode(encoded_addr)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/userrails/search-mac-address. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SearchMacAddress project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/userrails/search-mac-address/blob/master/CODE_OF_CONDUCT.md).
