class ForecastsController < ApplicationController
  before_action :set_forecast, only: %i[ show edit update destroy ]

  # GET /forecasts or /forecasts.json
  def index
    @forecasts = Forecast.all
  end

  # GET /forecasts/1 or /forecasts/1.json
  def show
  end

  # GET /forecasts/new
  def new
    @forecast = Forecast.new
  end

  # GET /forecasts/1/edit
  def edit
  end

  # POST /forecasts or /forecasts.json
  def create
    @forecast = Forecast.new(forecast_params)

    respond_to do |format|
      if @forecast.save
        format.html { redirect_to @forecast, notice: "Forecast was successfully created." }
        format.json { render :show, status: :created, location: @forecast }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @forecast.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /forecasts/1 or /forecasts/1.json
  def update
    respond_to do |format|
      if @forecast.update(forecast_params)
        format.html { redirect_to @forecast, notice: "Forecast was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @forecast }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @forecast.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /forecasts/1 or /forecasts/1.json
  def destroy
    @forecast.destroy!

    respond_to do |format|
      format.html { redirect_to forecasts_path, notice: "Forecast was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_forecast
      @forecast = Forecast.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def forecast_params
      params.expect(forecast: [ :current_temperature, :high, :low, :time, :location_id ])
    end
end
