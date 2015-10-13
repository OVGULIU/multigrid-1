function [Z,data] = relax(A,B,Z,iters,varargin)
  % RELAX  Relax (smooth) a current solution iteratively.
  %
  % [Z] = relax(A,B,Z,iters)
  % [Z,data] = relax(A,B,Z,iters,'ParameterName',ParameterValue,...)
  % 
  % Inputs:
  %   A  n by n system matrix (should be positive definite)
  %   B  n by ncols right-hand side
  %   Z  n by ncols current solution
  %   iters  number of iterations to run
  %   Optional:
  %     'Method' followed by one of:
  %       'jacobi'  Use Jacobi iterations
  %       'sor'  use successive over relaxation (Gauss-Seidel with a weight)
  %     'Weight'  followed by weight used for 'jacobi' or 'sor'
  %     'Data'  followed by a struct of precomputed data (see output)
  % Outputs:
  %   Z  n by ncols new solution
  %   data  struct of precomputed data set by solver or passed as input
  %

  method = 'jacobi';
  data = [];
  w = 0.1;
  V = [];
  T = [];
  % Map of parameter names to variable names
  params_to_variables = containers.Map( ...
    {'Method','Data','Weight','V','T'}, ...
    {'method','data','w','V','T'});
  v = 1;
  while v <= numel(varargin)
    param_name = varargin{v};
    if isKey(params_to_variables,param_name)
      assert(v+1<=numel(varargin));
      v = v+1;
      % Trick: use feval on anonymous function to use assignin to this workspace
      feval(@()assignin('caller',params_to_variables(param_name),varargin{v}));
    else
      error('Unsupported parameter: %s',varargin{v});
    end
    v=v+1;
  end

  %  Perform pre_jac steps of weighted Jacobi with weight w
  nsp = 2;
  %Z = pcg(A,B,1e-13,iters,[],[],Z);
  switch method
  case 'sor'
    % http://www.mathworks.com/matlabcentral/fileexchange/19206-successive-under-over-relaxation/content//sor.m
    if ...
      ~isfield(data,'DL') ||  isempty(data.DL) || ...
      ~isfield(data,'UE') || isempty(data.UE)
      D = diag(diag(A));
      L = -tril(A,-1);
      U = -triu(A,1);
      data.DL = D - w*L;
      data.UE = (1-w)*D + w*U;
    end
    BE = w*B;
    t = [];
    for iter = 1:iters
      %if ~isempty(V) && mod(iter,10)==0
      %  if isempty(t);
      %    t = tsurf(T,[V Z],'EdgeAlpha',1000/size(T,1));
      %    view(0,0);
      %  else
      %    set(t,'Vertices',[V Z],'CData',Z);
      %  end
      %  drawnow;
      %end
      Z = data.DL\(data.UE*Z + BE);
    end
  case 'gauss-seidel-alt'
    % http://stackoverflow.com/a/20914215/148668
    if ...
      ~isfield(data,'Q') || isempty(data.Q)
      data.Q=tril(A);
    end
    for iter=1:2*iters
      Z=Z+data.Q\(B-A*Z);
    end
  case 'jacobi'
    for iter = 1:iters
      Z = Z+w*(B-A*Z);
    end
  end
end