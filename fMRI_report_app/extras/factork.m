function[gridFactors]=factork(X,M)
% factork    1-by-2 factorisation based on a number of divisors  
%
% factork(X,M) returns a 1-by-2 matrix whose elements are factors of X, and
% M is the divisor
%
% See also factor 
%
% Michael Asghar - November 2023
F = X./M;
F = ceil(F);
if M*F<X
    error('Your grid will be too small, increase M')
end
gridFactors = [M F];
end