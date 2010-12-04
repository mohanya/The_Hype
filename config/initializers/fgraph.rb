# module FGraph
# 
#   # Collection objects for Graph response with array data.
#   #
#   class Collection < Array 
#     
#     # Initialize Facebook response object with 'data' array value.
#     
#     #####################################
#     ## MONKEY PATCH
#     ## Have to decode the JSON string in order to get the initializer to work correctly
#     #####################################
#     
#     def initialize(response)
#       return super unless response
#       
#       response = ActiveSupport::JSON.decode(response)
#       super(response['data'])
#       paging = response['paging'] || {}
#       self.next_url = paging['next']
#       self.previous_url = paging['previous']
#     end
#   end
# end