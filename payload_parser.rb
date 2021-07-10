require 'json'

class PayloadParser
  def initialize(file_path)
    serialized_data = File.read(file_path)
    @payload = JSON.parse(serialized_data)
  end

  def create_customer
    @customer = {
      "external_code": @payload["buyer"]["id"].to_s,
      "name": @payload["buyer"]["nickname"],
      "email": @payload["buyer"]["email"],
      "contact": "#{@payload['buyer']['phone']['area_code']}#{@payload['buyer']['phone']['number']}"
  }
  end

  def create_payment
    @payments = @payload["payments"]. map do |payment|
      {
        "kind": payment["payment_type"],
        "value": payment["installment_amount"]
      }
    end
  end

  def create_item
    @items = @payload["order_items"].map do |order_item|
      {
        "external_code": order_item["item"]["id"],
        "name": order_item["item"]["title"],
        "price": order_item["unit_price"],
        "quantity": order_item["quantity"],
        "total": order_item["full_unit_price"]
      } 
    end
  end

  def create_order
    {
      "external_code": @payload["id"].to_s,
      "store_id": @payload["store_id"],
      "sub_total": @payload["total_amount"].to_s,
      "delivery_fee": @payload["total_shipping"].to_s,
      "total_shipping": @payload["total_shipping"],
      "total": @payload["total_amount_with_shipping"].to_s,
      "country": @payload["shipping"]["receiver_address"]["country"]["id"],
      "state": @payload["shipping"]["receiver_address"]["state"]["name"],
      "city": @payload["shipping"]["receiver_address"]["city"]["name"],
      "district": @payload["shipping"]["receiver_address"]["neighborhood"]["name"],
      "street": @payload["shipping"]["receiver_address"]["street_name"],
      "complement": @payload["shipping"]["receiver_address"]["comment"],
      "latitude":  @payload["shipping"]["receiver_address"]["latitude"],
      "longitude":  @payload["shipping"]["receiver_address"]["longitude"],
      "dt_order_create": @payload["date_created"],
      "postal_code": @payload["shipping"]["receiver_address"]["zip_code"],
      "number": @payload["shipping"]["receiver_address"]["street_number"],
      "customer": create_customer,
      "items": create_item,
      "payment": create_payment
    }
  end
end

puts PayloadParser.new('payload.json').create_order