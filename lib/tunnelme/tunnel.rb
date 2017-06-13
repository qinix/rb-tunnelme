require 'uri'
require 'httparty'

module Tunnelme
  class Tunnel
    attr_reader :name, :url

    def initialize tun_server: 'https://localtunnel.me', subdomain: nil, port: 3000
      @local_port = port

      uri = "#{tun_server}/#{subdomain || '?new'}"
      res = HTTParty.get uri
      raise "localtunnel server error: #{res['message']}" unless res.code == 200

      @remote_host = URI.parse(uri).host
      @remote_port = res['port']
      @name = res['id']
      @url = res['url']
      @max_conn = res['max_conn_count'] || 1
    end

    def serve
      @tunnel_cluster = TunnelCluster.new remote_host: @remote_host, remote_port: @remote_port, local_port: @local_port
      threads = @max_conn.times.map { Thread.new { @tunnel_cluster.open }}
      threads.each(&:join)
    end
  end
end
