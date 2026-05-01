class LocationsController < ApplicationController
  before_action :set_location, only: %i[ show edit update destroy ]

  # GET /locations or /locations.json
  def index
    @locations = Location.all
  end

  # GET /locations/1 or /locations/1.json
  def show
  end

  # GET /locations/new
  def new
    @location = Location.new
    @countries = LocationsHelper.country_list
  end

  # GET /locations/1/edit
  def edit
  end

  # POST /locations or /locations.json
  def create
    # let's build the location object. 
    @location = Location.find_or_create_by(location_params)
    if @location.geocoding_required?
      service = Locations::GeocodingService.new(@location)
      service.call
    end

    # let's get the weather forecast
    # if we have the postal code, we can try and pull from the cache.
    if @location.postal_code.present?
      forecast = Forecasts::FetchByZipService.new(@location.postal_code).call
    end

    # if we don't find it via the cache, we can try and pull it by the coordinates we have. 
    # otherwise we can just dup the forecast we found and associate it with the new location.
    if forecast.blank?
      forecast = Forecasts::CreateService.new(@location).call
    else
      duped_forecast = forecast.dup
      duped_forecast.location = @location
      duped_forecast.save!
    end

    respond_to do |format|
      # happy path
      if @location.present? && forecast.present?
        format.html { redirect_to @location, notice: "Location was successfully created." }
        format.json { render :show, status: :created, location: @location }
      # the location didn't get created
      elsif @location.errors.any?
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      # the else statement covers us creating the location but not being able to get a forecast
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: forecast.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /locations/1 or /locations/1.json
  def update
    respond_to do |format|
      if @location.update(location_params)
        format.html { redirect_to @location, notice: "Location was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @location }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1 or /locations/1.json
  def destroy
    @location.destroy!

    respond_to do |format|
      format.html { redirect_to locations_path, notice: "Location was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location
      @location = Location.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def location_params
      puts "================================= Raw params: ================================="
      puts params[:location]
      puts "================================================================================"
      params.expect(location: [ :address_one, :address_two, :city, :province, :postal_code, :country ])
    end
end
