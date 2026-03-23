function value = dynamicvariable(base_name, suffix)
    % GETDYNAMICVARIABLE Safely access variable with dynamic name
    
    % Construct full variable name
    var_name = [base_name, suffix];
    
    % Check if variable exists in caller workspace
    if evalin('caller', ['exist(''', var_name, ''', ''var'')'])
        value = evalin('caller', var_name);
    else
        error('Variable %s not found', var_name);
    end
end