class ItemDetail
  include MongoMapper::EmbeddedDocument

  key :feature_group, String
  key :features, Hash

end
