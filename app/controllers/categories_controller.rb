class CategoriesController < ApplicationController
  def index
    @items = Item.all
  end

end
