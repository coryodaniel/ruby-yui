require File.join(File.dirname(__FILE__),'..','..','lib','ruby-yui','yui')
require 'digest/md5'

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
  
  it 'should raise an exception if no outpath and no suffix is specified' do
    lambda {
      yui = Yui.new "./test/data/javascripts", :suffix => nil
    }.should raise_error(Exception)
  end
  
  it 'should be able to specify an alternate out path' do
    yui = Yui.new "./test/data/javascripts", :out_path => "./test/data/alt_out_path/javascripts"
    yui.minify
    
    File.exist?("./test/data/alt_out_path/javascripts/prototype.yui-min.js").should be(true)
    File.exist?("./test/data/alt_out_path/javascripts/jquery-1.2.6.yui-min.js").should be(true)
    
    FileUtils.rm "./test/data/alt_out_path/javascripts/prototype.yui-min.js"
    FileUtils.rm "./test/data/alt_out_path/javascripts/jquery-1.2.6.yui-min.js"
  end
  
  it 'should have an identical file name (optionally path) if no suffix is supplied' do
    yui = Yui.new "./test/data/javascripts", :suffix => nil, :out_path => "./test/data/alt_out_path/javascripts"
    yui.minify

    File.exist?("./test/data/alt_out_path/javascripts/prototype.js").should be(true)
    File.exist?("./test/data/alt_out_path/javascripts/jquery-1.2.6.js").should be(true)
    
    FileUtils.rm "./test/data/alt_out_path/javascripts/prototype.js"
    FileUtils.rm "./test/data/alt_out_path/javascripts/jquery-1.2.6.js"
  end
  
  it 'should allow originals to be stomped with :stomp => true' do
    pre_md5   = Digest::MD5.hexdigest(File.read("./test/data/stompers/stompable.js"))
    yui = Yui.new "./test/data/stompers", :suffix => nil, :stomp => true
    yui.minify
    post_md5  = Digest::MD5.hexdigest(File.read("./test/data/stompers/stompable.js"))
    
    pre_md5.should_not == post_md5
    
    #restore backups after testing...
    FileUtils.cp "./test/data/backups/stompable.js", "./test/data/stompers/stompable.js"
    
  end
end