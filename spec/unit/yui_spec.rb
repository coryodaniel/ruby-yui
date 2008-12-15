require File.join(File.dirname(__FILE__),'..','..','lib','ruby-yui','yui')

describe Yui do
  it 'should provide a set of defaults via Yui.defaults' do
    Yui.defaults.class.should be(Hash)
  end  
    
  it 'should be able to minify a set of files' do 
    yui = Yui.new "./test/data/javascripts"
    yui.minify.should be(true)
    File.exist?("./test/data/javascripts/prototype.yui-min.js").should be(true)
    yui.clobber
  end
  
  it 'should be able to bundle a set of files' do
    yui = Yui.new "./test/data/javascripts"
    yui.bundle.should == ("./test/data/javascripts/bundle.yui-min.js")
    File.exist?("./test/data/javascripts/bundle.yui-min.js").should be(true)
    yui.clobber
  end
  
  it 'should provide a class level compressor' do
    Yui.respond_to?(:compress).should be(true)
    Yui.compress("./test/data/javascripts")
    File.exist?("./test/data/javascripts/prototype.yui-min.js").should be(true)
  end
  
  it 'should provide a class level clobber' do
    Yui.respond_to?(:clobber).should be(true)
    Yui.compress("./test/data/javascripts")
    File.exist?("./test/data/javascripts/prototype.yui-min.js").should be(true)
    Yui.clobber("./test/data/javascripts",Yui.defaults[:suffix],:js)
  end
  
  it 'should be able to clobber a set of files' do
    yui = Yui.new "./test/data/javascripts"
    yui.minify
    File.exist?("./test/data/javascripts/prototype.yui-min.js").should be(true)
    yui.clobber
    File.exist?("./test/data/javascripts/prototype.yui-min.js").should be(false)
  end  
  
  it 'should raise an exception if no input files are present' do
    yui = Yui.new "./NOT_A_FOLDER"
    lambda {
      yui.minify
    }.should raise_error(Yui::NoInputFileException)
    lambda {
      yui.bundle
    }.should raise_error(Yui::NoInputFileException)
  end
end