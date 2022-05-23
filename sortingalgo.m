%% Import data from spreadsheet
% Script for importing data from the following spreadsheet:
%
%    Workbook: C:\Users\twny1\Desktop\ProjectManagementsheetfixed.xlsx
%    Worksheet: Form Responses 1
%
% Auto-generated by MATLAB on 19-May-2022 11:15:26

%% Set up the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 14);

% Specify sheet and range
opts.Sheet = "Form Responses 1";
opts.DataRange = "A2:N35";

% Specify column names and types
opts.VariableNames = ["Timestamp", "EmailAddress", "FirstName", "LastName", "ClothingSwap", "LinkedInProfile", "EarthDayWildlifePreserve", "NeuromodulationForDummies", "AnimalHandling", "TextbookExchange", "MNWildEvent", "ArtMural", "OPTIONALIsThereAProjectThatYouDONOTWishToBeAssignedToifYouSkipT", "OPTIONALOtherConsiderationsForPlacementIntoAProjectExamplesExpe"];
opts.VariableTypes = ["datetime", "string", "string", "string", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "string"];

% Specify variable properties
opts = setvaropts(opts, ["EmailAddress", "FirstName", "LastName", "OPTIONALOtherConsiderationsForPlacementIntoAProjectExamplesExpe"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["EmailAddress", "FirstName", "LastName", "ClothingSwap", "LinkedInProfile", "EarthDayWildlifePreserve", "NeuromodulationForDummies", "AnimalHandling", "TextbookExchange", "MNWildEvent", "ArtMural", "OPTIONALIsThereAProjectThatYouDONOTWishToBeAssignedToifYouSkipT", "OPTIONALOtherConsiderationsForPlacementIntoAProjectExamplesExpe"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, "Timestamp", "InputFormat", "");

% Import the data
ProjectManagementsheetfixed1 = readtable("C:\Users\twny1\Desktop\ProjectManagementsheetfixed.xlsx", opts, "UseExcel", false);


%% Clear temporary variables
clear opts


% NEED TO EDIT THESE
T = ProjectManagementsheetfixed1; % this is just the name of the file (no path or extension)
outfile = "C:\Users\twny1\Desktop\testfinal.xlsx" % this needs to have quotes and full path and extension
namecol = 4; % column number with names
firstcol = 5; % first project column
lastcol = 12; % last project column
optionalcol = 13; % column where students list projects don't like
maxgroupsize = 5;
mingroupsize = 4;
% Done editing

nrows = size(T,1);
ncols = size(T,2);

%check some numbers
total1 = maxgroupsize*(lastcol-firstcol);
total2 = mingroupsize*(lastcol-firstcol);
if total1 >= nrows && total2 <= nrows
    disp("Group size numbers okay");
end

%initialize matrix
Matrixall = ones(nrows,ncols);

% convert matrix to values for minimization 
% more negative numbers are "better"
for i=1:nrows
    for j=1:ncols
        
        if string(T{i,j}) == "This is my project"
            Matrixall(i,j) = -100;
        end
        
        if string(T{i,j}) == "Top Choice A"
            Matrixall(i,j) = -4;
        end
        
        if string(T{i,j}) == "Top Choice B"
            Matrixall(i,j) = -3;
        end
        
        if string(T{i,j}) == "3rd Choice"
            Matrixall(i,j) = -2;
        end
        
        if string(T{i,j}) == "4th Choice"
            Matrixall(i,j) = -1;
        end
    end
end

% this part makes sure students aren't put into projects they don't want
for k=1:nrows
    for j=1:ncols
        s1 = string(T{k,optionalcol});
        s2 = strrep(s1,' ','');
        if s2== string(T.Properties.VariableNames(j))
            Matrixall(k,j) = 100;
        end
    end
end

% creates a streamlined matrix with just project minimization values
pcols=lastcol-firstcol+1;
p = ones(nrows,pcols);

for i=1:nrows
    for j=firstcol:lastcol
        jnew = j-firstcol+1;
        p(i,jnew)=Matrixall(i,j);
    end
end

e1 = ones(nrows);
e2 = ones(pcols);

% below is the optimization

cvx_begin
cvx_solver mosek

variable y(nrows,pcols) binary % if y(i,j) = 1 student is placed in project
obj=0;
for i=1:nrows, for j=1:pcols, obj = obj + y(i,j)*p(i,j); end, end % minimizes group total
minimize obj
    subject to
        e1*y <= maxgroupsize; % ensures groupsize isn't violated
        e1*y >= mingroupsize; % ensures groupsize isn't violated
        y*e2' == 1; % this makes sure no student is assigned to multiple projects
  
        cvx_end
        y;
        cvx_optval;

        
% create a blank final table
Final = array2table(string(zeros(maxgroupsize,pcols)));

for i=1:pcols
    
    Final.Properties.VariableNames(i)=T.Properties.VariableNames(i+firstcol-1);
end

for i=1:maxgroupsize
    for j=1:pcols
        Final(i,j)={""};
    end
end

% insert names into final table
for i=1:nrows
    for j=1:pcols
        
        if y(i,j) > 0.9 % this needs to be 0.9 or it wasn't working right.  I think the optimization
                        % for y isn't exactly integers even though it is
                        % supposed to be such.  Matlab is weird with
                        % matrices sometimes
            k=1;
            while Final{k,j} ~= ""
                k=k+1;
            end
            Final(k,j) = T(i,namecol);
        end
    end
end

% create output table
writetable(Final,outfile)