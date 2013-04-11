require 'spec_helper'

describe Faraday::CookieJar do
  let(:conn) { Faraday.new(:url => 'http://faraday.example.com') }

  before do
    conn.use :cookie_jar
    conn.adapter :net_http # for sham_rock
  end

  it 'get default cookie' do
    conn.get('/default')
    conn.get('/dump').body.should == 'foo=bar'
  end

  it 'does not send cookies to wrong path' do
    conn.get('/path')
    conn.get('/dump').body.should_not == 'foo=bar'
  end

  it 'expires cookie' do
    conn.get('/expires')
    conn.get('/dump').body.should == 'foo=bar'
    sleep 2
    conn.get('/dump').body.should_not == 'foo=bar'
  end
end

