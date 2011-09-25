require 'oauth2'

module Facebook
  # http://www.facebook.com/developers/apps.php?app_id=APPID
  class Client
    class << self
      attr_reader :last_oauth_client
    end

    def self.oauth_client(app_id, secret, &block)
      @last_oauth_client = OAuth2::Client.new app_id, secret,
        :site => 'https://graph.facebook.com',
        :token_url => '/oauth/access_token',
        &block
    end

    def self.access_token_options
      {:mode => :query, :param_name => 'access_token'}
    end

    def self.restore_access_token(token_string)
      OAuth2::AccessToken.new(last_oauth_client, token_string, access_token_options)
    end

    attr_reader :oauth

    def initialize(app_id, secret, options = {}, &block)
      @oauth = self.class.oauth_client(app_id, secret, &block)
      @default_params = { :scope => options[:permissions], :display => options[:display] }
      @user_fields = Array(options[:user_fields])
    end

    # params: redirect_uri, scope, display
    def authorize_url(params = {})
      @oauth.auth_code.authorize_url(@default_params.merge(params))
    end

    def get_access_token(code, redirect_uri)
      token = @oauth.auth_code.get_token(code, :redirect_uri => redirect_uri, :parse => :query)
      token.options.update(self.class.access_token_options)
      token
    end

    def login_handler(options = {})
      Login.new(self, options)
    end

    def get_user_info(access_token, path)
      access_token.get(path, :fields => @user_fields.join(','))
    end
  end
end
