class Yui
  YUI_ROOT    = File.join(File.dirname(__FILE__),'..','..')
  @@java_cli  = "java -jar"
  @@yui_lib   = File.join(YUI_ROOT,"ext","yuicompressor-2.4.2.jar")
  @@suffix    = "min"
  
  def Yui.configure(params={})
    @@java_cli  = params[:java_cli] if params[:java_cli]
    @@yui_lib   = params[:yui_lib] if params[:yui_lib]
    @@suffix    = params[:suffix] if params[:suffix]
  end
  
  # Parse a glob of files
  # @param inpath [String] path
  # @param options [Hash]
  # @see Yui#defaults
  #
  # inpath + options[:type] will create a glob,
  #   directory structure will be replicated in outputh
  #
  # @example
  #   Yui.minify("./javascripts")
  #   /javascripts/main.js => /javascripts/main.min.js
  #
  def Yui.minify(inpath,options={})
    options = defaults.merge(options)
    
    glob_path = File.join(inpath,"**","*.#{options[:type]}")
    files = Dir.glob(glob_path)
    
    files.each do |file|
      out_file = file.split('.')  #split on .
      out_file.pop                #Pop off .js or .css
      out_file.push @@suffix
      out_file.push options[:type]
      out_file = out_file.join('.')
      puts "Compressing: \n\t#{file} => \n\t #{out_file}"
      
      Yui.compress(file,out_file,options)
    end
  end
    
  def Yui.compress(in_file,out_file,options)
    _cmd = [%{#{@@java_cli} #{@@yui_lib} #{in_file}}]
    _cmd << "-o #{out_file}" unless options[:bundle]
    _cmd << "--charset #{options[:charset]}" if options[:charset]
    _cmd << "--nomunge" if options[:nomunge]
    _cmd << "--preserve-semi" if options[:preserve_semi]
    _cmd << "--disable-optimizations" if options[:disable_opt]
    
    stdin, stdout, stderr = Open3.popen3(%{#{_cmd.join(' ')}})
  end
  
  # Clobber *.min.(js|css)
  def Yui.clobber(path,type=:js)
    files = Dir.glob(File.join(path,"**","*.min.#{type}"))
    files.each do |file|
      puts "Clobbering #{file}..."
      FileUtils.rm file
    end
  end
  
  protected
  def Yui.defaults
    {
      :type           => :js,
      :charset        => nil,
      :preserve_semi  => false,
      :disable_opt    => false,
      :nomunge        => false,
      :bundle         => false #TODO bundle take nil or path to bundle
    }
  end
end