FactoryBot.define do
  factory :location do
    address_one { "123 Main St" }
    address_two { "Apt 4B" }
    city { "Anytown" }
    province { "CA" }
    postal_code { "12345" }
    country { "United States of America" }
  end
end
