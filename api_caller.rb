require_relative 'payload_parser'
require "http"

payload_hash = PayloadParser.new('payload.json').create_order
api_url = "http://localhost:3000/api/v1/orders"

response = HTTP.post(api_url, json: payload_hash)
p response.parse