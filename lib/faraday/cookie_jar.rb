require "faraday"
require "cookiejar"

module Faraday
  class CookieJar < Faraday::Middleware
    def initialize(app, options = {})
      super(app)
      @jar = ::CookieJar::Jar.new
    end

    def call(env)
      cookie = @jar.get_cookie_header(env[:url])
      unless cookie.empty?
        env[:request_headers]["Cookie"] = cookie
      end

      @app.call(env).on_complete do |res|
        @jar.set_cookies_from_headers(env[:url], res[:response_headers])
      end
    end
  end
end

if Faraday.respond_to? :register_middleware
  Faraday.register_middleware :cookie_jar => lambda { Faraday::CookieJar }
end
