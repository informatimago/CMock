class CMockGeneratorPluginReturnThruPtr
  attr_reader :priority
  attr_accessor :utils

  def initialize(config, utils)
    @utils        = utils
    @priority     = 9
    @config       = config
  end

  def instance_typedefs(function)
    lines = ''
    function[:args].each do |arg|
      next unless @utils.ptr_or_str?(arg[:type]) && !(arg[:const?])

      lines << "  char ReturnThruPtr_#{arg[:name]}_Used;\n"
      lines << "  #{arg[:type]} ReturnThruPtr_#{arg[:name]}_Val;\n"
      lines << "  size_t ReturnThruPtr_#{arg[:name]}_Size;\n"
    end
    lines
  end

  def void_pointer?(type)
    # returns true if the provided type is a void, or is supposed to be treated as void
    if type.casecmp?('void')
      true
    else
      @config.respond_to?(:treat_as_void) ? @config.treat_as_void.include?(type) : false
    end
  end

  def mock_function_declarations(function)
    lines = ''
    function[:args].each do |arg|
      next unless @utils.ptr_or_str?(arg[:type]) && !(arg[:const?])

      lines << "#define #{function[:name]}_ReturnThruPtr_#{arg[:name]}(#{arg[:name]})"
      # If the pointer type actually contains an asterisk, we can do sizeof the type (super safe), otherwise
      # we need to do a sizeof the dereferenced pointer (which could be a problem if give the wrong size
      # however if its a void pointer we are given then we have to use the provided parameter name because sizeof(void) is UB.
      lines << if (arg[:type][-1] == '*') && (void_pointer?(arg[:type][0..-2]) == false)
                 " #{function[:name]}_CMockReturnMemThruPtr_#{arg[:name]}(__LINE__, #{arg[:name]}, sizeof(#{arg[:type][0..-2]}))\n"
               else
                 " #{function[:name]}_CMockReturnMemThruPtr_#{arg[:name]}(__LINE__, #{arg[:name]}, sizeof(*#{arg[:name]}))\n"
               end
      lines << "#define #{function[:name]}_ReturnArrayThruPtr_#{arg[:name]}(#{arg[:name]}, cmock_len)"
      lines << " #{function[:name]}_CMockReturnMemThruPtr_#{arg[:name]}(__LINE__, #{arg[:name]}, cmock_len * sizeof(*#{arg[:name]}))\n"
      lines << "#define #{function[:name]}_ReturnMemThruPtr_#{arg[:name]}(#{arg[:name]}, cmock_size)"
      lines << " #{function[:name]}_CMockReturnMemThruPtr_#{arg[:name]}(__LINE__, #{arg[:name]}, cmock_size)\n"
      lines << "void #{function[:name]}_CMockReturnMemThruPtr_#{arg[:name]}(UNITY_LINE_TYPE cmock_line, #{arg[:type]} #{arg[:name]}, size_t cmock_size);\n"
    end
    lines
  end

  def mock_interfaces(function)
    lines = []
    func_name = function[:name]
    function[:args].each do |arg|
      arg_name = arg[:name]
      next unless @utils.ptr_or_str?(arg[:type]) && !(arg[:const?])

      lines << "void #{func_name}_CMockReturnMemThruPtr_#{arg_name}(UNITY_LINE_TYPE cmock_line, #{arg[:type]} #{arg_name}, size_t cmock_size)\n"
      lines << "{\n"
      lines << "  CMOCK_#{func_name}_CALL_INSTANCE* cmock_call_instance = " \
               "(CMOCK_#{func_name}_CALL_INSTANCE*)CMock_Guts_GetAddressFor(CMock_Guts_MemEndOfChain(Mock.#{func_name}_CallInstance));\n"
      lines << "  UNITY_TEST_ASSERT_NOT_NULL(cmock_call_instance, cmock_line, CMockStringPtrPreExp);\n"
      lines << "  cmock_call_instance->ReturnThruPtr_#{arg_name}_Used = 1;\n"
      lines << "  cmock_call_instance->ReturnThruPtr_#{arg_name}_Val = #{arg_name};\n"
      lines << "  cmock_call_instance->ReturnThruPtr_#{arg_name}_Size = cmock_size;\n"
      lines << "}\n\n"
    end
    lines
  end

  def mock_implementation(function)
    lines = []
    function[:args].each do |arg|
      arg_name = arg[:name]
      next unless @utils.ptr_or_str?(arg[:type]) && !(arg[:const?])

      lines << "  if (cmock_call_instance->ReturnThruPtr_#{arg_name}_Used)\n"
      lines << "  {\n"
      lines << "    UNITY_TEST_ASSERT_NOT_NULL(#{arg_name}, cmock_line, CMockStringPtrIsNULL);\n"
      lines << "    memcpy((void*)#{arg_name}, (void*)cmock_call_instance->ReturnThruPtr_#{arg_name}_Val,\n"
      lines << "      cmock_call_instance->ReturnThruPtr_#{arg_name}_Size);\n"
      lines << "  }\n"
    end
    lines
  end
end
