
$:.unshift File.dirname(__FILE__) 

require 'sinatra'
require 'thread'
require 'browsers'
require 'helpers'
require 'routes'

module JSpec
  class Server < Sinatra::Application
    
    ##
    # Suite HTML.
    
    attr_accessor :suite
    
    ##
    # Host string.
    
    attr_reader :host
    
    ##
    # Port number.
    
    attr_reader :port
    
    ##
    # Server instance.
    
    attr_reader :server
    
    ##
    # Server handlers to use.
    
    attr_reader :servers
    
    ##
    # URI formed by the given host and port.
    
    def uri
      'http://%s:%d' % [host, port]
    end
    
    ##
    # Initialize.
    # Start the server with _browsers_ which defaults to all supported browsers.
    
    def initialize suite, port, browsers, servers = %w[thin mongrel webrick]
      super()
      @suite, @port, @host, @servers = suite, port, 'localhost', servers
      browsers ||= Browser.subclasses.map { |browser| browser.new }
      browsers.map do |browser|
        Thread.new {
          sleep 1
          begin
            if browser.supported?
              browser.setup
              browser.visit uri + '/' + suite
              browser.teardown
            end
          end
        }
      end.push(Thread.new {
        begin
          $stderr.puts 'Started JSpec server at http://%s:%d' % [host, port.to_i]
          detect_rack_handler.run self, {:Host=> host, :Port=>port} do |server|
            trap 'INT' do
              server.respond_to?(:stop!) ? server.stop! : server.stop
            end
          end
        rescue Errno::EADDRINUSE
          raise "Port #{port} already in use"
        rescue Errno::EACCES
          raise "Permission Denied on port #{port}"
        end
      }).reverse.each { |thread| thread.join }
    end
    
    ##
    # Detects the first rack handler available. Taken from Sinatra::Base.
    
    private
    
    def detect_rack_handler
      @servers.each do |server_name|
        begin
          return Rack::Handler.get(server_name)
        rescue LoadError
        rescue NameError
        end
      end
    end
    
  end
end