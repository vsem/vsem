function m = DiagMatrixLinear(cfext,a,b)
    % m = DiagMatrix(a, b)
    %
    % Creates a zero matrix with ones on the diagonal, where the diagonal goes
    % from the top-left to bottom-right corner . If a equals b, then this
    % function does the same as the Matlab build-in function 'eye'.
    %
    % Additionally, do a linear interpolation. This function can be used to 
    % sum values over N x N regions within a matrix.
    %
    % NOTE: a / b OR b / a should result in an integer!
    %
    % a:        Number of rows
    % b:        Number of columns
    %
    % m:        a x b matrix with ones on the diagonal and zeros elsewhere.

    if a < b
        % The function creates a matrix m with a larger amount of rows than
        % columns. Transpose after function if necessary.
        c = a;
        a = b;
        b = c;
        clear c;
        transposed = true;
    else
        transposed = false;
    end

    if mod(a/b, 1) > 0
        warning('A should be divisible by B or vice versa!');
        m = [];
        return
    end

    %%% Creation of m
    m = zeros(a, b);
    nP = a / b;

    % For even and uneven we have a different type of values: with uneven nP
    % the middle pixel is really the center of the bin. Otherwise the center of
    % the bin is in between 2 pixels.
    % Note that we do linear interpolation
    if mod(nP,2) == 0 % even
        %     assignment = ([1:nP nP:-1:1] - 0.5 )/ nP;
        assignment = cfext.NormalizeRows([1:nP nP:-1:1] - 0.5 );

        iB = nP / 2+1;
        iE = iB + 2 * nP - 1;

        for i=2:b-1
            m(iB:iE,i) = assignment;
            iB = iB + nP;
            iE = iE + nP;
        end

        % Now we need only the last and first row
        firstAssignment = ((nP:-1:1) - 0.5) / nP;
        firstAssignment = [repmat(1, 1, nP/2) firstAssignment];
        m(1:1.5*nP,1) = cfext.NormalizeRows(firstAssignment);
        lastAssignment = ones(1, a - iB + 1);
        lastAssignment(1,1:nP) = ((1:nP) - 0.5) / nP;
        m(iB:end,b) = cfext.NormalizeRows(lastAssignment);    
    else % uneven
        %     assignment = [1:nP nP-1:-1:1] / nP;
        assignment = cfext.NormalizeRows([1:nP nP-1:-1:1]);

        iB = (nP+1) / 2 + 1;
        iE = iB + 2 * nP - 2;

        for i=2:b-1
            m(iB:iE,i) = assignment;
            iB = iB + nP;
            iE = iE + nP;
        end

        % Now we need only the last and first row
        firstAssignment = ((nP:-1:1)) / nP;
        firstAssignment = [repmat(1, 1, (nP-1)/2) firstAssignment];
        m(1:(nP + (nP-1)/2)) = cfext.NormalizeRows(firstAssignment);
        lastAssignment = ones(1, a - iB + 1);
        lastAssignment(1,1:nP) = (1:nP) / nP;
        m(iB:end,b) = cfext.NormalizeRows(lastAssignment);    
    end


    % transpose if necessary
    if transposed
        m = m';
    end

    m = sparse(m);

end
