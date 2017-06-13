require 'socket'

module Tunnelme
  class TunnelCluster
    def initialize remote_host: nil, remote_port: nil, local_port: nil
      @remote_host = remote_host
      @remote_port = remote_port
      @local_port = local_port
    end

    def open
      loop do
        remote_socket = TCPSocket.new @remote_host, @remote_port
        local_socket = TCPSocket.new 'localhost', @local_port

        loop do
          (ready_socks, _, _) = IO.select([remote_socket, local_socket])
          begin
            ready_socks.each do |socket|
              data = socket.readpartial 256
              if socket == remote_socket
                local_socket.write data
                local_socket.flush
              else
                remote_socket.write data
                remote_socket.flush
              end
            end
          rescue EOFError
            break
          end
        end

        remote_socket.close
        local_socket.close
      end
    end
  end
end
