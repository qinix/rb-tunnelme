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

    # def open
    #   loop do
    #     remote_socket = TCPSocket.new @remote_host, @remote_port
    #     local_socket = TCPSocket.new 'localhost', @local_port

    #     loop do
    #       (ready_socks, _, _) = IO.select([remote_socket, local_socket])
    #       begin
    #         ready_socks.each do |socket|
    #           data = socket.readpartial 256
    #           if socket == remote_socket
    #             local_socket.write data
    #             local_socket.flush
    #           else
    #             remote_socket.write data
    #             remote_socket.flush
    #           end
    #         end
    #       rescue EOFError
    #         break
    #       end
    #     end

    #     remote_socket.close
    #     local_socket.close
    #   end
    # end

    class LocalConnection < EventMachine::Connection
      attr_reader :remote, :data

      def initialize(remote, data)
        @remote = remote
        @data = data
        super
      end

      def post_init
        puts "local connected"
        send_data data
      end

      def unbind
        puts "local unbind"
      end

      def receive_data data
        puts '=======local receive data========'
        puts data
        remote.send_data data

      end
    end

    class RemoteConnection < EventMachine::Connection
      attr_reader :local, :cluster

      def initialize cluster
        @cluster = cluster
        super
      end

      def post_init
        puts "remote connected"
      end

      def unbind
        puts "remote unbind"
        reconnect cluster.remote_host, cluster.remote_port unless cluster.stop
      end

      def receive_data data
        puts '=======remote receive data========'
        send_data_to_local data
      end

      private

      def send_data_to_local data
        EM.connect 'localhost', cluster.local_port, LocalConnection, self, data
      end
    end

    def open
      EM.run {
        Signal.trap('INT') { @stop = true; EM.stop }
        Signal.trap('TERM') { @stop = true; EM.stop }
        EM.connect @remote_host, @remote_port, RemoteConnection, self
      }
    end
  end
end
