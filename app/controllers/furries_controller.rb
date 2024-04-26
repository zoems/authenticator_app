class FurriesController < ApplicationController
  before_action :set_furry, only: %i[show destroy]
  skip_before_action :authenticate_user!, only: %i[index show map]

  def index
    current_user.nil? ? @furries = Furry.all : @furries = Furry.where.not(user_id: current_user.id)
    if params[:search].present?
      @query = params[:search][:query]
      @furries = @furries.where("fursona ILIKE ?", "%#{@query}%")
    end
  end

  def map
    @furries = Furry.all
    @markers = @furries.geocoded.map do |furry|
      {
        lat: furry.latitude,
        lng: furry.longitude,
        info_window_html: render_to_string(partial: "furries/info_window", locals: { furry: furry }),
        marker_html: render_to_string(partial: "furries/marker", locals: { furry: furry })
      }
    end
  end

  def my_furries
    @furries = Furry.where(user_id: current_user.id)
    # key_skill if !@furries.nil? || @furries[0].key_skill.nil?
  end

  def show
    @booking = Booking.new
    @today = Date.today.to_s

    # Get an array of hashes witht he start and end date
    @dates_booked = @furry.bookings.map do |booking|
      { from: booking[:start_date], to: booking[:end_date] }
    end
  end

  def new
    @furry = Furry.new
  end

  def create
    @furry = Furry.new(furry_params)
    @furry.user = current_user
    # raise
    if @furry.save
      redirect_to furries_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @furry.destroy
    redirect_to furries_path
  end

  private

  def set_furry
    @furry = Furry.find(params[:id])
  end

  def furry_params
    params.require(:furry).permit(:name, :description, :price, :fursona, :photo)
  end
end
