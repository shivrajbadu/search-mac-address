RSpec.describe SearchMacAddress do
  describe 'version' do
    it 'has a version number' do
      expect(SearchMacAddress::VERSION).not_to be_nil
    end
  end

  describe SearchMacAddress::AddrMac do
    let(:loopback_addr) { instance_double(Addrinfo, ip?: true, ip_address: '127.0.0.1', ipv4?: true) }
    let(:wifi_addr) { instance_double(Addrinfo, ip?: true, ip_address: '192.168.1.20', ipv4?: true) }
    let(:ethernet_addr) { instance_double(Addrinfo, ip?: true, ip_address: '10.0.0.12', ipv4?: true) }
    let(:ipv6_link_local) { instance_double(Addrinfo, ip?: true, ip_address: 'fe80::1%en0', ipv4?: false) }

    let(:loopback_if) { instance_double(Socket::Ifaddr, name: 'lo0', addr: loopback_addr) }
    let(:wifi_if) { instance_double(Socket::Ifaddr, name: 'wlan0', addr: wifi_addr) }
    let(:ethernet_if) { instance_double(Socket::Ifaddr, name: 'en0', addr: ethernet_addr) }
    let(:ipv6_if) { instance_double(Socket::Ifaddr, name: 'utun0', addr: ipv6_link_local) }

    it 'returns usable IPs from interfaces, prioritizing IPv4 on physical interfaces' do
      allow(Socket).to receive(:getifaddrs).and_return([loopback_if, wifi_if, ethernet_if, ipv6_if])

      expect(described_class.get_ip_addresses).to eq(%w[10.0.0.12 192.168.1.20])
    end

    it 'falls back to command parsing when socket enumeration fails' do
      allow(Socket).to receive(:getifaddrs).and_raise(StandardError)
      allow(described_class).to receive(:command_output).with('ifconfig').and_return(<<~OUT)
        en0: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST>
                inet 192.168.0.10 netmask 0xffffff00 broadcast 192.168.0.255
        lo0: flags=8049<UP,LOOPBACK,RUNNING,MULTICAST>
                inet 127.0.0.1 netmask 0xff000000
      OUT

      expect(described_class.get_ip_addresses).to eq(['192.168.0.10'])
    end
  end

  describe SearchMacAddress::Filter do
    before do
      allow(SearchMacAddress::AddrMac).to receive(:get_ip_addresses).and_return(%w[10.10.17.18 192.168.1.2])
    end

    it 'returns the full list of IPs' do
      expect(described_class.all_addr).to eq(%w[10.10.17.18 192.168.1.2])
      expect(described_class.all_ip_addr).to eq(%w[10.10.17.18 192.168.1.2])
    end

    it 'returns the primary IP through both method names' do
      expect(described_class.ip_addr).to eq('10.10.17.18')
      expect(described_class.mac_addr).to eq('10.10.17.18')
    end

    it 'encodes and decodes the primary IP' do
      encoded = described_class.encode

      expect(encoded).not_to be_empty
      expect(described_class.decode(encoded)).to eq('10.10.17.18')
    end
  end
end
