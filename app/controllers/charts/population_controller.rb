class Charts::PopulationController < ApplicationController
  before_action :set_population

  def index
    respond_to do |format|
      format.html { render :index }
    end
  end

  def population
    respond_to do |format|
      format.json { render json: @population }
      format.xml { render xml: @population }
      format.html { render html: @population }
    end
  end

  private

  def set_population
    population_json = File.read("storage/population.json")
    @population = JSON.parse(population_json)
    @population.sort_by! { |c| c['Year'] }
  end
end