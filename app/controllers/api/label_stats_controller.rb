module Api
  class LabelStatsController < BaseResourceController
    def index
      item = Item.first(:integer_id => params[:item_id].to_i, :select => 'id')
      item_id = item.id if item
      if params[:pro]
        label_stats = LabelStat.paginate(paging_params.merge(:type => "pro", :item_id => item_id, :order => "value DESC"))
      else # cons
        label_stats = LabelStat.paginate(paging_params.merge(:type => "con", :item_id => item_id, :order => "value DESC"))
      end
      @json_opts = { 
        :methods => [
          :item_integer_id,
          :text,
          :count,
          :integer_id
        ] 
      }
      json_objects =  label_stats.collect { |c| c.as_json(@json_opts) }
      response =  { :paging => json_paging, :objects => json_objects }
      render :json => response
    end
  end
end