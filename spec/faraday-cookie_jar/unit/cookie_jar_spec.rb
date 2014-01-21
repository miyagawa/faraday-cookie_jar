require 'spec_helper'

describe Faraday::CookieJar do

  let(:cookie_jar) { HTTP::CookieJar.new }

  let(:middleware) { Faraday::CookieJar.new(nil, {jar: cookie_jar }) }

  it 'accepts a custom jar' do
    expect { middleware }.to_not raise_error
  end

  it 'uses the custom cookie jar' do
    expect(middleware.instance_variable_get(:@jar)).to equal(cookie_jar)
  end

end

