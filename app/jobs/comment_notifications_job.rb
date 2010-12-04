class CommentNotificationsJob < Struct.new(:item_comment)
  def perform  
    unless item_comment.depth == 0
      item_comment.conversation_members.each do |commentator|
        UserMailer.deliver_comment_notice(item_comment, commentator) if commentator.comment_notice == '1'
      end
    end
    item_owner = item_comment.item.user
    UserMailer.deliver_comment_notice_to_item_owner(item_comment, item_owner) if item_owner.profile.comment_notice
  end
end
