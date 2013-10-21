function PI = pmiReweight(N)
% pointwise mutual information operator [I,Pxy] = pmi(N)
%
%Build the contingency matrix, then the MLE estimate of the joint
%probabilites.

Ni = sum(N,2);%column of row marginal counts
Nj = sum(N,1);%row of column marginal counts
Nt = sum(Ni);%either the sum of the row or columns marginal counts.
NiNj = Ni* Nj;
PI = (double(N) * Nt)./ NiNj;%pointwise quotient of probs.

%When nans are generated, some adjustements are required
%Consider Nij=1, Ni=1, Nj=1, Nt -> Inf. The quotient goes to Inf, and the
%counts are indiscernible from as many zeroes. However, when only two of
%the counts go to zero, Nij must vanish more quickly than Ni (or Nj), hence
%the quotient goes to zero.

mynans = isnan(PI);%This should be sparse!
if any(any(mynans))
    [in,jn]=find(mynans);
    both = (Ni(in,1) + Nj(jn)')==0;%both counts are zero: these go to 0.
    sP = size(PI);
    PI(sub2ind(sP,in(both),jn(both)))=0;
    PI(sub2ind(sP,in(~both),jn(~both)))=0;%and aldo the quotienf goes to 0.
end
%Now work out the real matrix
PI = log2(PI);%This is bad for sparse matrices.
PI(PI < 0) = 0;
PI = real(PI);

