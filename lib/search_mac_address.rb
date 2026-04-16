require "search_mac_address/version"
require 'search_mac_address/addr_mac'
require "base64"

module SearchMacAddress
  class Filter
    class << self
      def all_ip_addr
        SearchMacAddress::AddrMac.get_ip_addresses
      end

      def all_addr
        all_ip_addr
      end

      def ip_addr
        all_ip_addr.first
      end

      def mac_addr
        ip_addr
      end

      def encode
        rec = ip_addr
        rec ? Base64.urlsafe_encode64(rec) : ''
      end

      def decode(addr)
        addr ? Base64.urlsafe_decode64(addr) : ''
      end
    end
  end
end
