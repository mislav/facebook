require 'facebook/client'
require 'yajl'
require 'rack/request'
require 'addressable/uri'

module Facebook
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
        handle_facebook_authorization(code, callback_url, request)
      elsif error = request[:error_reason]
        handle_error(error, request)
      else
        redirect_to_facebook(callback_url)
      end
    end

    module Helpers
      def facebook_client
        OAuth2::AccessToken.new(facebook_oauth, session[:facebook_access_token])
      end
      
      def facebook_oauth
        Facebook::Client.oauth_client
      end
      
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
    
    def handle_facebook_authorization(code, callback_url, request)
      access_token = @client.get_access_token(code, callback_url)
      user_info = @client.get_user_info(access_token, '/me')
    
      request.session[:facebook_access_token] = access_token.token
      request.session[:facebook_user] = Yajl::Parser.parse(user_info)
      redirect_to_return_path(request)
    end    
    
    def handle_error(error, request)
      request.session[:facebook_error] = error
      redirect_to_return_path(request)
    end
    
    def redirect_to_facebook(callback_url)
      redirect @client.authorize_url(:redirect_uri => callback_url)
    end

    def redirect_to_return_path(request)
      redirect request.url_for(options[:return_to])
    end

    def redirect(url)
      ['302', {'Location' => url, 'Content-type' => 'text/plain'}, []]
    end
  end
end
