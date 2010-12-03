module Friends::ContactsHelper
  def contact_name(item)
    if item[0].nil?
      return item[1]
    else
      return item[0]
    end
  end
end
