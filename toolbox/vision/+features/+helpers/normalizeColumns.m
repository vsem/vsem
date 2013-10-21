function normD = normalizeColumns(D,n)
    %NORMALIZECOLUMNS Normalize the columns of a matrix to a given sum.
    %
    % normalizeColumns(D,n)
    %
    % Normalizes the columns of D to sum to n (default 1).

    sumD = sum(D);

    % Make sure there is no division by zero
    sumD(sumD == 0) = 1;

    % By default, the columns will sum to 1 (L1 normalization)
    if nargin == 1
        n = 1;
    end

    % Normalize
    normD = bsxfun(@rdivide, D, sumD / n);
