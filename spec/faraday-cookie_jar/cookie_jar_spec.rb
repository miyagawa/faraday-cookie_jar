require 'spec_helper'

describe Faraday::CookieJar do
  let(:conn) { Faraday.new(:url => 'http://faraday.example.com') }
  let(:cookie_jar) { HTTP::CookieJar.new }

  before do
    conn.use :cookie_jar
    conn.adapter :net_http # for sham_rock
  end

  it 'get default cookie' do
    conn.get('/default')
    expect(conn.get('/dump').body).to eq('foo=bar')
  end

  it 'does not send cookies to wrong path' do
    conn.get('/path')
    expect(conn.get('/dump').body).to_not eq('foo=bar')
  end

  it 'expires cookie' do
    conn.get('/expires')
    expect(conn.get('/dump').body).to eq('foo=bar')
    sleep 2
    expect(conn.get('/dump').body).to_not eq('foo=bar')
  end

  it 'fills an injected cookie jar' do

    conn_with_jar = Faraday.new(:url => 'http://faraday.example.com') do |conn|
      conn.use :cookie_jar, jar: cookie_jar
      conn.adapter :net_http # for sham_rock
    end

    conn_with_jar.get('/default')

    expect(cookie_jar.empty?).to be false

  end

  it 'multiple cookies' do
    conn.get('/default')

    response = conn.send('get') do |request|
      request.url '/multiple_cookies'
      request.headers.merge!({ :Cookie => 'language=english' })
    end

    expect(response.body).to eq('foo=bar;language=english')
  end

  context 'when configured to load and save cookies from a file.' do
    after :each do
      Faraday::CookieJar.filename = nil
      Faraday::CookieJar.save_options = nil
    end

    let(:saved_cookies) {
      jar = HTTP::CookieJar.new.load(Faraday::CookieJar.filename)
      jar.cookies('http://faraday.example.com')
    }

    it 'loads cookies from a file' do
      Faraday::CookieJar.filename = './spec/data/default-cookie.yml'
      Faraday::CookieJar.save_options = { session: true }
      expect(conn.get('/dump').body).to eq('foo=bar')
    end

    it 'saves cookies in a file' do
      Faraday::CookieJar.filename = './spec/tmp/default-cookie.yml'
      Faraday::CookieJar.save_options = { session: true }
      FileUtils.remove_dir(File.dirname(Faraday::CookieJar.filename), true) if File.exist? Faraday::CookieJar.filename
      conn.get('/default')
      expect(File).to exist(Faraday::CookieJar.filename)
      expect(saved_cookies).to match_array([have_attributes(
                                              name: 'foo',
                                              value: 'bar'
                                            )])
    end

    it 'expires cookie' do
      Faraday::CookieJar.filename = './spec/tmp/expired-cookie.yml'
      Faraday::CookieJar.save_options = { session: true }
      FileUtils.remove_dir(File.dirname(Faraday::CookieJar.filename), true) if File.exist? Faraday::CookieJar.filename
      conn.get('/expires')
      expect(conn.get('/dump').body).to eq('foo=bar')
      sleep 2
      expect(conn.get('/dump').body).to_not eq('foo=bar')
      expect(saved_cookies).to match_array([])
    end

  end
end

