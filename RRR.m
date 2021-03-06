function [x_est, error, diff, last_iter] = RRR(y, x_init, K, x_true, parameters)
%
% The RRR algorithm
%
% Inputs:
%
% y - the observed data
% x_init - initial guess of the signal
% K - expected sparsity level
% x_true is used only to measure the error compared with the true signal

% Output:
%
% x_est - the final estimation of the signal
% error - the error compared with the ground truth (for all iterations)
% diff - the difference between consecutive iterations, used to stop the
% iterations
% last_iter - number of RRR iterations
%
% Tamir Bendory
% Last update: July, 2021
%

beta = parameters.beta; % RRR step size
max_iter = parameters.max_iter;
verbosity = parameters.verbosity; %either 0 or 1
th = parameters.th; % stopping criterion

x_est = x_init;
diff = zeros(max_iter,1);
error = zeros(max_iter,1);
last_iter = max_iter;

% main loop
for iter = 1:max_iter
    
    % one RRR iteration
    x1 =  P1(x_est, K); %, mode, alpha);
    x2 = P2(2*x1 - x_est, y);
    x_est = x_est + beta*(x2-x1);
    
    % stopping criterion
    x_proj_new = P1(x_est, K); %, mode, alpha);
    %diff(iter) = norm(x_proj -x_proj_new)/norm(x_proj);
    diff(iter) = norm(y - abs(fft(x_proj_new)))/norm(y);
    x_proj = x_proj_new;
 %   error(iter) = compute_error(x_proj, x_true);
    
    if mod(iter, max_iter/1000) == 0 &&  verbosity == 1
        fprintf('iter = %g, eta = %.4g, error = %.4g\n', iter, diff(iter), error(iter));
    end
    
    if diff(iter)<th
        last_iter = iter;
        diff = diff(1:last_iter);
%        error = error(1:last_iter);
        break;
    end
end

% output
x_est = P1(x_est, K); %, mode, alpha);

end

%% Auxiliary functions

%function x1 = P1(x, K, mode, alpha)
function x1 = P1(x, K)
% Projecting onto the significant K entries

x1 = zeros(size(x));
[val, ind] = maxk(x, K); %, 'ComparisonMethod','abs');
x1(ind) = val;

end

function x2 = P2(x, y)
% projection onto the Fourier magnitude of y
x2 = ifft(y.*sign(fft(x)));
end
% 
% function err = compute_error(x_est, x_true)
% % comparing the error between the two signals, while taking all symmetries
% % into account
% X_true = fft(x_true);
% X_est = fft(x_est);
% a1 = abs(ifft(X_true.*X_est)); % the abs values takes also the sign change into account
% a2 = abs(ifft(X_true.*conj(X_est))); % the reflected signal
% max_correlation = max([a1; a2]);
% %max_correlation = max(max(a1),max(a2));
% err = norm(x_est).^2 + norm(x_true).^2 - 2*max_correlation;
% err = err/norm(x_true).^2; % relative error
% end
