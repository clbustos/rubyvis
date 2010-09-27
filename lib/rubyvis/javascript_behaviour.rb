unless Object.public_method_defined? :instance_exec
  class Object
    module InstanceExecHelper; end
    include InstanceExecHelper
    def instance_exec(*args, &block) # :nodoc:
      begin
        old_critical, Thread.critical = Thread.critical, true
        n = 0
        n += 1 while respond_to?(mname="__instance_exec#{n}")
        InstanceExecHelper.module_eval{ define_method(mname, &block) }
      ensure
        Thread.critical = old_critical
      end
      begin
        ret = send(mname, *args)
      ensure
        InstanceExecHelper.module_eval{ remove_method(mname) } rescue nil
      end
      ret
    end
  end

end
# Add javascript-like +apply+ and +call+ methods to Proc,
# called +js_apply+ and +js_call+, respectivly.
# Requires Ruby 1.9
class Proc
  def js_apply(obj,args)
		obj.instance_exec(*args,&self)
	end
	def js_call(obj,*args)
		obj.instance_exec(*args, &self)		
	end
end
