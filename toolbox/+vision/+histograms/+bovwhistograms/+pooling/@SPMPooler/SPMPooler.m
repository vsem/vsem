classdef SPMPooler < handle & vision.histograms.bovwhistograms.pooling.GenericPooler
    %SPMPooler Pooling using the spatial pyramid match kernel
    
    properties
        turnMeOff
        subbin_norm_type    % 'l1' or 'l2' (or other value = none)
        norm_type    % 'l1' or 'l2' (or other value = none)
        post_norm_type    % 'l1' or 'l2' (or other value = none)
        pool_type    % 'sum' or 'max'
        quad_divs
        horiz_divs
        kermap  % 'homker', 'hellinger' (or other value = none [default])
    end
    
    properties(SetAccess=protected)
        encoder_     % implementation of featpipem.encoding.GenericEncoder
    end
    
    methods
        function obj = SPMPooler(turnMeOff, subbin_norm_type, norm_type, post_norm_type, pool_type, quad_divs, horiz_divs, kermap, encoder)
            % set default parameter values
            obj.turnMeOff = turnMeOff;
            obj.subbin_norm_type = lower(subbin_norm_type);
            obj.norm_type = lower(norm_type);
            obj.post_norm_type = lower(post_norm_type);
            obj.pool_type = lower(pool_type);
            obj.quad_divs = quad_divs;
            obj.horiz_divs = horiz_divs;
            obj.kermap = lower(kermap);
            
            % setup encoder
            obj.encoder_ = encoder;
        end
        function dim = get_output_dim(obj)
            
            if obj.turnMeOff
                dim = obj.encoder_.get_output_dim();
                % account for expansion in dimensionality when using kernel map
                if strcmp(obj.kermap,'homker')
                    dim = dim*3;
                end
            else
                % check bin levels
                if mod(log2(obj.quad_divs),1)
                    error('quad_divs must be a power of 2');
                end
                bin_quads_count = obj.quad_divs*obj.quad_divs;
                bin_quad_levels = 1;
                bin_div_tmp = obj.quad_divs;
                while bin_div_tmp ~= 2
                    bin_div_tmp = bin_div_tmp/2;
                    bin_quad_levels = bin_quad_levels + 1;
                    bin_quads_count = bin_quads_count + bin_div_tmp*bin_div_tmp;
                end
                clear bin_div_tmp;
                
                bin_count = bin_quads_count + obj.horiz_divs + 1;
                dim = bin_count*obj.encoder_.get_output_dim();
                % account for expansion in dimensionality when using kernel map
                if strcmp(obj.kermap,'homker')
                    dim = dim*3;
                end
            end
        end
        pcode = compute(obj, imsize, feats, frames)
    end
    
end

