require "rails_helper"

RSpec.describe Forecasts::FetchByZipService, type: :service do
  context "when there is a forecast in the cache for the provided postal code" do
    let!(:forecast) { create(:forecast) }
    it "should return the forecast from the cache" do
      Rails.cache.write(forecast.location.postal_code, forecast.id)

      service = Forecasts::FetchByZipService.new(forecast.location.postal_code)
      result = service.call

      expect(result).to eq(forecast)
    end
  end

  context "when there is not a forecast in the cache for the provided postal code" do
    it "should return nil" do
      service = Forecasts::FetchByZipService.new("54321")
      result = service.call

      expect(result).to be_nil
    end
  end
end
