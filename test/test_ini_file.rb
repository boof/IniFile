require 'tempfile'
require 'test/unit'

require 'ini_file'

class TestIniFile < Test::Unit::TestCase

  DATA_POS = DATA.pos

  def setup
    DATA.pos = DATA_POS
  end

  def assert_data(data)
    section = data['section']
    assert_kind_of Hash, section
    assert_equal 'simple value', section['simple']
    assert_equal 'single quoted value', section['single_quoted']
    assert_equal 'double quoted value', section['double_quoted']

    nested = section['nested']
    assert_kind_of Hash, nested
    assert_equal 1, nested['integer']
    assert_equal 0.1, nested['float']
    assert_equal 'value', nested['key']
  end

  def test_read_io
    assert_data IniFile.parse(DATA)
  end
  def test_read_string
    assert_data IniFile.parse(DATA.read)
  end

  def test_open_without_block
    Tempfile.open('ini_file') do |tempfile|
      tempfile.sync = true
      tempfile << DATA.read

      assert_data IniFile.open(tempfile.path)
    end
  end
  def test_open_with_block
    Tempfile.open('ini_file') do |tempfile|
      tempfile.sync = true
      tempfile << DATA.read

      IniFile.open(tempfile.path) { |data| assert_data data }
    end
  end

  def test_dump
    Tempfile.open('ini_file') do |tempfile|
      tempfile.sync = true

      data = IniFile.parse(DATA)
      IniFile.dump data, tempfile

      IniFile.open(tempfile.path) { |data| assert_data data }
    end
  end

end

__END__
; Comment
[ section ]
  simple = simple value
  single_quoted = 'single quoted value'
  double_quoted = "double quoted value"
  [ section.nested ]
    integer = 1
    float = .1
    key = value