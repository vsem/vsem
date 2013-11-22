function matrix = pmiReweight(matrix)
% pointwise mutual information operator [I,Pxy] = pmi(matrix)
%
%Build the contingency matrix, then the MLE estimate of the joint
%probabilites.

Mi = sum(matrix,2);%column of row marginal counts
Mj = sum(matrix,1);%row of column marginal counts
Mt = sum(Mi);%either the sum of the row or columns marginal counts.
MiMj = Mi* Mj;
matrix = (double(matrix) * Mt)./ MiMj;%pointwise quotient of probs.

%When nans are generated, some adjustements are required
%Consider Mij=1, Mi=1, Mj=1, Mt -> Inf. The quotient goes to Inf, and the
%counts are indiscernible from as many zeroes. However, when only two of
%the counts go to zero, Mij must vanish more quickly than Mi (or Mj), hence
%the quotient goes to zero.

mynans = isnan(matrix);%This should be sparse!
if any(any(mynans))
    [in,jn]=find(mynans);
    both = (Mi(in,1) + Mj(jn)')==0;%both counts are zero: these go to 0.
    sP = size(matrix);
    matrix(sub2ind(sP,in(both),jn(both)))=0;
    matrix(sub2ind(sP,in(~both),jn(~both)))=0;%and aldo the quotienf goes to 0.
end
%Now work out the real matrix
matrix = log2(matrix);%This is bad for sparse matrices.
matrix(matrix < 0) = 0;
matrix = real(matrix);

