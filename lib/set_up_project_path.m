function set_up_project_path(path_to_project_root,folders_to_add,cd_proj_root)
%this function is used to set up the path and current directory
%for a function in a project

% inputs
% path_to_project_root  - path to the root folder of the project
%                           if empty then the directory of the calling function is used
%                           a common choice is the current path pwd
% folders_to_add        - cell array of char vectors, eg {'dev','lib','bin'}
%                           if empty then default folders {'dev','lib','bin','test'} are used
%                           can use + as shorthand for the default folders {'dev','lib','bin','test'} so {'+','figs'} would add
%                           {'dev','lib','bin','test','figs'}
% cd_proj_root          - should the current directory be changed to the project root
%                           default true 

default_folders={'dev','lib','external','bin','test'};



if nargin<1 || isempty(path_to_project_root)
    path_to_project_root='.';
end

if nargin<2 || isempty(folders_to_add)
    folders_to_add=default_folders;
else
   idx_plus=strcmp(folders_to_add,'+');
   folders_to_add(idx_plus)=[];
   % note: this does not preserve order but who cares
   folders_to_add=cat(2,folders_to_add,default_folders);
end
%remove duplicates
folders_to_add=unique(folders_to_add);



if nargin<3 || isempty(cd_proj_root)
    cd_proj_root=true;
end

% if the path to root is relative then se the current directory to the calling function
if strcmp(path_to_project_root(1),'.')
    % find the path of the script/function that called this function 
    fun_stack_obj=dbstack;

    calling_function_name=fun_stack_obj(2).file;
    %fprintf('name of file what path will be relative to "%s" \n',calling_function_name)
    calling_function_path = which(calling_function_name);
    calling_function_path=fileparts(calling_function_path); %remove the function name
    path_to_project_root=fullfile(calling_function_path,path_to_project_root);
end

%change to the project root if requested and if the current folder is not that already
if cd_proj_root && ~strcmp(pwd,cd_proj_root)
    cd(path_to_project_root)
end

possible_genpath_places={'./lib/Core_BEC_Analysis/bin/genpath_exclude/',...
    './bin/genpath_exclude/'};
%try to find genpath_exclude without adding everything
look_for_genpath=1;
found_genpath=0;
search_index=1;
while look_for_genpath
    if search_index>numel(possible_genpath_places)
        look_for_genpath=false;
    elseif exist(possible_genpath_places{search_index},'dir')==7
        look_for_genpath=false;
        found_genpath=true;
        path_to_genpath=possible_genpath_places{search_index};
    end
    search_index=search_index+1;
end

%if it has not been found in these locations try the brute option
if ~found_genpath
    %add eveything in all the subfolders so that we can find genpath_exclude
    % Add that folder plus all subfolders to the path.
    addpath(genpath(path_to_project_root));%add all subfolders to the path to find genpath_exclude
    if exist('genpath_exclude','file')~=2
        error('could not find genpath_exclude check that it exists in your project folder')
    end
    path_to_genpath=fileparts(which('genpath_exclude'));
end

path(pathdef) %clean up the path back to the default state to remove all the folders .git that were added
addpath(path_to_project_root)
addpath(path_to_genpath)

for ii=1:numel(folders_to_add)
    path_to_adding_folder=fullfile(path_to_project_root,folders_to_add{ii});
    if exist(path_to_adding_folder,'dir')==7
        addpath(genpath_exclude(path_to_adding_folder,'\.'))%dont add hidden folders
    else 
        warning('%s: folder you have requested to add ("%s") does not exist ',mfilename,folders_to_add{ii})
    end
end




end