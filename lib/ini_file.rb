class IniFile
  VERSION = [1,0,0]
  TODO = {
    :strip_inline_comments => true,
    :unescape_values => true,
    :line_continuation => true
  }

  BLANK                     = ''
  SECTION                   = '['
  DEFAULT_COMMENT_CHAR      = ';'
  DEFAULT_VALUE_DELIMITER   = '='
  DEFAULT_SECTION_DELIMITER = '.'

  DUPLICATION_HANDLER = {
    :overwrite  => proc { |o, n| n },
    :concat     => proc { |o, n| "#{ o }#{ n }" },
    :to_array   => proc { |o, n| (Array === o)? o << n : [o, n] }
  }
  DUPLICATION_HANDLER.
      default = proc { |*| raise IndexError, 'value already set'}

  RE_INTEGER  = /^\d+$/
  RE_FLOAT    = /^\d*\.\d+$/

  def initialize(enumerable, parse_opts) #:nodoc:
    @enumerable   = enumerable
    @cchr         = parse_opts[:cchr] || DEFAULT_COMMENT_CHAR
    @vdelim       = parse_opts[:vdelim] || DEFAULT_VALUE_DELIMITER
    @sdelim       = parse_opts[:sdelim] || DEFAULT_SECTION_DELIMITER
    @dup_handler  = DUPLICATION_HANDLER[ parse_opts[:dup_handler] ]
    @typecast     = parse_opts.fetch :typecast, true

    @ini = {}
  end

  # Opens file at <tt>path</tt> and yields or returns the parsed content.
  #
  # See parse for details on <tt>parse_opts</tt>.
  def self.open(path, parse_opts = {})
    if block_given?
      Kernel.open(path) { |io| yield parse(io, parse_opts) }
    else
      Kernel.open(path) { |io| parse(io, parse_opts) }
    end
  end
  # Parses <tt>object</tt> and returns a Hash.
  #
  # Valid options are (with defaults):
  #   :cchr     => ';'  # => Comment character
  #   :vdelim   => '='  # => Value delimiter
  #   :sdelim   => '.'  # => Section delimiter
  #   :dup_handler      # => default raises an IndexError
  #   :typecast => true # => typecast numeric values to Integer or Float
  def self.parse(object, parse_opts = {})
    enumerable = case object
        when String: object.split("\n")
        when IO: object
        else
          raise ArgumentError
        end
    instance = new enumerable, parse_opts

    instance.__send__ :parse
  end
  # Dumps <tt>hash</tt> to <tt>out</tt> and returns <tt>out</tt>.
  #
  # Valid options are (with defaults):
  #   :vdelim => '='  # => Value delimiter
  #   :sdelim => '.'  # => Section delimiter
  def self.dump(hash, out = '', options = {})
    indent    = options[:indent] || 0
    vdelim    = options[:vdelim] || DEFAULT_VALUE_DELIMITER
    sdelim    = options[:sdelim] || DEFAULT_SECTION_DELIMITER
    sections  = Array options[:sections]
    nested    = {}

    hash.each do |key, value|
      if Hash === value then nested[key] = value
      else
        out << "#{ ' ' * indent }"
        out << "#{ key } #{ vdelim } #{ value }\n"
      end
    end

    nested.each do |key, value|
      s = sections.map << key
      o = options.merge :indent => indent + 2, :sections => s

      dump value, out << "#{ ' ' * indent }[#{ s * sdelim }]\n", o
    end

    out
  end

  protected

    def parse #:nodoc:
      current = @ini

      @enumerable.each do |line|
        line = line.strip # make a copy when stripping

        case line[0, 1]
        when BLANK # NOP
        when @cchr # NOP
        when SECTION; current = extract_current_section line
        else
          key, value = line.split(@vdelim, 2).each { |v| v.strip! }
          value = typecast value if @typecast

          # TODO[:strip_inline_comments]
          # TODO[:unescape_values]

          previous = current[key] and value = @dup_handler[previous, value]

          # TODO[:line_continuation]

          current[key] = value
        end
      end

      @ini
    end

    def extract_current_section(line) #:nodoc:
      line.delete! '[]'
      line.split(@sdelim).inject(@ini) { |current, section|
        section.strip!
        if current[section].is_a? Hash then current[section]
        elsif current[section].nil? then current[section] = {}
        else
          raise TypeError
        end
      }
    end

    def typecast(value) #:nodoc:
      case value
      when RE_INTEGER; Integer(value)
      when RE_FLOAT; Float(value)
      else
        # remove quotes at the beginning and the end of value
        value.gsub(/(?:^['"]|['"]$)/, '')
      end
    end

end
