class Api::V1::BusesController < ApplicationController
  
  def index
    @timetables = Timetable.order(:start).all
    @latest = @timetables[0]
    @timetable = Timetable.new
    
    respond_to do |format|
      format.html
    end
  end
  
  
  
end
