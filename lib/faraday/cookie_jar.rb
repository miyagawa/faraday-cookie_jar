require "faraday"
require "http/cookie_jar"

module Faraday
  class CookieJar < Faraday::Middleware
    def initialize(app, options = {})
      super(app)
      @jar = HTTP::CookieJar.new
    end

    def call(env)
      cookies = @jar.cookies(env[:url])
      unless cookies.empty?
        env[:request_headers]["Cookie"] = HTTP::Cookie.cookie_value(cookies)
      end

      @app.call(env).on_complete do |res|
        if set_cookie = res[:response_headers]["Set-Cookie"]
          @jar.parse(set_cookie, env[:url])
        end
      end
    end
  end
end

if Faraday.respond_to? :register_middleware
  Faraday.register_middleware :cookie_jar => lambda { Faraday::CookieJar }
end
