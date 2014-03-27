require 'date'

class Api::V1::Buses::TimetablesController < ApplicationController
  
  def show
    @timetable = Timetable.where(:start => params[:start_date]).first
    @route = Route.new
    @stop = Stop.new

    respond_to do |format|
      format.html
    end
  end
  
  def new
    @timetable = Timetable.new
  end
  
  def create
    @timetable = Timetable.new(timetable_params)
    @timetable.save
  #  
    flash[:success] = "Timetable '#{@timetable.name}' successfully saved."
  #  
    redirect_to api_v1_buses_timetable_path(@timetable.start)
  end
  
  def destroy
    @timetable = Timetable.find_by_start(params[:start])
    
    if !@timetable
      flash[:error] = "Couldn't find a timetable with start date of '#{params[:start]}' to delete!"
      redirect_to api_v1_buses_path # redirect a level higher because it doesn't exist
    end
    
    if !@timetable.destroy
      flash[:error] = "Couldn't delete the timetable with a start date of '#{params[:start]}'"
      redirect_to api_v1_buses_timetable_path(params[:start])
    end
    
    flash[:success] = "Successfully deleted timetable with a start date of '#{params[:start]}"
    redirect_to api_v1_buses_path
  end
  
  #def download
    
  #  date = params[:date]
  #  type = params[:type]
    
    # Based on the type get the data
    
    #end
  
  private
  
  def timetable_params
    params.require(:timetable).permit(:name, :description, :start, :end)
  end
end