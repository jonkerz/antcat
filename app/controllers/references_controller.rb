class ReferencesController < ApplicationController
  def index
    if params[:commit] == 'clear'
      params[:author] = params[:start_year] = params[:end_year] = params[:journal] = ''
    end
    @references = Reference.search(params).paginate(:page => params[:page])
  end

  def show
    @reference = Reference.find(params[:id])
  end
  
  def edit
    @reference = Reference.find(params[:id])
  end

  def update
    @reference = Reference.find(params[:id])
    unless @reference.update_attributes(params[:reference])
      flash[:error] = "There was an error updating this reference"
    end
    render_json
  end
  
  def new
    @reference = Reference.new
  end
  
  def create
    @reference = Reference.new(params[:reference])
    unless @reference.save
      flash[:error] = "There was an error adding this reference"
    end
    render_json true
  end
  
  def destroy
    @reference = Reference.find(params[:id])
    @reference.destroy
    render :nothing => true
  end

  private
  def render_json new = false
    render :json => {:isNew => new, :content => render_to_string(:file => 'references/reference'), :id => @reference.id}
  end
end
