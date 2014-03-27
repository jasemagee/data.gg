class Api::V1::Buses::RoutesController < ApplicationController
  
  # Not used yet
  def index
    @routes = Route.all
    
    respond_to do |format|
      format.html
    end
  end
  
  # POSTed from the timetables 'show'
  def create
    @route = Route.new(route_params)
    
    if !@route.timetable
      # error
    end
    @route.save
    
    flash[:success] = "Route created"
    
    redirect_to api_v1_buses_timetable_path(:start_date => @route.timetable.start)
  end
  
  def destroy
    @route = Route.find_by_id(params[:id])
    
    respond_to do |f|
      if @route.destroy
        flash[:success] = "Route destroyed"
        redirect_to api_v1_buses_timetable_path(:start_date => params[:start])
      else
        redirect_to api_v1_buses_timetable_route_path(:start_date => params[:start], :id => params[:id])
      end
    end
  end
  
  def show
    @route = Route.find_by_id(params[:id])
    @timetable = @route.timetable
    
    # Create route_stop which can be edited from this screen
    @route_stop = RouteStop.new
    @route_stop.route = @route
    
    
    @new_stop_link_set = []
    @route.route_stops.each do |route_stop|
      sl = StopLink.new
      sl.route_stop = route_stop
      sl.skip = route_stop = false
      sl.arrive = false
      sl.depart = true
      if @new_stop_link_set.count > 0
        sl.origin_stop_link = @new_stop_link_set[0]
      else
        sl.origin_stop_link = sl
      end
      
      @new_stop_link_set << sl
      
    end
    
    @ordered_route_stops = @route.route_stops.order(:idx).all

    tmp_stop_links = StopLink.joins("INNER JOIN route_stops rs ON rs.id = stop_links.route_stop_id")
                          .joins("INNER JOIN stop_links origin ON origin.origin_stop_link_id = stop_links.origin_stop_link_id")
                          .where("rs.route_id = ?", @route.id)
                          .order("origin.time DESC, origin.id ASC, rs.idx ASC")
                          .distinct
                          
                          p tmp_stop_links
                          
    overall_set = Array.new # Contains ALL the stop links
    curr_set = Array.new # Contains CURRENT set
    curr_origin = nil
    tmp_stop_links.each do |stop_link|
      
      if curr_origin != nil && curr_origin != stop_link.origin_stop_link.id
        overall_set << curr_set
        curr_set = Array.new
      end
      
      curr_origin = stop_link.origin_stop_link.id
      curr_set << stop_link
    end
    
    # because the LAST set won't flip over, so need to push it on
    overall_set << curr_set
  
    @stop_links = overall_set
                          
    # Now we loop through until we find the origin time has changed, then add it to a collection. This will
    # organise each stop_link entry in a two-dimensional array instead
    
    respond_to do |format|
      format.html
    end
  end
  
  def stops
    @route = Route.find_by_id(params[:id])
    
    respond_to do |format|
      format.html
    end
  end
  
  def create_stop_link_chain
    
  end
  
  private
  
  def route_params
    params.require(:route).permit(:name, :description, :start_day, :end_day, :timetable_id)
  end
  
  def stop_params
    params.require(:stop).permit(:stop_id, :route_id)
  end
end