function out_string=string_value_with_unc(value,unc,varargin)
%string_value_with_unc - prints value with uncert. and the right number of sig figs
%
% Syntax:  output_string=import_data(value,unc,type)
%
% Inputs:
%    value      - numeric, value 
%    unc        - nmeric, uncertianty in the value
%    type       - to use the � notation as in 10�3 pass 's','standard','pm' to use the () notation as in 10(3) pass , 'b','brackets'

%
% Outputs:
%    out_string - char vec, the formated value

%
% Example: 

% string_value_with_unc(50.1234,0.15,'s')
% '50.12�0.15'
% string_value_with_unc(8.547896541,0.001,'b')
% '8.5479(10)'
% string_value_with_unc(854738.96541,200,'b')
% '854700(200)'

% Other m-files required: none
% Also See:test_string_value_with_unc
% Subfunctions: none
% MAT-files required: none
%
% Known BUGS/ Possible Improvements
%    -more commenting
%
% Author: Bryce Henson
% email: Bryce.Henson@live.com
% Last revision:2019-07-02

%------------- BEGIN CODE --------------


%% parse the optional inputs
% type,comma_sep,remove_common_factors

is_c_logical=@(in) isequal(in,true) || isequal(in,false); %can x be cast as a logical
validtypes={'s','standard','pm','b','brackets'};
type_ok_fun=@(x) sum(contains(validtypes,x))==1;
p = inputParser;
addParameter(p,'type','standard',type_ok_fun);
addParameter(p,'separator',true,@(x) is_c_logical(x) || (ischar(x) && numel(x)==1) );
addParameter(p,'remove_common_factors',0,is_c_logical);
parse(p,varargin{:});

type=p.Results.type;

rem_com_fac=p.Results.remove_common_factors;

if p.Results.separator==false || p.Results.separator==0
    use_sep=0;
else
    use_sep=1;
    if ischar(p.Results.separator)
        if numel(p.Results.separator)==1
            sep_char=p.Results.separator;
        else
            error('must be single char')
        end
    else
        sep_char=' '; %default sep char
end


if ~isnumeric(value) || ~isnumeric(unc)
    error('value and uncert. must be numeric')
end


% find the first decimal place
unc_first_decimal_place=floor(log10(unc));
% i think this section can be done a little better
fractional_unc_error=abs(((10^unc_first_decimal_place)-unc)/unc);
if fractional_unc_error<=(1/3)
    two_sig_figs=1;
else
    two_sig_figs=0;
end
% if the value is beteen 1*10^i and 1.5*10^i (where i is an integer) then show two decimal places
decimal_place_unc=unc_first_decimal_place-two_sig_figs;
rounded_unc=(10^decimal_place_unc)*round(unc*(10^(-decimal_place_unc)));
rounded_val=(10^decimal_place_unc)*round(value*(10^(-decimal_place_unc)));

% standard plus-minus format
if sum(strcmp(type,{'s','standard','pm'}))>0

    if rem_com_fac
        error('remove common factors feature is not yet implemented')
    end
    
    if use_sep
        unc_str=num_with_sep(rounded_unc,...
                            'format',sprintf('%%.%uf',max([0,-decimal_place_unc])),...
                            'separator',sep_char,...
                            'add_sep_after_decimal',1);
        val_str=num_with_sep(rounded_val,...
                            'format',sprintf('%%.%uf',max([0,-decimal_place_unc])),...
                            'separator',sep_char,...
                            'add_sep_after_decimal',1);        
    else
        unc_str=sprintf('%.*f',max([0,-decimal_place_unc]),rounded_unc);
        val_str=sprintf(sprintf('%%.%uf',max([0,-decimal_place_unc])),rounded_val);
    end
    out_string=cat(2,val_str,'�',unc_str);

    
%metrology brackets notation    
elseif  sum(strcmp(type,{'b','brackets'}))>0
    unc_str=sprintf('%.0f',rounded_unc*(10^(max([0,-decimal_place_unc]))));
    if use_sep
        val_str=num_with_sep(rounded_val,...
                            'format',sprintf('%%.%uf',max([0,-decimal_place_unc])),...
                            'separator',sep_char,...
                            'add_sep_after_decimal',1);
    else
        val_str=sprintf(sprintf('%%.%uf',max([0,-decimal_place_unc])),rounded_val);
    end
    out_string=cat(2,val_str,'(',unc_str,')');
else
    error('did not pass valid format string')
end


end