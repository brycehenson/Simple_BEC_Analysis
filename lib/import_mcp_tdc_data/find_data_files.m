function shots=find_data_files(import_opts)
%finds the the files that match the format (in name only) of a data file
%could add an option to check the first few lines of the data file
%Bryce Henson
% TODO
% standard function header


if ~isfield(import_opts, 'file_name') ,import_opts.file_name='d'; end



%check that the folder exists
if exist(import_opts.dir,'dir')~=7, error('import directory does not exist'), end
dirq=dir(import_opts.dir);
dir_names={dirq.name};
dir_names={dir_names{3:end}};
shot_mask=contains(dir_names,import_opts.file_name) ...
        & ~contains(dir_names,'txy_forc') & contains(dir_names,'txt');
dir_names={dir_names{shot_mask}};
dir_nums=zeros(1,size(dir_names,2));
file_name_width=size(import_opts.file_name,2);
for n=1:size(dir_names,2)
    if isequal(dir_names{n}(1:file_name_width),import_opts.file_name) ...
            && isequal(dir_names{n}(end-3:end),'.txt') &&... 
            sum(isstrprop((dir_names{n}(1+file_name_width:end-4)),'digit')==0)==0
        dir_nums(n)=str2num(dir_names{n}(2:end-4));
    else 
        dir_nums(n)=NaN;
    end
end
dir_nums=dir_nums(~isnan(dir_nums));
dir_nums=sort(dir_nums);
shots=dir_nums;  

end