require 'tunnelme'
require 'rails/commands/server'

module RailsServerExt
  def start
    start_tunnelme if ENV['TUNNELME']
    super
  end

  def start_tunnelme
    Thread.new do
      @tunnel = Tunnelme::Tunnel.new(tun_server: tunnelme_server, subdomain: tunnelme_subdomain, port: options[:Port])
      puts "=> Tunnelme URL: #{@tunnel.url}"

      begin_timestamp = Time.now.to_i
      begin
        @tunnel.serve
      rescue Errno::ECONNREFUSED => e
        retry if Time.now.to_i - begin_timestamp <= 30

        puts "Can't start Tunnelme client in 30 seconds..."
      end
    end
  end

  private

  def tunnelme_server
    ENV['TUN_SERVER'] || tunnelme_config['tun_server'] || 'https://localtunnel.me'
  end

  def tunnelme_subdomain
    ENV['TUN_DOMAIN'] || tunnelme_config['domain']
  end

  def tunnelme_config
    @tunnelme_config ||= YAML.load File.read File.join(Rails.root, 'config', 'tunnelme.yml') rescue {}
  end
end

Rails::Server.prepend RailsServerExt
