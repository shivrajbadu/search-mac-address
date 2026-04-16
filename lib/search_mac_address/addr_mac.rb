require 'ipaddr'
require 'socket'

module SearchMacAddress
  class AddrMac
    PHYSICAL_INTERFACE_PATTERN = /\A(en|eth|ens|eno|enp|wlan|wlp|wifi|wl|lan)\w*/i.freeze
    VIRTUAL_INTERFACE_PATTERN = /\A(lo|loopback|docker|br-|veth|virbr|vmnet|utun|tun|tap|awdl|llw|anpi|gif|stf|bridge|ap)\w*/i.freeze

    class << self
      def get_physical_address
        get_ip_addresses
      end

      def get_ip_addresses
        by_socket.then do |addresses|
          return addresses if addresses.any?
        end

        by_popen
      end

      def by_socket
        interfaces = Socket.getifaddrs.filter_map do |ifaddr|
          next unless usable_ip_interface?(ifaddr)

          {
            name: ifaddr.name.to_s,
            ip: normalized_ip(ifaddr.addr.ip_address),
            family: ifaddr.addr.ipv4? ? :ipv4 : :ipv6
          }
        end

        ordered_unique_ips(interfaces)
      rescue StandardError
        []
      end

      def by_popen
        ordered_unique_ips(parse_output(command_output('ifconfig'))).tap do |addresses|
          return addresses if addresses.any?
        end

        ordered_unique_ips(parse_output(command_output('ipconfig /all')))
      end

      private

      def usable_ip_interface?(ifaddr)
        addr = ifaddr.addr
        return false unless addr&.ip?

        ip = parse_ip(addr.ip_address)
        return false unless ip
        return false if excluded_ip?(ip)

        true
      end

      def parse_output(output)
        return [] if output.to_s.empty?

        interfaces = []
        current_name = nil

        output.each_line do |line|
          current_name = interface_name_from(line) || current_name
          next unless relevant_ip_line?(line)

          extract_ips(line).each do |ip|
            parsed_ip = parse_ip(ip)
            next unless parsed_ip
            next if excluded_ip?(parsed_ip)

            interfaces << {
              name: current_name.to_s,
              ip: normalized_ip(parsed_ip.to_s),
              family: parsed_ip.ipv4? ? :ipv4 : :ipv6
            }
          end
        end

        interfaces
      end

      def extract_ips(line)
        if line.match?(/\binet6\b/i) || line.match?(/IPv6 Address/i)
          line.scan(/\b(?:[0-9a-f]{0,4}:){2,7}[0-9a-f]{0,4}\b/i).first(1)
        else
          line.scan(/\b(?:\d{1,3}\.){3}\d{1,3}\b/).first(1)
        end
      end

      def interface_name_from(line)
        unix_name = line[/\A([A-Za-z0-9:_\-.]+):/, 1]
        return unix_name if unix_name

        windows_name = line[/adapter\s+(.+?):\s*\z/i, 1]
        return windows_name if windows_name

        nil
      end

      def relevant_ip_line?(line)
        line.match?(/\binet6?\b/i) || line.match?(/IPv[46] Address/i)
      end

      def ordered_unique_ips(interfaces)
        interfaces
          .uniq { |entry| entry[:ip] }
          .sort_by { |entry| [-priority_for(entry), entry[:name], entry[:ip]] }
          .map { |entry| entry[:ip] }
      end

      def priority_for(entry)
        score = 0
        score += 100 if entry[:family] == :ipv4
        score += 20 if entry[:name].match?(PHYSICAL_INTERFACE_PATTERN)
        score -= 40 if entry[:name].match?(VIRTUAL_INTERFACE_PATTERN)
        score
      end

      def command_output(command)
        IO.popen(command, err: File::NULL, &:read)
      rescue StandardError
        ''
      end

      def parse_ip(ip)
        IPAddr.new(normalized_ip(ip))
      rescue IPAddr::InvalidAddressError, NoMethodError
        nil
      end

      def normalized_ip(ip)
        ip.to_s.split('%').first
      end

      def link_local?(ip)
        ip.ipv4? ? ip.to_s.start_with?('169.254.') : ip.to_s.downcase.start_with?('fe80:')
      end

      def excluded_ip?(ip)
        ip.loopback? || unspecified?(ip) || multicast?(ip) || link_local?(ip)
      end

      def unspecified?(ip)
        value = ip.to_s.downcase
        value == '0.0.0.0' || value == '::'
      end

      def multicast?(ip)
        value = ip.to_s.downcase
        return value.start_with?('ff') if ip.ipv6?

        first_octet = value.split('.').first.to_i
        first_octet >= 224 && first_octet <= 239
      end
    end
  end
end
