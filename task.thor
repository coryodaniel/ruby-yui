require 'ruby-yui'
class RubyYui < Thor
  desc "minify PATH", "Minify all javascript in the path"
  def minify(path)
    yui = Yui.new path
    yui.minify
  end
  
  desc "bundle PATH", "Minify and bundle all javascript in the path"
  def bundle(path)
    yui = Yui.new path
    yui.bundle
  end
  
  def clobber(path)
    yui = Yui.new path
    yui.clobber
  end
end