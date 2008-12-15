class Yui
  MAJOR = 0
  MINOR = 0
  RELEASE = 3
  def Yui.version
    [MAJOR,MINOR,RELEASE].join('.')
  end
  
  YUI_ROOT    = File.join(File.dirname(__FILE__),'..','..')
      
  # Grabs a glob of files
  # @param inpath [String] path
  # @param options [Hash]
  # @see Yui#defaults
  #
  # inpath + options[:type] will create a glob,
  #   directory structure will be replicated in outputh
  #
  # @example
  #   Yui.new("./javascripts")
  #   [/javascripts/main.js, /javascripts/folder/other.js]
  #
  def initialize(inpath,options={})
    @inpath   = inpath
    @options  = Yui.defaults.merge(options)
    glob_path = File.join(@inpath,"**","*.#{@options[:type]}")
    @files    = Dir.glob(glob_path)
    
    #Dont compress ruby-yui files.
    @files.delete_if {|file| file =~ /#{@options[:suffix]}/}
    
    self.clobber if @options[:clobber]
  end
  attr_reader :files
  attr_reader :inpath
  attr_reader :options
  
  def outpath
    @options[:out_path] || @inpath
  end
  
  #Clobbers files with the right suffix/type in the outpath
  #   outpath defaults to inpath
  def clobber
    Yui.clobber(outpath,@options[:suffix],@options[:type])
  end
  
  # Bundles a set of files to 
  #   #{@options[:out_path]}/bundle.#{@options[:suffix]}.#{@options[:type]}
  #
  # @return [String|nil]
  #   Returns path to bundle if successful, otherwise nil
  #
  def bundle
    bundle_data = ""
    successful_compressions = 0
    @files.each do |file|
      cmd = Yui.gen_cmd(file,@options)
      stdin, stdout, stderr = Open3.popen3(cmd.join(' '))
      bundle_tmp = stdout.read
      
      if stderr.read.empty?
        puts "Bundling: #{file}"
        bundle_data += "\n#{bundle_tmp}"
        successful_compressions += 1
      else
        puts "Failed to bundle: #{file}"
      end
    end
    
    if successful_compressions == @files.length
      bundle_file_name = "bundle.#{@options[:suffix]}.#{@options[:type]}"
      bundle_path = File.join(outpath,bundle_file_name)
      File.open(bundle_path,'w'){|f| f.write(bundle_data)}
      return bundle_path
    else
      return nil
    end
  end
  
  def minify
    successful_compressions = 0
    
    @files.each do |file|
      out_file = file.split('.')      # split on '.'
      out_file.pop                    # pop off file extension
      out_file.push @options[:suffix] # add yui min suffix
      out_file.push @options[:type]   # add extension back on
      out_file = out_file.join('.')    # put it all together
      
      out_file.sub!(@inpath,outpath) if @options[:out_path]
      
      cmd = Yui.gen_cmd(file,@options)
      cmd << "-o #{out_file}"
      
      FileUtils.mkdir_p File.dirname(out_file)

      puts "Compressing:\n\t #{file} =>\n\t #{out_file}"
      stdin, stdout, stderr = Open3.popen3(cmd.join(' '))

      if stdout.read.empty? && stderr.read.empty?
        successful_compressions += 1 
      else
        puts "Failed to compress: #{file}"
      end
    end
    
    return (successful_compressions == @files.length)
  end
  alias :compress :minify
      
  # Clobber *.SUFFIX.(js|css)
  def Yui.clobber(path,suffix,type)
    files = Dir.glob(File.join(path,"**","*.#{suffix}.#{type}"))
    files.each do |file|
      puts "Clobbering #{file}..."
      FileUtils.rm file
    end
  end
  
  # Compresses inpath with options
  # @see Yui#initialize
  # @return [Boolean]
  #   Was 100% of files compressed
  #
  def Yui.compress(inpath,options={})
    _yui_obj = Yui.new(inpath,options)
    _yui_obj.minify
  end
  
  protected
  # Generates the command line call
  def Yui.gen_cmd(in_file,options)
    _cmd = [%{#{options[:java_cli]} #{options[:yui_jar]} #{in_file}}]
    _cmd << "--charset #{options[:charset]}" if options[:charset]
    _cmd << "--nomunge" if options[:nomunge]
    _cmd << "--preserve-semi" if options[:preserve_semi]
    _cmd << "--disable-optimizations" if options[:disable_opt]
    _cmd
  end
  
  
  def Yui.defaults
    {
      :clobber        => false,
      :java_cli       => "java -jar",
      :yui_jar        => File.join(YUI_ROOT,"ext","yuicompressor-2.4.2.jar"),
      :suffix         => "yui-min",
      :out_path       => nil,   #file_path.sub(inpath,outpath)
      :type           => :js,
      :charset        => nil,
      :preserve_semi  => false,
      :disable_opt    => false,
      :nomunge        => false
    }
  end
end