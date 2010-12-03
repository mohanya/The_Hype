class BaseResourceController < InheritedResources::Base
  respond_to :json
  actions :all
  
  skip_before_filter :set_facebook_session
  skip_before_filter :verify_authenticity_token

  protected

  def json_paging
    count = end_of_association_chain.count
    paging_params.merge(:total_objects => count, :total_pages => (count.to_f/paging_params[:per_page]).ceil)
  end

  def collection
    get_collection_ivar || set_collection_ivar(end_of_association_chain.paginate(paging_params))
  end
  
end
