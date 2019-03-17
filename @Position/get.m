% @Parameter/get.m: return attribute value for given property key
function m = get (obj, property)
  if (nargin == 1)
    m = obj.name;
  elseif (nargin == 2)
    if (ischar (property))
      % check, if property is an unique existing field
        try
            m = obj.(property);
        catch
            fprintf('get: allowed fieldnames:\n');
            fieldnames(obj)
            error ('get: invalid property of %s class: >>%s<<\n',class(obj),property);
        end
    else
      error ('get: expecting the property to be a string');
    end
  else
    print_usage ();
  end
end