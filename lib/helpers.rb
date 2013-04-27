environment = ENV['NANOC_ENV']

production = (environment == 'production')
$minify_js = production
$concat_js = $minify_js || production
$production = production
$testing = !production

module JavaScript
  def js_re
    %r<^/js/(.*)/$>
  end

  def test_re
    %r<^/js/(.*)-spec/$>
  end

  # The main module
  def main_item()
    @items.find { |i| i.identifier == '/js/main/' }
  end

  # All "normal" code modules
  def module_items()
    main = main_item
    @items.select do |i|
      i.identifier =~ js_re and
      i.identifier !~ test_re and
      i.identifier != '/js/all/' and
      i.identifier != '/js/main/'
    end
  end

  # Test sources (spec files)
  def test_items()
    @items.select do |i|
      i.identifier =~ test_re
    end
  end

  def src_for_item(item)
    item.identifier.chop + '.js'
  end

  def script_tag(item)
    src = src_for_item(item)
    "<script src=\"#{src}\"></script>"
  end

  def script_tags(items)
    items.map do |item|
      script_tag item
    end.join ''
  end

end

include JavaScript

class OggEncFilter < Nanoc::Filter
  identifier :oggenc
  type :binary => :binary
  def run(filename, params={})
    r = `oggenc -o #{output_filename} #{filename}`
    return r if $?.exitstatus == 0
    raise "oggenc failed: #{$?}"
  end
end

class Mp3EncFilter < Nanoc::Filter
  identifier :mp3enc
  type :binary => :binary
  def run(filename, params={})
    r = `lame #{filename} #{output_filename}`
    return r if $?.exitstatus == 0
    raise "lame failed: #{$?}"
  end
end
