# The most pragmatic approach to ease the usage of our rake helper library is
# to require this file which itself requires all other files.

$LOAD_PATH.unshift '.'
$LOAD_PATH.unshift File.dirname(__FILE__)

require "require_ext"

require "log"
require "platform"
require "template"
require "clean"
require "file_utils_ext"
