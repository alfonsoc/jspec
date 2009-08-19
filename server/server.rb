
$:.unshift File.dirname(__FILE__) 

require 'sinatra'
require 'thread'
require 'browsers'
require 'routes'

module JSpec
  class Server
    
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
    # Initialize.
    
    def initialize suite, port
      @suite, @port, @host = suite, port, :localhost
    end
    
    ##
    # URI formed by the given host and port.
    
    def uri
      'http://%s:%d' % [host, port]
    end
    
    ##
    # Start the server with _browsers_ which defaults to all supported browsers.
    
    def start browsers = nil
      browsers ||= Browser.subclasses.map { |browser| browser.new }
      browsers.map do |browser|
        Thread.new {
          if browser.supported?
            $stderr.puts "Running #{browser}"
            browser.setup
            browser.visit uri + '/' + suite
            browser.teardown
          end
        }
      end.push(Thread.new {
        start!
      }).each { |thread| thread.join }
    end
    
    private
    
    #:nodoc:
    
    def start!
      Sinatra::Application.class_eval do
        begin
          detect_rack_handler.run self, :Host => host, :Port => port do |server|
            trap 'INT' do
              server.respond_to?(:stop!) ? server.stop! : server.stop
            end
          end
        rescue Errno::EADDRINUSE => e
          puts "Port `#{port}' already in use"
        end
      end
    end
    
  end
end