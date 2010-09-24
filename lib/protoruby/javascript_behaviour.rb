# Create a lambda with javascript 'apply' and 'call' methods, called
# +js_apply+ and +js_call+, respectivly
module JavascriptFunction
  def js_apply(obj,args)
		obj.instance_exec(*args,&self)
	end
	def js_call(obj,*args)
		obj.instance_exec(*args,&self)		
	end
end

def js_function(&block)
  block.extend JavascriptFunction
end
