class Users::FavoritesController < ApplicationController
  before_filter :login_required
  before_filter :parse_params, :only => [:update]
  before_filter :find_user, :except => [:show]
  skip_before_filter :set_facebook_session, :only => [:show]

  def edit
    @categories = ItemCategory.find_all_by_parent_id(nil, :limit => 8)
    @items = {}
    @user.top.each{|e| @items[e.item.category.id] = e}
    
    if params[:created] && params[:created]=="true"
      session[:help_text_on_top]=true
    end

    if params[:from] == 'profile'
      render(:template => "users/favorites/edit_for_profile.html.haml", :layout => "layouts/profile")
    else
      render(:template => "users/favorites/edit_for_wizard.html.haml")
    end
  end

  def update
    begin
      case params[:ref]
      when 'homepage'
        act = '/'
      when 'profile'
        flash[:notice] = "Your Top Hyped List has been updated"
        act = edit_user_favorites_path(@user, :from => "profile")
      else
        act = edit_user_profile_path(@user)
      end

      UserTop.create_or_update(@items, @user)
      ItemFavorite.add_to_favorites(@items,@user)

    rescue => err
      flash[:notice] = err.message#"Error has occured"
    end

    redirect_to(act)
  end

  def show
    @user = User.find(params[:user_id], :select => 'users.id')
    category = ItemCategory.find(params[:category_id])
    offset = params[:offset] || 0
    if (offset.to_i == 5)
      @category_favorites, more = @user.paginated_favorites(category, false, :offset => offset, :limit => 50) 
      render(:partial => 'items/item', :collection => @category_favorites)
    else
      render(:nothing => true)
    end
  end
  
  def show_before_unload
    user=User.find(params[:user_id])
    render(:partial=>'show_before_unload', :layout=>false, :locals=>{:user=>user})
  end

  private

  def parse_params
    @items = {}
    params.each {|k,v| @items[k.split('_')[0]] = v if (k =~ /_field/)}
  end

end
