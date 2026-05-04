FactoryBot.define do
  factory :forecast do
    association :location

    current_temperature { rand(-50.0..110.0).round(1) }
    high { current_temperature + rand(0.0..20.0).round(1) }
    low { current_temperature - rand(0.0..20.0).round(1) }
    time { Time.current }
    units { "fahrenheit" }
  end
end
