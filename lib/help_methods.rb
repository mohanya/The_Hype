class Array

  def uniq_slice
    return [] if self.empty?
    @actual = self.first

    inject([[]]) do |r,e|
      if @actual.first != e.first
        r << []
        r.last << e
        @actual = e.first
      else
        r.last << e
      end
      r
    end
  end
end
