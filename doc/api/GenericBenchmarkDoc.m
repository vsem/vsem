%% benchmarks.GenericBenchmark class
%
% *Package:* benchmarks
%
% <html>
% <span style="color:#666">The base class of a benchmark</span>
% </html>
%
%% Description
%
% |benchmarks.GenericBenchmark| defines the abstract methods that 
% have to be implemented from its subclasses.
%
%
%% Methods (Abstract)
%
% |score = computeBenchmark(obj, concepts, varargin)| To be implemented by
% its subclasses.
%
% |benchmark = buildBenchmark(obj)| To be implemented by its subclasses.
%