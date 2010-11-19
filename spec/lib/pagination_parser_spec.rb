require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PaginationParser do
  ['1 p., 5 maps',
    '12 + 532 pp.',
    '24 pp. 24 pls.',
    '247 pp. + 14 pl. + 4 pp. (index)',
    '312 + (posthumous section) 95 pp.',
    '5-187 + i-viii pp.',
    '5 maps',
    '8 pls., 84 pp.',
    'i-ii, 279-655',
    'xi',
    '93-114, 121',
    'P. 1',
    '33pp.',
    '33 pp.',
    'Pp. 63-396 (part)',
  ].each do |pagination|
    it "should handle '#{pagination}'" do
      string = pagination.dup
      PaginationParser.parse(string).should == pagination
      string.should be_empty
    end
  end

  it "shouldn't consider '4th' a pagination" do 
    PaginationParser.parse('4th').should be_nil
  end

end
