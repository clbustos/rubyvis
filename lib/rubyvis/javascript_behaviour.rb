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
