require 'oauth2'
require 'yajl'
require 'rack/request'
require 'addressable/uri'

module Facebook
  class Client
    def initialize(app_id, secret, options = {})
      @oauth = OAuth2::Client.new(app_id, secret, :site => 'https://graph.facebook.com')
      @default_params = { :scope => options[:permissions], :display => options[:display] }
    end
    
    # params: redirect_uri, scope, display
    def authorize_url(params = {})
      @oauth.web_server.authorize_url(@default_params.merge(params))
    end
    
    def get_access_token(code, redirect_uri)
      @oauth.web_server.get_access_token(code, :redirect_uri => redirect_uri)
    end
    
    def login_handler(options = {})
      Login.new(self, options)
    end
  end
  
  class Login
    attr_reader :options
    
    def initialize(client, options = {})
      @client = client
      @options = { :return_to => '/' }.merge(options)
    end
    
    def call(env)
      request = Request.new(env)
      callback_url = Addressable::URI.parse(request.url)
      callback_url.query = nil
      
      if code = request[:code]
        access_token = @client.get_access_token(code, callback_url)
        request.session[:facebook_access_token] = access_token.token
        request.session[:facebook_user] = Yajl::Parser.parse(access_token.get('/me'))
        redirect_to_return_path(request)
      else
        redirect @client.authorize_url(:redirect_uri => callback_url)
      end
    end

    module Helpers
      def facebook_user
        if session[:facebook_user]
          Hashie::Mash.new session[:facebook_user]
        end
      end

      def facebook_logout
        [:facebook_user, :facebook_access_token].each do |key|
          session[key] = nil # work around Rails 2.3.5 bug
          session.delete key
        end
      end
    end
    
    class Request < ::Rack::Request
      # for storing :request_token, :access_token
      def session
        env['rack.session'] ||= {}
      end

      # SUCKS: must duplicate logic from the `url` method
      def url_for(path)
        url = scheme + '://' + host

        if scheme == 'https' && port != 443 ||
            scheme == 'http' && port != 80
          url << ":#{port}"
        end

        url << path
      end
    end
    
    private
    
    def redirect_to_return_path(request)
      redirect request.url_for(options[:return_to])
    end

    def redirect(url)
      ['302', {'Location' => url, 'Content-type' => 'text/plain'}, []]
    end
  end
end
