classdef WaitBar < handle
% WaitBar waiting bar handle
%   WaitBar(processedItems, text, optionalInput) creates a handle to a
%   Matlab waitbar for 'processedItems' number of items (e.g. in a loop).
%   'text' is displayed inside the waitbar. Alternatively, it produces a
%   textual waitbar to be displayed on shell environments.
%
%   The third input argument is optional:
%
%   No input
%     Creates a graphical waitbar of black color.
%
%   RGB color
%     Putting as input a 1x3 vector with decimal RGB components creates a
%     graphical waitbar of that color.
%
%   'textVersion'
%     Builds a textual waitbar, suited for shell or otherwise non graphical
%     environments.
%
%
% Authors: A2
%
% AUTORIGHTS
%
% This file is part of the VSEM library and is made available under
% the terms of the BSD license (see the COPYING file).

    
    properties
        bar
        text
        processedItems
        textualVersion = true;
    end
    
    properties (Constant, Hidden)
        defaultColor = [0 0 0];
    end
    
    methods
        function obj = WaitBar(processedItems, text, varargin)
            
            % checking input
            if nargin == 2
                
                % bar with default color
                barColor = obj.defaultColor;
                
            elseif nargin == 3
                if strcmpi(varargin{1}, 'textVersion')
                    
                    % triggering textual version
                    obj.textualVersion = true;
                    
                else
                    
                    % checking and assigning bar color
                    assert(isa(varargin{1}, 'double') && all(size(varargin{1}) == [1, 3]), 'Incorrect input, provide either ''textVersion'' for a textual version of the WaitBar, or a 1x3 vector with decimal RGB colors. No input returns graphical black bar.');
                    barColor = varargin{1};
                end
            else
                
                % checking for alternative input
                error('Too many input arguments.');
            end
            
            % initializing properties and bar value
            obj.processedItems = processedItems;
            obj.text = text;
            value = 0;
            
            if obj.textualVersion
                
                % initializing textual bar and initial print
                obj.bar = '|________________________________________|';
                clc;
                fprintf('%s %s  %i%%\n\n', obj.text, obj.bar, value);
                pause(0.5);
                
            else
                
                % initializing bar, cancel button and bar color
                obj.bar = waitbar(value,[obj.text '0%'],'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
                barHandle = findobj(obj.bar,'type','patch');
                set(barHandle,'FaceColor', barColor, 'EdgeColor', obj.defaultColor);
                setappdata(obj.bar,'canceling',0);
            end
        end
        
        function update(obj,i)
            
            % textual version case
            if obj.textualVersion
                
                % calculating floored value and number of pipes
                value = round(i/(obj.processedItems)*20)*5;
                pipes = sum(double(obj.bar(2:end-1)) == 124);
                
                if value/2.5 > pipes
                    
                    % clearing screen
                    clc;
                    
                    % adding two pipes to the bar by half tens
                    for i = 1:(value/5 - pipes/2)
                        obj.bar([pipes + 2*i, pipes + 2*i + 1]) = '||';
                    end
                    
                    % printing textual bar and pausing half a second (for short loops)
                    fprintf('%s %s  %i%%\n', obj.text, obj.bar, value);
                    pause(0.5)
                end
            else
                
                % determining current value for the bar
                value = i/(obj.processedItems);
                
                % producing formatted and displayed text
                formattedText = [obj.text '%' num2str(floor(log10(value*100)+1)) '.0f%%'];
                displayedText = sprintf(formattedText,value*100);
                
                % generating waitbar
                waitbar(value,obj.bar,displayedText);
            end
        end
    end
    
    methods (Hidden)
        
        % being a handle method, this destructor is issued at object's destruction
        function delete(obj)
            if obj.textualVersion
                % clc;  % uncomment to clear screen after finishing a loop
            else
                % deleting handle object for graphic bar
                delete(obj.bar);
            end
        end
    end
end
