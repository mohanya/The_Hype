class Admin::ItemMediasController < AdminController
  before_filter :find_item

  def new
    @item_media = ItemMedia.new
  end

  def create
    media = ItemMedia.new
    media.remote_image_url = params[:item_media][:remote_image_url]
    if media.save
       @item.medias << media
      flash[:notice] = "New image created"
    else
      flash[:error] = "Image creation failed!"
    end
    respond_to do |format|
      format.html { redirect_to edit_admin_item_path(@item) }
    end
  end

  def update
    @item_media = ItemMedia.find(params[:id])
    old_primary_media = ItemMedia.first(:primary => true, :item_id => @item_media.item_id)
    old_primary_media.primary = false
    @item_media.primary = true
    old_primary_media.save
    @item_media.save

    respond_to do |format|
      flash[:notice] = "Item primary image switched."
      format.html { redirect_to edit_admin_item_path(@item) }
    end
  end

  def destroy
    @item_media = ItemMedia.find(params[:id])
    @item_media.destroy

    respond_to do |format|
      flash[:notice] = "Item image removed."
      format.html { redirect_to edit_admin_item_path(@item) }
    end
  end

  def parse_google_url(google_url)
    google_url = google_url.to_s
    s = google_url.split(":").last
    image_url = (s.starts_with?("//") ? 'http:' : 'http://') + s
    CGI.unescape(image_url)
  end

  private
  def find_item
    @item = Item.find(params[:item_id])
  end
end
