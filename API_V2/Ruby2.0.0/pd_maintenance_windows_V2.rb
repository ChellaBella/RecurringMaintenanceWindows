#!/usr/bin/env ruby

# Ruby script to create recurring maintenance windows in PagerDuty
#
# Copyright (c) 2012, PagerDuty, Inc. <info@pagerduty.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of PagerDuty Inc nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL PAGERDUTY INC BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Tested with Ruby 2.0.0 and PagerDuty API V2
# Requires rubygems (Ruby 2.0.0 comes with Rubygems)
# Just run the following from a terminal to install the necessary gems
#
# sudo gem install json
# sudo gem install faraday
# sudo gem install activesupport
#
require 'rubygems'
require 'active_support/all'
require 'faraday'
require 'json'

DATE_FORMAT =  "%FT%T:%z"

class PagerDutyAgent

  def initialize(options = {})
    @options = options
    @connection = Faraday.new(:url => "https://api.pagerduty.com",
                              :ssl => {:verify => true}) do |c|
      c.request  :url_encoded
      c.response :logger
      c.adapter  :net_http
    end
  end

  def post(url, body = {}, headers = {})
    @connection.post do |req|
      req.url(url)
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = "Token token=#{@options[:token]}"
      req.headers['Accept'] = "application/vnd.pagerduty+json;version=2"
      # From is the email address of the user.
      req.headers['From'] = ENTER_YOUR_PAGERDUTY_EMAIL_HERE
      puts JSON.generate(body)
      req.body = JSON.generate(body)
    end
  end

end
# token is the API key. Please ensure you are generating a key for the V2 API
pd = PagerDutyAgent.new(:token => ENTER_YOUR_V2_API_KEY_HERE)

# List of services that are part of this maintenance
services = [{
  "id" => ENTER_YOUR_SERVICE_KEY_HERE,
  "type" => "service"
  }]

maintenance_start_time = Time.utc(2016, 06, 10, 12, 30).localtime("-08:00")
maintenance_end_time = maintenance_start_time + 2.hours

# Recur this maintenance window for the next 20 weeks

20.times do

  pd.post("/maintenance_windows",
  { "maintenance_window" => {
      "start_time" => maintenance_start_time.strftime(DATE_FORMAT),
      "end_time" => maintenance_end_time.strftime(DATE_FORMAT),
      "description" => "Weekly maintenance",
      "services" => services
    },
  })
  maintenance_start_time = maintenance_start_time + 1.week
  maintenance_end_time = maintenance_start_time + 2.hours
end
