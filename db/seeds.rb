seeds = [
  {
    :model => EducationLevel,
    :data => ['College Degree', 'High School', 'Primary School'].map { |name| {:name => name} }
  },
  {
    :model => ConsumerType,
    :data => [
      ['Researcher', 'Give me reviews'],
      ['Trendster', 'If it is hip and in I want it'],
      ['Thrifster', 'The best deal is all I need'],
    ].map{ |data| {:name => data[0], :description => data[1]} }
  },
]
seeds.each do |seed|
  if seed[:model].count == 0
    seed[:data].each do |attributes|
      seed[:model].create!(attributes)
    end
  end
end
