require 'socket'
require 'eventmachine'

module Tunnelme
  class TunnelCluster
    attr_reader :remote_host, :remote_port, :local_port, :stop

    def initialize remote_host: nil, remote_port: nil, local_port: nil
      @remote_host = remote_host
      @remote_port = remote_port
      @local_port = local_port
    end

    class LocalConnection < EventMachine::Connection
      attr_reader :remote

      def initialize(remote)
        @remote = remote
        super
      end

      def receive_data data
        remote.send_data data
      end
    end

    class RemoteConnection < EventMachine::Connection
      attr_reader :local, :cluster

      def initialize cluster
        @cluster = cluster
        super
      end

      def unbind
        @local = nil
        reconnect cluster.remote_host, cluster.remote_port unless cluster.stop
      end

      def receive_data data
        local.send_data data
      end

      private

      def local
        @local ||= EM.connect 'localhost', cluster.local_port, LocalConnection, self
      end
    end

    def open conn_num
      EM.run {
        Signal.trap('INT') { @stop = true; EM.stop }
        Signal.trap('TERM') { @stop = true; EM.stop }
        conn_num.times do
          EM.connect @remote_host, @remote_port, RemoteConnection, self
        end
      }
    end
  end
end
