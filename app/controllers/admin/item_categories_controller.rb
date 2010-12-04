class Admin::ItemCategoriesController < AdminController
  before_filter :find_item_category, :except => [:new, :index]

  def new

    @item_category = ItemCategory.new
    
    @categories = ItemCategory.all
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def create
    item_category = params[:item_category]
    
    parent = ItemCategory.find_by_name(item_category.delete(:parent_id))
    item_category[:parent] = parent
    
    @item_category = ItemCategory.new(item_category)

    respond_to do |format|
      if @item_category.save
        flash[:notice] = "Your category has been created."
        format.html { redirect_to admin_item_categories_url }
      else
        flash[:warning] = "There was an issue saving your new category. #{@item_category.errors}"
        format.html { render :action => :new }
      end
    end

  end
  
  def index
    @item_categories = ItemCategory.all
 
    respond_to do |format|
      format.html
    end
    
  end
  
  def edit
    @categories = ItemCategory.all
  end
  
  def update
    respond_to do |format|
      if @item_category.update_attributes(params[:item_category]) 
        format.html { redirect_to admin_item_categories_url }
      else
        format.html { render :action => :edit }
      end
    end
  end

  def destroy
    @item_category.destroy
    flash[:notice] = "That category has been removed."
    
    respond_to do |format|
      format.html { redirect_to admin_item_categories_url }
    end
  end

  private
  
  def find_item_category
    @item_category = ItemCategory.find(params[:id])
  end
    
end