require 'oauth2'

module Facebook
  # http://www.facebook.com/developers/apps.php?app_id=APPID
  class Client
    class << self
      attr_accessor :app_id, :secret
    end
    
    def self.oauth_client(app_id = nil, secret = nil)
      self.app_id, self.secret = app_id, secret unless app_id.nil?
      OAuth2::Client.new(self.app_id, self.secret, :site => 'https://graph.facebook.com')
    end
    
    def initialize(app_id, secret, options = {})
      @oauth = self.class.oauth_client(app_id, secret)
      @default_params = { :scope => options[:permissions], :display => options[:display] }
      @user_fields = Array(options[:user_fields])
    end

    # params: redirect_uri, scope, display
    def authorize_url(params = {})
      @oauth.web_server.authorize_url(@default_params.merge(params))
    end

    def get_access_token(code, redirect_uri)
      @oauth.web_server.get_access_token(code, :redirect_uri => redirect_uri)
    end
    
    def restore_access_token(token_string)
      OAuth2::AccessToken.new(@oauth, token_string)
    end

    def login_handler(options = {})
      Login.new(self, options)
    end
    
    def get_user_info(access_token, path)
      access_token.get(path, :fields => @user_fields.join(','))
    end
  end
end
