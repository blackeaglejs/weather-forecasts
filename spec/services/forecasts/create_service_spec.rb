require "rails_helper"

RSpec.describe Forecasts::CreateService, type: :service do
  let!(:location) { create(:location, latitude: 40.7128, longitude: -74.0060) }

  let(:successful_response_body) do
    {
      "current_weather" => { "temperature" => 72.0, "temperature_unit" => "F" },
      "daily" => { "temperature_2m_max" => [ 80.0 ], "temperature_2m_min" => [ 65.0 ] }
    }.to_json
  end

  context "when the forecast is successfully created" do
    before do
      stub_request(:get, /api.open-meteo.com/).to_return(status: 200, body: successful_response_body)
    end

    it "should create the forecast record and associate it with the location" do
      forecast = Forecasts::CreateService.new(location).call

      expect(forecast).to be_persisted
      expect(forecast.location).to eq(location)
      expect(forecast.current_temperature).to eq(72.0)
      expect(forecast.high).to eq(80.0)
      expect(forecast.low).to eq(65.0)
    end

    it "should write the forecast ID to the cache with the postal code as the key" do
      forecast = Forecasts::CreateService.new(location).call

      expect(Rails.cache.read(location.postal_code)).to eq(forecast.id)
    end
  end

  context "when the location is missing coordinates" do
    let!(:location) { create(:location, latitude: nil, longitude: nil) }

    it "should raise a StandardError" do
      expect { Forecasts::CreateService.new(location).call }.to raise_error(StandardError, "Location is missing coordinates")
    end
  end

  context "when the forecast API request fails" do
    before do
      stub_request(:get, /api.open-meteo.com/).to_return(status: 500, body: "Internal Server Error")
    end

    it "should raise a StandardError" do
      expect { Forecasts::CreateService.new(location).call }.to raise_error(StandardError, /External forecast retrieval failed with/)
    end
  end

  context "when we don't get the expected attributes in the forecast API response" do
    before do
      stub_request(:get, /api.open-meteo.com/).to_return(status: 200, body: {}.to_json)
    end

    it "should raise a StandardError" do
      expect { Forecasts::CreateService.new(location).call }.to raise_error(StandardError, "External forecast retrieval did not retrieve temperature")
    end
  end

  context "when we fail to save the forecast record" do
    before do
      stub_request(:get, /api.open-meteo.com/).to_return(status: 200, body: successful_response_body)
      allow(location.forecasts).to receive(:create) do
        forecast = Forecast.new
        forecast.errors.add(:base, "Something went wrong")
        forecast
      end
    end

    it "should raise a StandardError" do
      expect { Forecasts::CreateService.new(location).call }.to raise_error(StandardError, /Failed to save forecast/)
    end
  end
end
