# Auto-generated ruby debug require       
require "ruby-debug"
Debugger.start
Debugger.settings[:autoeval] = true if Debugger.respond_to?(:settings)
# TODO md5 checksum the compressed files for spec testing to verify they were compressed correctly.
# TODO output yui.checksums.txt "#{OUT_PATH}\t#{CHECKSUM}\n"

require 'open3'
require 'fileutils'

class Yui
  include Open3
  
  class NoInputFileException < Exception;end;
  
  MAJOR = 0
  MINOR = 0
  RELEASE = 4
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
    @options[:suffix] = "" if @options[:suffix].nil?
    glob_path = File.join(@inpath,"**","*.#{@options[:type]}")
    @files    = Dir.glob(glob_path)
    
    if @options[:suffix].empty? && outpath == @inpath && @options[:stomp] == false
      raise Exception, "Your originals will be destroyed without a suffix or an outpath, run again with :stomp => true to allow this."
    end
    
    #Dont compress ruby-yui files.
    @files.delete_if {|file| file =~ /#{@options[:suffix]}/} unless @options[:suffix].empty?
    
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
    raise(NoInputFileException, "Nothing to do, check input path.")if @files.empty?
    
    bundle_data = ""
    successful_compressions = 0
    @files.each do |file|
      cmd = Yui.gen_cmd(file,@options)
      stdin, stdout, stderr = popen3(cmd.join(' '))
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
      if @options[:suffix].empty?
        bundle_file_name = "bundle.#{@options[:type]}"
      else
        bundle_file_name = "bundle#{@options[:suffix]}.#{@options[:type]}"
      end
      bundle_path = File.join(outpath,bundle_file_name)
      File.open(bundle_path,'w'){|f| f.write(bundle_data)}
      return bundle_path
    else
      return nil
    end
  end
  
  def minify
    raise(NoInputFileException, "Nothing to do, check input path.") if @files.empty?
    
    successful_compressions = 0
    
    @files.each do |file|
      #put the suffix on before the externsion if provided
      if @options[:suffix].empty?
        out_file = file.clone
      else
        out_file = file.split('.')
        out_file.pop #pop off extension
        out_file = out_file.join('.') << @options[:suffix] << ".#{@options[:type]}"
      end
      
      #Substitute the outpath
      out_file.sub!(@inpath,outpath)
      
      cmd = Yui.gen_cmd(file,@options) << "-o #{out_file}"
      
      FileUtils.mkdir_p File.dirname(out_file)

      puts "Compressing:\n\t #{file} =>\n\t #{out_file}"
      stdin, stdout, stderr = popen3(cmd.join(' '))

      stdout = stdout.read
      stderr = stderr.read

      if stdout.empty? && stderr.empty?
        successful_compressions += 1 
      else
        puts "Failed to compress: #{file}"
        if @options[:rename_on_fail] && !@options[:suffix].empty?
          puts "Copying:\n\t #{file} =>\n\t #{out_file}"
          FileUtils.cp file, out_file
        end

        puts "OUT: #{stdout}"
        puts "ERR: #{stderr}"
      end
    end
    
    return (successful_compressions == @files.length)
  end
  alias :compress :minify
      
  # Clobber *.SUFFIX.(js|css)
  def Yui.clobber(path,suffix,type)
    if suffix.empty?
      glob_path = File.join(path,"**.#{type}")
    else
      glob_path = File.join(path,"**","*#{suffix}.#{type}")
    end
    
    Dir.glob(glob_path).each do |file|
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
    Yui.new(inpath,options).minify
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
      :suffix         => ".yui-min",
      :out_path       => nil,   #file_path.sub(inpath,outpath)
      :type           => :js,
      :charset        => nil,
      :preserve_semi  => false,
      :disable_opt    => false,
      :nomunge        => false,
      :stomp          => false, #destroys originls if NO suffix and NO out_path
      :rename_on_fail => false  #If failed to compress and suffix given, original file will be renamed still
    }
  end
end