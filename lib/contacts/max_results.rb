class Contact 
  class Gmail < Base
    Contacts::Gmail::CONTACTS_FEED = "http://www.google.com/m8/feeds/contacts/default/full/?max-results=10"
  end
end
