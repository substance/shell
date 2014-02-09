require("logger")

# TODO: make this configurable

LOGGER = Logger.new(STDOUT)
LOGGER.level = Logger::INFO
def log
  LOGGER
end
