class CategoriesController < ApplicationController
  before_filter :set_tab
  before_filter :authenticate
  before_filter :categories_list, :except => [:show, :destroy]
  load_and_authorize_resource :through => :current_company

  def index
    @search = current_company.categories.search(params[:search])
    if params[:search]
      @categories = @search.paginate(:page => params[:page])
    else
      @categories = @search.sorted.paginate(:page => params[:page])
    end
    @category = Category.new
  end
  
  def show
    @category = Category.find(params[:id])
    render :layout => false if request.xhr?
  end
  
  def new
    @category = Category.new
    @parents = current_company.categories.collect { |cat| [cat.fullcode, cat.id] }.compact
    render :layout => false if request.xhr?
  end
  
  def create
    @category = Category.new(params[:category])
    @category.company = current_company
    if @category.save
      flash[:notice] = "Successfully created category."
      if request.xhr?
        render :json => { 'location' => categories_path}.to_json, :layout => false
      else
        redirect_to @category
      end
    else
      if request.xhr?
        form = render_to_string :action => 'new', :layout => false
        status = 'validation error'
        render :json => {'status' => status, 'form' => form }.to_json
      else
        @parents = current_company.categories.collect { |cat| [cat.fullcode, cat.id] }.compact
        render :action => 'new'
      end
    end
  end
  
  def edit
    @category = Category.find(params[:id])
    @parents = current_company.categories.collect { |cat| [cat.fullcode, cat.id] }.compact
    render :layout => false if request.xhr?
  end
  
  def update
    @category = Category.find(params[:id])
    if @category.update_attributes(params[:category])
      flash[:notice] = "Successfully updated category."
      if request.xhr?
        render :json => { 'location' => categories_path}.to_json, :layout => false
      else
        redirect_to @category
      end
    else
      if request.xhr?
        form = render_to_string :action => 'edit', :layout => false
        status = 'validation error'
        render :json => {'status' => status, 'form' => form }.to_json
      else
        @parents = current_company.categories.collect { |cat| [cat.fullcode, cat.id] }.compact
        render :action => 'edit'
      end
    end
  end
  
  def destroy
    @category = Category.find(params[:id])
    @category.delete
    flash[:notice] = "Successfully destroyed category."
    redirect_to categories_url
  end

  def items_for_begining_balance
    @items = Category.find(params[:id]).items
    if request.xhr?
      render :layout => false
    end
  end

  def search
  end

  private
  def set_tab
    @tab = 'administrations'
    @current = 'cat'
  end

  def categories_list
    @categories_list = current_company.categories
  end
end
