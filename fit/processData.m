function [T, units] = createDataTable(s)
% createDataTable takes a struct array (from readfitraw) and returns a
% TimeTable with fixed times, properly formatted data, and NaNs. All data
% is numeric.

% number of messages
N = numel(s);

% get list of fields
fields = unique([s.fields]);

% empty data structures to be filled in
units = cell(1,numel(fields));
data = nan(N,numel(fields));

for i=1:N
    
    % number of fields
    n = numel(s(i).fields);
    
    for j=1:n
        f = s(i).fields{j};
        u = s(i).units{j};
        v = s(i).values{j};
        
        col = find(strcmp(f,fields));
        
        % validate and fill units
        if isempty(units{col})
            units{col} = u;
        else
            assert(strcmp(units(col),u),'Mismatched units: %s %s i=%d',u,units{col},i)
        end
        
        % fill data
        if ~isempty(v)
            data(i,col) = v;
        end
    end
    
end

% Remove timestamp column to use to build timetable
timecol = find(strcmp('timestamp',fields));
dates = timestamp2datetime(data(:,timecol));
data(:,timecol) = [];
units(timecol) = [];
fields(timecol) = [];

% Build table
T = array2timetable(data,'RowTimes',dates,'VariableNames',fields);
end
