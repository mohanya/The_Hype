atom_feed(:url => formatted_posts_url(:atom), :schema_date => @site.created_at) do |feed|
  feed.title("Posts")
  feed.updated(@posts.first ? @posts.first.created_at : Time.now.utc)

  for post in @posts
    feed.entry(post, :id => post.id) do |entry|
      entry.title(post.title)

      entry.content(post.body, :type => 'html')
      
      entry.link(:rel => "alternate", :href => post_url(post))
      entry.author do |author|
        author.name post.author.name
      end
    end
  end
end